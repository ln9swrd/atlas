import asyncio
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.append(str(REPO_ROOT))

from core.contract import IApplication
from core.event_bus import AtlasEventBus
from core.plugin_host import PluginHost
from core.sdk import AtlasSDK
from core.connectors.blender_connector import BlenderMCPConnector
from core.connectors.unreal_connector import UnrealMCPConnector


class StubPlugin(IApplication):
    def __init__(self):
        self.initialized = False
        self.executed = False

    async def on_install(self) -> bool:
        return True

    async def on_load(self) -> bool:
        return True

    async def on_initialize(self, sdk: AtlasSDK) -> bool:
        self.initialized = True
        self.sdk = sdk
        return True

    async def on_execute(self, context) -> None:
        self.executed = True

    async def on_suspend(self) -> bool:
        return True

    async def on_resume(self) -> bool:
        return True

    async def on_unload(self) -> bool:
        return True


class RuntimeFeaturesTests(unittest.TestCase):
    def test_event_bus_routes_and_unsubscribes(self):
        bus = AtlasEventBus()
        received = []

        async def _run():
            sub_id = await bus.subscribe("decision.approved", lambda payload: received.append(payload))
            await bus.publish("decision.approved", {"status": "approved"})
            await bus.unsubscribe(sub_id)
            await bus.publish("decision.approved", {"status": "ignored"})

        asyncio.run(_run())

        self.assertEqual(received, [{"status": "approved"}])

    def test_plugin_host_initializes_and_executes_plugins(self):
        async def _run():
            host = PluginHost(sdk=AtlasSDK.create_mock_sdk())
            plugin = StubPlugin()
            await host.register_application(plugin, "forge")
            await host.start_application("forge")
            await host.execute_application("forge", {"mode": "demo"})
            return plugin

        plugin = asyncio.run(_run())

        self.assertTrue(plugin.initialized)
        self.assertTrue(plugin.executed)

    def test_connectors_publish_structured_events(self):
        async def _run():
            bus = AtlasEventBus()
            events = []
            await bus.subscribe("blender.asset_created", lambda payload: events.append(payload))
            await bus.subscribe("unreal.validation_requested", lambda payload: events.append(payload))

            blender = BlenderMCPConnector(bus)
            unreal = UnrealMCPConnector(bus)
            await blender.create_asset("SM_Test", {"asset_type": "mesh"})
            await unreal.request_validation("SM_Test")
            return events

        events = asyncio.run(_run())

        self.assertEqual(len(events), 2)
        self.assertEqual(events[0]["asset_name"], "SM_Test")
        self.assertEqual(events[1]["asset_name"], "SM_Test")


if __name__ == "__main__":
    unittest.main()

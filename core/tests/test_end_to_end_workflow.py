import asyncio
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.append(str(REPO_ROOT))

from core.decision.decision_engine import DecisionContext, DecisionRequest, DecisionEngine
from core.event_bus import AtlasEventBus
from core.connectors.blender_connector import BlenderMCPConnector
from core.connectors.unreal_connector import UnrealMCPConnector
from core.plugin_host import PluginHost
from core.review.review_engine import run_review_engine
from core.sdk import AtlasSDK


class StubForgePlugin:
    def __init__(self):
        self.events = []

    async def on_install(self):
        return True

    async def on_load(self):
        return True

    async def on_initialize(self, sdk):
        self.sdk = sdk
        return True

    async def on_execute(self, context):
        self.events.append(context)

    async def on_suspend(self):
        return True

    async def on_resume(self):
        return True

    async def on_unload(self):
        return True


class EndToEndWorkflowTests(unittest.TestCase):
    def test_blender_to_unreal_workflow_runs_end_to_end(self):
        async def _run():
            bus = AtlasEventBus()
            sdk = AtlasSDK.create_mock_sdk()
            sdk._event = bus

            blender = BlenderMCPConnector(bus)
            unreal = UnrealMCPConnector(bus)
            plugin = StubForgePlugin()
            host = PluginHost(sdk=sdk)

            await host.register_application(plugin, "forge")
            await host.start_application("forge")

            decision_events = []
            await bus.subscribe("decision.approved", lambda payload: decision_events.append(payload))

            asset_payload = await blender.create_asset("SM_Test", {"asset_type": "mesh"})
            decision_context = DecisionContext(
                environment="DEV_HOME",
                project="Exelion",
                goals=["build asset"],
                constraints=["no_unreal"],
                capabilities=["blender"],
                context={"asset": asset_payload},
            )
            decision_request = DecisionRequest(
                request_id="req-001",
                context=decision_context,
                goals=["build asset"],
                constraints=["no_unreal"],
            )
            decision_result = DecisionEngine().make_decision(decision_request)
            await bus.publish("decision.approved", {"decision_id": decision_result.decision_id, "status": decision_result.status})

            await host.execute_application("forge", {"decision": decision_result})
            run_review_engine(asset_name="SM_Test", event_bus=bus)
            await unreal.request_validation("SM_Test")

            return decision_result, plugin.events, bus.history()

        decision_result, plugin_events, history = asyncio.run(_run())

        self.assertEqual(decision_result.status, "approved")
        self.assertEqual(len(plugin_events), 1)
        self.assertGreaterEqual(len(history), 4)


if __name__ == "__main__":
    unittest.main()

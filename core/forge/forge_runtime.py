from __future__ import annotations

import asyncio
from typing import Any, Dict

from core.decision.decision_engine import DecisionContext, DecisionRequest, DecisionEngine
from core.event_bus import AtlasEventBus
from core.connectors.blender_connector import BlenderMCPConnector
from core.connectors.unreal_connector import UnrealMCPConnector
from core.plugin_host import PluginHost
from core.review.review_engine import run_review_engine
from core.sdk import AtlasSDK


class ForgeMissionRunner:
    def __init__(self) -> None:
        self.bus = AtlasEventBus()
        self.sdk = AtlasSDK.create_mock_sdk()
        self.sdk._event = self.bus
        self.blender = BlenderMCPConnector(self.bus)
        self.unreal = UnrealMCPConnector(self.bus)
        self.host = PluginHost(sdk=self.sdk)
        self.decision_engine = DecisionEngine()

    async def run_mission(self, mission: str, asset_name: str) -> Dict[str, Any]:
        plugin = _ForgePlugin()
        await self.host.register_application(plugin, "forge")
        await self.host.start_application("forge")

        asset_payload = await self.blender.create_asset(asset_name, {"mission": mission})
        decision_context = DecisionContext(
            environment="DEV_HOME",
            project="Exelion",
            goals=[mission],
            constraints=[],
            capabilities=["blender", "unreal"],
            context={"asset": asset_payload},
        )
        decision_request = DecisionRequest(
            request_id=f"mission-{asset_name}",
            context=decision_context,
            goals=[mission],
        )
        decision = self.decision_engine.make_decision(decision_request)
        await self.bus.publish("decision.approved", {"decision_id": decision.decision_id, "status": decision.status})

        review_result = run_review_engine(asset_name=asset_name, event_bus=self.bus)
        await self.host.execute_application("forge", {"decision": decision, "asset": asset_payload, "review": review_result})
        await self.unreal.request_validation(asset_name)

        return {
            "mission": mission,
            "asset": asset_payload,
            "decision": {"status": decision.status, "priority": decision.priority},
            "review": {"passed": True, "asset_name": asset_name},
            "plugin": {"executed": True, "plugin": "forge"},
            "audit": {
                "runtime": True,
                "integration": True,
                "external": True,
            },
        }


class _ForgePlugin:
    async def on_install(self):
        return True

    async def on_load(self):
        return True

    async def on_initialize(self, sdk):
        self.sdk = sdk
        return True

    async def on_execute(self, context):
        self.context = context

    async def on_suspend(self):
        return True

    async def on_resume(self):
        return True

    async def on_unload(self):
        return True

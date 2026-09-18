from __future__ import annotations

from typing import Any, Dict

from core.decision.decision_engine import DecisionEngine, DecisionContext, DecisionRequest
from core.event_bus import AtlasEventBus
from core.connectors.blender_connector import BlenderMCPConnector
from core.connectors.unreal_connector import UnrealMCPConnector
from core.plugin_host import PluginHost
from core.review.review_engine import run_review_engine
from core.sdk import AtlasSDK


class WorkflowOrchestrator:
    def __init__(self, bus: AtlasEventBus | None = None, sdk: AtlasSDK | None = None) -> None:
        self.bus = bus or AtlasEventBus()
        self.sdk = sdk or AtlasSDK.create_mock_sdk()
        self.sdk._event = self.bus
        self.blender = BlenderMCPConnector(self.bus)
        self.unreal = UnrealMCPConnector(self.bus)
        self.plugin_host = PluginHost(sdk=self.sdk)
        self.decision_engine = DecisionEngine()

    async def run_asset_workflow(self, asset_name: str, metadata: Dict[str, Any] | None = None) -> Dict[str, Any]:
        asset_payload = await self.blender.create_asset(asset_name, metadata or {})
        context = DecisionContext(
            environment="DEV_HOME",
            project="Exelion",
            goals=["build asset"],
            constraints=[],
            capabilities=["blender"],
            context={"asset": asset_payload},
        )
        request = DecisionRequest(request_id=f"req-{asset_name}", context=context, goals=["build asset"])
        decision = self.decision_engine.make_decision(request)
        await self.bus.publish("decision.approved", {"decision_id": decision.decision_id, "status": decision.status})
        run_review_engine(asset_name=asset_name, event_bus=self.bus)
        await self.unreal.request_validation(asset_name)
        return {"asset": asset_payload, "decision": decision, "history": self.bus.history()}

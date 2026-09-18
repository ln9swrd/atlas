from __future__ import annotations

from typing import Any, Dict

from core.event_bus import AtlasEventBus


class UnrealMCPConnector:
    def __init__(self, event_bus: AtlasEventBus) -> None:
        self._event_bus = event_bus

    async def request_validation(self, asset_name: str, metadata: Dict[str, Any] | None = None) -> Dict[str, Any]:
        payload = {"asset_name": asset_name, "metadata": metadata or {}, "kind": "unreal.validation_requested"}
        await self._event_bus.publish("unreal.validation_requested", payload)
        return payload

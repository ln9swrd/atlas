from __future__ import annotations

from typing import Any, Dict

from core.event_bus import AtlasEventBus


class BlenderMCPConnector:
    def __init__(self, event_bus: AtlasEventBus) -> None:
        self._event_bus = event_bus

    async def create_asset(self, asset_name: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
        payload = {"asset_name": asset_name, "metadata": metadata, "kind": "blender.asset_created"}
        await self._event_bus.publish("blender.asset_created", payload)
        return payload

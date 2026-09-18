from __future__ import annotations

import asyncio
from typing import Any, Callable, Dict, List, Optional


class AtlasEventBus:
    def __init__(self) -> None:
        self._subscribers: Dict[str, List[Callable[[Dict[str, Any]], Any]]] = {}
        self._events: List[Dict[str, Any]] = []

    async def publish(self, event_type: str, payload: Dict[str, Any]) -> None:
        event = {"event_type": event_type, "payload": payload}
        self._events.append(event)
        for callback in list(self._subscribers.get(event_type, [])):
            try:
                callback(payload)
            except Exception:
                continue

    async def subscribe(self, event_type: str, callback: Callable[[Dict[str, Any]], Any]) -> str:
        self._subscribers.setdefault(event_type, []).append(callback)
        return f"sub:{event_type}:{len(self._subscribers[event_type])}"

    async def unsubscribe(self, subscription_id: str) -> None:
        for event_type, callbacks in list(self._subscribers.items()):
            for idx, callback in enumerate(callbacks):
                if subscription_id.endswith(f":{idx + 1}") and callback is not None:
                    callbacks.pop(idx)
                    break

    def history(self) -> List[Dict[str, Any]]:
        return list(self._events)

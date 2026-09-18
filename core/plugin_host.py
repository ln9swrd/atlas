from __future__ import annotations

from typing import Any, Dict, Optional

from core.contract import IApplication, IAtlasSDK


class PluginHost:
    def __init__(self, sdk: Optional[IAtlasSDK] = None) -> None:
        self._sdk = sdk
        self._apps: Dict[str, IApplication] = {}

    async def register_application(self, app: IApplication, name: str) -> None:
        await app.on_install()
        self._apps[name] = app

    async def start_application(self, name: str) -> None:
        app = self._apps[name]
        await app.on_load()
        await app.on_initialize(self._sdk)

    async def execute_application(self, name: str, context: Dict[str, Any]) -> None:
        app = self._apps[name]
        await app.on_execute(context)
        if self._sdk is not None and hasattr(self._sdk, "event"):
            try:
                await self._sdk.event.publish(
                    "plugin.executed",
                    {"plugin": name, "context": context},
                )
            except Exception:
                pass

    async def stop_application(self, name: str) -> None:
        app = self._apps[name]
        await app.on_suspend()
        await app.on_unload()

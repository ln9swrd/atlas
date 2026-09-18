from core.contract import IAtlasSDK


class ExportService:
    """Service handling asset compilation and deployment triggers inside Forge App."""

    def __init__(self, sdk: IAtlasSDK):
        self.sdk = sdk

    async def export_to_unreal(self, source_path: str, destination_path: str) -> bool:
        """Triggers export process through external Blender/Unreal pipelines."""
        await self.sdk.event.publish(
            "ImportRequested", {"path": source_path, "dest": destination_path}
        )
        return True

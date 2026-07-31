from core.contract import IAtlasSDK


class AssetService:
    """Service handling asset lifecycle commands inside Forge App."""

    def __init__(self, sdk: IAtlasSDK):
        self.sdk = sdk

    async def process_asset_creation(self, filename: str) -> None:
        """Mock processing of newly designed asset."""
        await self.sdk.memory.set_session_state("last_created_asset", filename)
        await self.sdk.event.publish("AssetCreated", {"path": f"projects/excelion/{filename}"})

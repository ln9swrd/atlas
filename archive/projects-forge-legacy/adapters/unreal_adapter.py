from core.contract import IAtlasSDK


class UnrealAdapter:
    """Interface Adapter encapsulating Unreal Engine Python actions without direct unreal module dependency."""

    def __init__(self, sdk: IAtlasSDK):
        self.sdk = sdk

    async def import_fbx(self, source_path: str, destination_path: str) -> bool:
        """Simulates Unreal Engine FBX import process."""
        await self.sdk.event.publish(
            "LogEmitted",
            {"message": f"Unreal Engine Fbx Imported smx: {source_path} ➔ {destination_path}"},
        )
        return True

    async def assign_material(self, asset_path: str, material_instance_path: str) -> bool:
        """Simulates Unreal Engine Material Instance assignment."""
        await self.sdk.event.publish(
            "LogEmitted",
            {
                "message": f"Unreal Material Instance Assigned: {material_instance_path} ➔ {asset_path}"
            },
        )
        return True

from core.contract import IAtlasSDK


class ValidationService:
    """Service triggering rule validation and scoring reviews inside Forge App."""

    def __init__(self, sdk: IAtlasSDK):
        self.sdk = sdk

    async def validate_asset(self, filepath: str, stage: str) -> bool:
        """Triggers validation against Rule Engine and generates Scorecard."""
        audit_res = await self.sdk.review.submit_artifact_for_audit(filepath, stage)
        is_passed = audit_res.get("status") == "PASS"

        # Emit validation events
        await self.sdk.event.publish(
            "ValidationCompleted",
            {
                "target_asset": filepath,
                "status": "PASS" if is_passed else "FAIL",
                "score": audit_res.get("score", 0),
            },
        )
        return is_passed

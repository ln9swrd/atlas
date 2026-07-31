from core.contract import IAtlasSDK


class ProjectService:
    """Service tracking project context, remaining time, and rule directives inside Forge App."""

    def __init__(self, sdk: IAtlasSDK):
        self.sdk = sdk

    async def get_project_context(self) -> dict:
        """Retrieves OS configurations and available budgets."""
        env_info = await self.sdk.resource.get_environment_info()
        time_left = await self.sdk.resource.get_remaining_budget()
        return {
            "environment": env_info.get("environment"),
            "constraints": env_info.get("constraints", []),
            "time_budget_remaining": time_left,
        }

from typing import Any, Dict, Optional
from core.contract import IApplication, IAtlasSDK
from projects.forge.services.asset_service import AssetService
from projects.forge.services.validation_service import ValidationService
from projects.forge.services.export_service import ExportService
from projects.forge.services.project_service import ProjectService
from projects.forge.adapters.blender_adapter import BlenderAdapter
from projects.forge.adapters.unreal_adapter import UnrealAdapter


class ForgeApplication(IApplication):
    """Forge application executing under Atlas 2.0 DevOS environment."""

    def __init__(self):
        self.sdk: Optional[IAtlasSDK] = None
        self.is_installed = False
        self.is_loaded = False
        self.status = "NONE"

        # Services & Adapters to be initialized with SDK dependency injection
        self.asset_service: Optional[AssetService] = None
        self.validation_service: Optional[ValidationService] = None
        self.export_service: Optional[ExportService] = None
        self.project_service: Optional[ProjectService] = None
        self.blender_adapter: Optional[BlenderAdapter] = None
        self.unreal_adapter: Optional[UnrealAdapter] = None

    async def on_install(self) -> bool:
        self.is_installed = True
        self.status = "INSTALLED"
        return True

    async def on_load(self) -> bool:
        self.is_loaded = True
        self.status = "LOADED"
        return True

    async def on_initialize(self, sdk: IAtlasSDK) -> bool:
        self.sdk = sdk

        # Inject SDK dependency into Services
        self.asset_service = AssetService(sdk)
        self.validation_service = ValidationService(sdk)
        self.export_service = ExportService(sdk)
        self.project_service = ProjectService(sdk)

        # Inject SDK dependency into Adapters
        self.blender_adapter = BlenderAdapter(sdk)
        self.unreal_adapter = UnrealAdapter(sdk)

        self.status = "INITIALIZED"
        return True

    async def on_execute(self, context: Dict[str, Any]) -> None:
        self.status = "EXECUTING"
        if not self.sdk:
            raise RuntimeError("SDK not injected. Cannot execute Forge Application.")

        # 1. Workflow validation: Get recommended task
        task = await self.sdk.workflow.get_recommended_task()
        if task:
            task_id = task.get("id")
            # Mark task status via Workflow API
            await self.sdk.workflow.mark_task_status(task_id, "IN_PROGRESS")

            # 2. AI Reasoning verification
            opinion = await self.sdk.ai.get_agent_opinion(
                "Forge", {"task_id": task_id, "stage": "modeling"}
            )
            await self.sdk.event.publish("LogEmitted", {"message": f"AI Opinion fetched: {opinion}"})

            # 3. Memory verification
            await self.sdk.memory.set_session_state("current_executing_task", task_id)

            # 4. Mocking Service Workflow integration
            # Asset load mock call
            await self.asset_service.process_asset_creation("SM_Brave_Arm.fbx")

            # Validate naming via SDK Knowledge
            naming_ok = await self.sdk.knowledge.validate_naming_rule("SM_Brave_Arm", "mesh")
            if naming_ok:
                await self.sdk.event.publish(
                    "AssetCreated", {"path": "projects/excelion/SM_Brave_Arm.fbx"}
                )

            # Finish task
            await self.sdk.workflow.mark_task_status(task_id, "DONE")

    async def on_suspend(self) -> bool:
        self.status = "SUSPENDED"
        return True

    async def on_resume(self) -> bool:
        self.status = "EXECUTING"
        return True

    async def on_unload(self) -> bool:
        self.status = "UNLOADED"
        return True

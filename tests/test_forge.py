import asyncio
import unittest
from core.sdk import AtlasSDK
from projects.forge.app import ForgeApplication


class TestForgeApplication(unittest.TestCase):
    """Unit tests for Forge Application Skeleton integration and SDK verification."""

    def test_forge_lifecycle_and_dependencies(self):
        """Test Forge Application lifecycle hooks and verification of dependency injection."""
        app = ForgeApplication()
        sdk = AtlasSDK.create_mock_sdk()

        async def run_lifecycle_test():
            # 1. on_install & on_load
            self.assertTrue(await app.on_install())
            self.assertEqual(app.status, "INSTALLED")

            self.assertTrue(await app.on_load())
            self.assertEqual(app.status, "LOADED")

            # 2. on_initialize with SDK Injection
            self.assertTrue(await app.on_initialize(sdk))
            self.assertEqual(app.status, "INITIALIZED")
            self.assertEqual(app.sdk, sdk)

            # Check if internal layers are successfully injected with the SDK reference
            self.assertIsNotNone(app.asset_service)
            self.assertEqual(app.asset_service.sdk, sdk)

            self.assertIsNotNone(app.blender_adapter)
            self.assertEqual(app.blender_adapter.sdk, sdk)

            self.assertIsNotNone(app.unreal_adapter)
            self.assertEqual(app.unreal_adapter.sdk, sdk)

            # 3. on_execute with mocked SDK interactions
            context = {"environment": "DEV_WORK"}
            await app.on_execute(context)
            self.assertEqual(app.status, "EXECUTING")

            # Verify Task status was updated in Workflow Service
            task_status = sdk.workflow.tasks["TASK-001"]["status"]
            self.assertEqual(task_status, "DONE")

            # Verify session state memory was saved
            session_task = await sdk.memory.get_session_state("current_executing_task")
            self.assertEqual(session_task, "TASK-001")

            last_processed = await sdk.memory.get_session_state("last_created_asset")
            self.assertEqual(last_processed, "SM_Brave_Arm.fbx")

            # Verify Events history contains publications
            events = sdk.event.events_history
            event_types = [e["event_type"] for e in events]
            self.assertIn("AssetCreated", event_types)
            self.assertIn("LogEmitted", event_types)

            # 4. Suspend, resume, and unload transitions
            self.assertTrue(await app.on_suspend())
            self.assertEqual(app.status, "SUSPENDED")

            self.assertTrue(await app.on_resume())
            self.assertEqual(app.status, "EXECUTING")

            self.assertTrue(await app.on_unload())
            self.assertEqual(app.status, "UNLOADED")

        asyncio.run(run_lifecycle_test())

    def test_forge_adapters_and_services(self):
        """Test services and adapters inside Forge independently with the Mock SDK."""
        app = ForgeApplication()
        sdk = AtlasSDK.create_mock_sdk()

        async def run_adapter_tests():
            await app.on_initialize(sdk)

            # Test Blender Adapter
            uv_pass = await app.blender_adapter.execute_uv_check("SM_Brave_Leg.fbx")
            collision_pass = await app.blender_adapter.execute_collision_check("SM_Brave_Leg.fbx")
            self.assertTrue(uv_pass)
            self.assertTrue(collision_pass)

            # Test Unreal Adapter
            import_ok = await app.unreal_adapter.import_fbx(
                "SM_Brave_Leg.fbx", "/Game/Exelion/Brave"
            )
            self.assertTrue(import_ok)

            # Test Validation Service triggers and publishes Event
            validation_ok = await app.validation_service.validate_asset(
                "SM_Brave_Leg.fbx", "Blender - Modeling"
            )
            self.assertTrue(validation_ok)

            # Inspect validation completed event
            events = sdk.event.events_history
            val_event = next(e for e in events if e["event_type"] == "ValidationCompleted")
            self.assertEqual(val_event["payload"]["target_asset"], "SM_Brave_Leg.fbx")
            self.assertEqual(val_event["payload"]["status"], "PASS")

            # Test Project Service context retrieval
            ctx = await app.project_service.get_project_context()
            self.assertEqual(ctx["environment"], "DEV_WORK")
            self.assertEqual(ctx["time_budget_remaining"], 180)

        asyncio.run(run_adapter_tests())


if __name__ == "__main__":
    unittest.main()

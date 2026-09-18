import asyncio
import unittest
from core.contract import (
    IApplication,
    IAtlasSDK,
    IEventBus,
    IAIService,
    IMemoryService,
    IKnowledgeService,
    IWorkflowService,
    IResourceService,
    IReviewService,
)
from core.sdk import AtlasSDK


class DummyApp(IApplication):
    """A minimal mock application to verify SDK injection and lifecycle hook execution."""

    def __init__(self):
        self.initialized = False
        self.sdk_ref: IAtlasSDK = None
        self.executed = False
        self.payload_received = {}

    async def on_install(self) -> bool:
        return True

    async def on_load(self) -> bool:
        return True

    async def on_initialize(self, sdk: IAtlasSDK) -> bool:
        self.initialized = True
        self.sdk_ref = sdk
        return True

    async def on_execute(self, context: dict) -> None:
        self.executed = True
        self.payload_received = context

    async def on_suspend(self) -> bool:
        return True

    async def on_resume(self) -> bool:
        return True

    async def on_unload(self) -> bool:
        return True


class TestContracts(unittest.TestCase):
    """Unit tests using unittest framework to avoid external pytest dependency."""

    def test_sdk_facade_integrity(self):
        """Verify that AtlasSDK implements IAtlasSDK and has proper concrete properties."""
        sdk = AtlasSDK.create_mock_sdk()
        self.assertTrue(isinstance(sdk, IAtlasSDK))
        self.assertTrue(isinstance(sdk.event, IEventBus))
        self.assertTrue(isinstance(sdk.ai, IAIService))
        self.assertTrue(isinstance(sdk.memory, IMemoryService))
        self.assertTrue(isinstance(sdk.knowledge, IKnowledgeService))
        self.assertTrue(isinstance(sdk.workflow, IWorkflowService))
        self.assertTrue(isinstance(sdk.resource, IResourceService))
        self.assertTrue(isinstance(sdk.review, IReviewService))

    def test_mock_services_behavior(self):
        """Verify functional behaviors of the In-Memory mock services inside the SDK."""
        sdk = AtlasSDK.create_mock_sdk()

        async def run_async_tests():
            # 1. Event Bus subscription and publishing check
            events_received = []

            def callback(payload):
                events_received.append(payload)

            sub_id = await sdk.event.subscribe("AssetCreated", callback)
            self.assertTrue(sub_id.startswith("sub_AssetCreated_"))

            await sdk.event.publish("AssetCreated", {"path": "test_mesh.fbx"})
            self.assertEqual(len(events_received), 1)
            self.assertEqual(events_received[0]["path"], "test_mesh.fbx")

            # 2. Memory Service ADR operations check
            adr_created = await sdk.memory.create_adr(
                "ADR-100", "Adopt SDK", "Need standard contract", "Accepted standard contracts"
            )
            self.assertTrue(adr_created)
            adr = await sdk.memory.get_adr("ADR-100")
            self.assertIsNotNone(adr)
            self.assertEqual(adr["title"], "Adopt SDK")
            self.assertEqual(adr["status"], "Accepted")

            # 3. Knowledge Service best practices query
            practices = await sdk.knowledge.query_best_practice("Blender - Modeling")
            self.assertIn("Mirror -> Bevel -> Weighted Normal", practices)

            # 4. Workflow task recommended check
            task = await sdk.workflow.get_recommended_task()
            self.assertIsNotNone(task)
            self.assertEqual(task["id"], "TASK-001")
            self.assertEqual(task["status"], "TODO")

            # 5. Resource environment capabilities query
            env = await sdk.resource.get_environment_info()
            self.assertEqual(env["environment"], "DEV_WORK")
            self.assertIn("no_unreal", env["constraints"])

            # 6. AI structured reasoning check
            schema = {
                "type": "object",
                "properties": {
                    "decision": {"type": "string"},
                    "confidence": {"type": "integer"},
                    "passed": {"type": "boolean"},
                },
            }
            reasoning = await sdk.ai.request_reasoning("Test reasoning prompt", schema)
            self.assertEqual(reasoning["decision"], "mocked_string_val")
            self.assertEqual(reasoning["confidence"], 42)
            self.assertTrue(reasoning["passed"])

        asyncio.run(run_async_tests())

    def test_application_lifecycle(self):
        """Verify that a custom IApplication class can be initialized and executed with AtlasSDK."""
        app = DummyApp()
        sdk = AtlasSDK.create_mock_sdk()

        async def run_lifecycle_test():
            # Simulate OS kernel launching application lifecycle hooks
            installed = await app.on_install()
            loaded = await app.on_load()
            self.assertTrue(installed)
            self.assertTrue(loaded)

            initialized = await app.on_initialize(sdk)
            self.assertTrue(initialized)
            self.assertTrue(app.initialized)
            self.assertEqual(app.sdk_ref, sdk)

            context = {"environment": "DEV_WORK", "task_id": "EX-BRAVE-001"}
            await app.on_execute(context)
            self.assertTrue(app.executed)
            self.assertEqual(app.payload_received["task_id"], "EX-BRAVE-001")

            suspended = await app.on_suspend()
            resumed = await app.on_resume()
            unloaded = await app.on_unload()
            self.assertTrue(suspended)
            self.assertTrue(resumed)
            self.assertTrue(unloaded)

        asyncio.run(run_lifecycle_test())


if __name__ == "__main__":
    unittest.main()

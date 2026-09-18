import unittest

from core.taskbroker.task_models import TaskStatus
from core.taskbroker.task_registry import TaskRegistry


class TaskRegistryTests(unittest.TestCase):
    def test_create_and_update_task(self):
        registry = TaskRegistry()
        task = registry.create_task("Implement broker", "Create MVP broker", "cline")
        self.assertEqual(task.status, TaskStatus.PENDING)
        registry.update_status(task.task_id, TaskStatus.RUNNING)
        self.assertEqual(registry.get_task(task.task_id).status, TaskStatus.RUNNING)

    def test_delete_task(self):
        registry = TaskRegistry()
        task = registry.create_task("Delete me", "Remove task", "cline")
        self.assertTrue(registry.delete_task(task.task_id))
        self.assertIsNone(registry.get_task(task.task_id))


if __name__ == "__main__":
    unittest.main()

import asyncio
import os
import tempfile
import unittest

from core.event_bus import AtlasEventBus
from core.taskbroker.task_broker import TaskBroker


class TaskBrokerTests(unittest.TestCase):
    def test_create_and_complete_task(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            history_path = os.path.join(tmpdir, "task_history.jsonl")
            broker = TaskBroker(event_bus=AtlasEventBus(), history_path=history_path)

            async def _run():
                task = await broker.create_task("Broker task", "Run broker workflow", "cline", priority=5)
                started = await broker.start_next()
                completed = await broker.complete_task(task.task_id, {"status": "ok"})
                return task, started, completed

            task, started, completed = asyncio.run(_run())
            self.assertEqual(task.task_id, started.task_id)
            self.assertEqual(completed.status, "COMPLETED")
            self.assertTrue(os.path.exists(history_path))


if __name__ == "__main__":
    unittest.main()

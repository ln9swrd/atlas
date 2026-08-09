import unittest

from core.taskbroker.task_models import Task
from core.taskbroker.task_queue import TaskQueue


class TaskQueueTests(unittest.TestCase):
    def test_enqueue_dequeue_and_peek(self):
        queue = TaskQueue()
        low = Task(title="Low", description="", target_agent="cline", priority=1)
        high = Task(title="High", description="", target_agent="cline", priority=9)
        queue.enqueue(low)
        queue.enqueue(high)
        self.assertEqual(queue.peek().task_id, high.task_id)
        self.assertEqual(queue.dequeue().task_id, high.task_id)
        self.assertEqual(queue.dequeue().task_id, low.task_id)

    def test_cancel_and_retry(self):
        queue = TaskQueue()
        task = Task(title="Retry", description="", target_agent="cline", priority=3)
        queue.enqueue(task)
        self.assertTrue(queue.cancel(task.task_id))
        self.assertIsNone(queue.peek())


if __name__ == "__main__":
    unittest.main()

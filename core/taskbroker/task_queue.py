from __future__ import annotations

from heapq import heappop, heappush
from typing import List, Optional

from .task_models import Task


class TaskQueue:
    def __init__(self) -> None:
        self._heap: List[tuple[int, int, str, Task]] = []
        self._counter = 0

    def enqueue(self, task: Task) -> None:
        self._counter += 1
        heappush(self._heap, (-task.priority, self._counter, task.task_id, task))

    def dequeue(self) -> Optional[Task]:
        if not self._heap:
            return None
        _, _, _, task = heappop(self._heap)
        return task

    def peek(self) -> Optional[Task]:
        if not self._heap:
            return None
        _, _, _, task = self._heap[0]
        return task

    def cancel(self, task_id: str) -> bool:
        for idx, item in enumerate(self._heap):
            if item[2] == task_id:
                del self._heap[idx]
                return True
        return False

    def retry(self, task_id: str) -> bool:
        return self.cancel(task_id)

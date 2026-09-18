from __future__ import annotations

from typing import Dict, List, Optional

from .task_models import Task, TaskStatus


class TaskRegistry:
    def __init__(self) -> None:
        self._tasks: Dict[str, Task] = {}

    def create_task(self, title: str, description: str, target_agent: str, priority: int = 0, metadata: Optional[dict] = None) -> Task:
        task = Task(title=title, description=description, target_agent=target_agent, priority=priority, metadata=metadata or {})
        self._tasks[task.task_id] = task
        return task

    def get_task(self, task_id: str) -> Optional[Task]:
        return self._tasks.get(task_id)

    def list_tasks(self) -> List[Task]:
        return list(self._tasks.values())

    def update_status(self, task_id: str, status: str) -> Optional[Task]:
        task = self._tasks.get(task_id)
        if task is None:
            return None
        task.status = status
        return task

    def delete_task(self, task_id: str) -> bool:
        if task_id in self._tasks:
            del self._tasks[task_id]
            return True
        return False

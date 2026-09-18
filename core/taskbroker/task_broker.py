from __future__ import annotations

import json
import os
from datetime import datetime
from typing import Any, Dict, Optional

from core.decision.decision_engine import DecisionContext, DecisionEngine, DecisionRequest, RuleDecisionStrategy
from core.event_bus import AtlasEventBus

from .task_models import Task, TaskStatus
from .task_queue import TaskQueue
from .task_registry import TaskRegistry


class TaskBroker:
    def __init__(self, event_bus: Optional[AtlasEventBus] = None, registry: Optional[TaskRegistry] = None, queue: Optional[TaskQueue] = None, history_path: Optional[str] = None) -> None:
        self.event_bus = event_bus or AtlasEventBus()
        self.registry = registry or TaskRegistry()
        self.queue = queue or TaskQueue()
        self.history_path = history_path or os.path.join(os.getcwd(), "logs", "task_history.jsonl")
        self.decision_engine = DecisionEngine(strategy=RuleDecisionStrategy())
        os.makedirs(os.path.dirname(self.history_path), exist_ok=True)

    async def create_task(self, title: str, description: str, target_agent: str, priority: int = 0, metadata: Optional[Dict[str, Any]] = None) -> Task:
        task = self.registry.create_task(title, description, target_agent, priority=priority, metadata=metadata or {})
        await self.event_bus.publish("task.created", {"task_id": task.task_id, "title": task.title, "target_agent": task.target_agent})
        self._record_history(task, "task.created")
        decision_request = DecisionRequest(
            request_id=task.task_id,
            context=DecisionContext(environment="DEV_HOME", project="Exelion", goals=[task.title], constraints=[], capabilities=[], resources={}, time={}),
            goals=[task.title],
            constraints=[],
            knowledge=[description],
            strategies=["rule"],
            preferred_strategy="rule",
        )
        decision_result = self.decision_engine.make_decision(decision_request)
        task.metadata.setdefault("decision", {
            "priority": decision_result.priority,
            "recommended_agent": target_agent,
            "reason": decision_result.reason,
        })
        self._record_history(task, "decision.recorded")
        self.queue.enqueue(task)
        await self.event_bus.publish("task.queued", {"task_id": task.task_id, "priority": task.priority})
        self._record_history(task, "task.queued")
        return task

    async def start_next(self) -> Optional[Task]:
        task = self.queue.dequeue()
        if task is None:
            return None
        task.status = TaskStatus.RUNNING
        task.started_at = datetime.now()
        self.registry.update_status(task.task_id, task.status)
        await self.event_bus.publish("task.started", {"task_id": task.task_id})
        self._record_history(task, "task.started")
        return task

    async def complete_task(self, task_id: str, result: Optional[Dict[str, Any]] = None) -> Optional[Task]:
        task = self.registry.get_task(task_id)
        if task is None:
            return None
        task.status = TaskStatus.COMPLETED
        task.finished_at = datetime.now()
        task.result = result or {}
        self.registry.update_status(task.task_id, task.status)
        await self.event_bus.publish("task.completed", {"task_id": task.task_id, "result": task.result})
        self._record_history(task, "task.completed")
        return task

    async def fail_task(self, task_id: str, reason: str) -> Optional[Task]:
        task = self.registry.get_task(task_id)
        if task is None:
            return None
        task.status = TaskStatus.FAILED
        task.finished_at = datetime.now()
        task.result = {"error": reason}
        self.registry.update_status(task.task_id, task.status)
        await self.event_bus.publish("task.failed", {"task_id": task.task_id, "reason": reason})
        self._record_history(task, "task.failed")
        return task

    def _record_history(self, task: Task, event: str) -> None:
        payload = {
            "event": event,
            "task": task.to_dict(),
            "timestamp": datetime.now().isoformat(timespec="seconds"),
        }
        with open(self.history_path, "a", encoding="utf-8") as handle:
            handle.write(json.dumps(payload, ensure_ascii=False) + "\n")

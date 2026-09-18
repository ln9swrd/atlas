from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import uuid4


class TaskStatus:
    PENDING = "PENDING"
    READY = "READY"
    RUNNING = "RUNNING"
    BLOCKED = "BLOCKED"
    FAILED = "FAILED"
    COMPLETED = "COMPLETED"


@dataclass
class Task:
    title: str
    description: str
    target_agent: str
    priority: int = 0
    status: str = TaskStatus.PENDING
    task_id: str = field(default_factory=lambda: str(uuid4()))
    created_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
    dependencies: List[str] = field(default_factory=list)
    artifacts: List[str] = field(default_factory=list)
    result: Optional[Dict[str, Any]] = None
    metadata: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "task_id": self.task_id,
            "title": self.title,
            "description": self.description,
            "target_agent": self.target_agent,
            "priority": self.priority,
            "status": self.status,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "finished_at": self.finished_at.isoformat() if self.finished_at else None,
            "dependencies": list(self.dependencies),
            "artifacts": list(self.artifacts),
            "result": self.result,
            "metadata": dict(self.metadata),
        }

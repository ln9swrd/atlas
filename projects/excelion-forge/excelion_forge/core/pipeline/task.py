"""Task execution system for Excelion Forge pipelines."""

from __future__ import annotations

from abc import ABC
from abc import abstractmethod
from dataclasses import dataclass
from dataclasses import field
from enum import Enum
from typing import Any
from typing import Callable
from typing import Optional

from .context import PipelineContext
from .error import PipelineError


class TaskStatus(Enum):
    """Status of a pipeline task."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    SKIPPED = "skipped"


@dataclass
class TaskResult:
    """Result of a task execution.

    Attributes:
        task_id: Unique identifier of the task
        status: Final status of the task
        success: Whether the task succeeded
        result: Result data from the task
        error: Error if task failed
        duration: Execution duration in seconds
        metadata: Additional result metadata
    """
    task_id: str
    status: TaskStatus
    success: bool
    result: Any = None
    error: Optional[PipelineError] = None
    duration: float = 0.0
    metadata: dict[str, Any] = field(default_factory=dict)


class Task(ABC):
    """Base class for pipeline tasks.

    Subclasses must implement the execute method.
    Provides common functionality for all pipeline tasks.

    Attributes:
        task_id: Unique identifier for this task
        name: Human-readable name
        dependencies: IDs of tasks this depends on
        context: Shared execution context
    """

    def __init__(
        self,
        task_id: str,
        name: Optional[str] = None,
        dependencies: Optional[list[str]] = None,
    ) -> None:
        self.task_id = task_id
        self.name = name or task_id
        self.dependencies = dependencies or []
        self._status = TaskStatus.PENDING
        self._result: Optional[TaskResult] = None

    @property
    def status(self) -> TaskStatus:
        """Current task status."""
        return self._status

    @property
    def result(self) -> Optional[TaskResult]:
        """Task execution result."""
        return self._result

    @abstractmethod
    def execute(self, context: PipelineContext) -> Any:
        """Execute the task.

        Args:
            context: Shared pipeline context

        Returns:
            Task result data

        Raises:
            PipelineError: If task execution fails
        """
        pass

    def run(self, context: PipelineContext) -> TaskResult:
        """Run the task with result tracking.

        Args:
            context: Shared pipeline context

        Returns:
            Task execution result
        """
        import time

        start_time = time.time()
        self._status = TaskStatus.RUNNING

        try:
            result_data = self.execute(context)
            self._status = TaskStatus.COMPLETED
            
            self._result = TaskResult(
                task_id=self.task_id,
                status=self._status,
                success=True,
                result=result_data,
                duration=time.time() - start_time,
            )
            return self._result

        except PipelineError as e:
            self._status = TaskStatus.FAILED
            self._result = TaskResult(
                task_id=self.task_id,
                status=self._status,
                success=False,
                error=e,
                duration=time.time() - start_time,
            )
            return self._result

        except Exception as e:
            self._status = TaskStatus.FAILED
            error = PipelineError(
                message=f"Unexpected error: {str(e)}",
                details={"exception_type": type(e).__name__},
            )
            self._result = TaskResult(
                task_id=self.task_id,
                status=self._status,
                success=False,
                error=error,
                duration=time.time() - start_time,
            )
            return self._result

    def cancel(self) -> None:
        """Mark the task as cancelled."""
        if self._status in (TaskStatus.PENDING, TaskStatus.RUNNING):
            self._status = TaskStatus.CANCELLED

    def skip(self) -> None:
        """Mark the task as skipped."""
        if self._status == TaskStatus.PENDING:
            self._status = TaskStatus.SKIPPED


class FunctionTask(Task):
    """Task that wraps a simple function execution.

    Allows using plain functions to be used as pipeline tasks
    without subclassing.
    """

    def __init__(
        self,
        task_id: str,
        func: Callable[[PipelineContext], Any],
        name: Optional[str] = None,
        dependencies: Optional[list[str]] = None,
    ) -> None:
        super().__init__(task_id, name, dependencies)
        self.func = func

    def execute(self, context: PipelineContext) -> Any:
        """Execute the wrapped function.

        Args:
            context: Pipeline context

        Returns:
            Function result
        """
        return self.func(context)

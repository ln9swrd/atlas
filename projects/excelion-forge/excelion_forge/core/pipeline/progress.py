"""Progress reporting system for Excelion Forge pipelines."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any
from typing import Callable
from typing import Optional


class ProgressStatus(Enum):
    """Status of a progress trackable operation."""
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


@dataclass
class ProgressUpdate:
    """Represents a progress update event.

    Attributes:
        task_id: Unique identifier for the task
        status: Current status
        progress: Progress value (0.0 to 1.0)
        message: Human-readable progress message
        metadata: Additional update metadata
    """
    task_id: str
    status: ProgressStatus
    progress: float = 0.0
    message: str = ""
    metadata: Optional[dict[str, Any]] = None

    def __post_init__(self) -> None:
        if self.metadata is None:
            self.metadata = {}


class ProgressManager:
    """Manages progress reporting for pipeline operations.

    Tracks task progress, notifies listeners, and provides
    cancellation support. Can integrate with Blender's wm.progress API.
    """

    def __init__(self) -> None:
        self._tasks: dict[str, ProgressUpdate] = {}
        self._callbacks: list[Callable[[ProgressUpdate], None]] = []
        self._cancelled_tasks: set[str] = set()
        self._blender_context: Optional[Any] = None
        self._runtime: Optional[Any] = None

    def set_blender_context(self, context: Any) -> None:
        """Set Blender context for wm.progress integration.

        Args:
            context: Blender context (bpy.types.Context)
        """
        self._blender_context = context

    def set_runtime(self, runtime: Any) -> None:
        """Set a runtime adapter implementing the runtime protocol.

        The manager will attempt to derive a Blender context/window_manager
        from the runtime when available. This keeps direct `bpy` access
        contained in adapter implementations.
        """
        self._runtime = runtime

    def register_callback(
        self,
        callback: Callable[[ProgressUpdate], None],
    ) -> None:
        """Register a callback to receive progress updates.

        Args:
            callback: Function that receives ProgressUpdate
        """
        if callback not in self._callbacks:
            self._callbacks.append(callback)

    def unregister_callback(
        self,
        callback: Callable[[ProgressUpdate], None],
    ) -> None:
        """Unregister a previously added callback.

        Args:
            callback: Callback to remove
        """
        if callback in self._callbacks:
            self._callbacks.remove(callback)

    def start_task(
        self,
        task_id: str,
        message: str = "Starting task...",
        metadata: Optional[dict[str, Any]] = None,
    ) -> None:
        """Mark a task as started.

        Args:
            task_id: Unique task identifier
            message: Initial progress message
            metadata: Additional metadata
        """
        update = ProgressUpdate(
            task_id=task_id,
            status=ProgressStatus.IN_PROGRESS,
            progress=0.0,
            message=message,
            metadata=metadata or {},
        )
        self._tasks[task_id] = update
        
        # Blender progress integration
        wm = None
        if self._runtime is not None:
            try:
                scene = getattr(self._runtime, "get_scene")()
                wm = getattr(scene, "window_manager", None)
            except Exception:
                wm = None
        if wm is None and self._blender_context:
            try:
                wm = self._blender_context.window_manager
            except Exception:
                wm = None
        if wm:
            try:
                wm.progress_begin(0, 100)
            except Exception:
                pass
        
        self._notify(update)

    def update_progress(
        self,
        task_id: str,
        progress: float,
        message: str = "",
        metadata: Optional[dict[str, Any]] = None,
    ) -> None:
        """Update progress for a task.

        Args:
            task_id: Task identifier
            progress: Progress value (0.0 to 1.0)
            message: Progress message
            metadata: Additional metadata
        """
        if task_id not in self._tasks:
            self.start_task(task_id, message, metadata)
            return

        if self.is_cancelled(task_id):
            return

        current = self._tasks[task_id]
        update = ProgressUpdate(
            task_id=task_id,
            status=ProgressStatus.IN_PROGRESS,
            progress=max(0.0, min(1.0, progress)),
            message=message or current.message,
            metadata=metadata or current.metadata,
        )
        self._tasks[task_id] = update
        
        # Blender progress integration
        wm = None
        if self._runtime is not None:
            try:
                scene = getattr(self._runtime, "get_scene")()
                wm = getattr(scene, "window_manager", None)
            except Exception:
                wm = None
        if wm is None and self._blender_context:
            try:
                wm = self._blender_context.window_manager
            except Exception:
                wm = None
        if wm:
            try:
                wm.progress_update(int(update.progress * 100))
            except Exception:
                pass
        
        self._notify(update)

    def complete_task(
        self,
        task_id: str,
        message: str = "Task completed",
        metadata: Optional[dict[str, Any]] = None,
    ) -> None:
        """Mark a task as completed.

        Args:
            task_id: Task identifier
            message: Completion message
            metadata: Additional metadata
        """
        if task_id not in self._tasks:
            self.start_task(task_id, message, metadata)

        update = ProgressUpdate(
            task_id=task_id,
            status=ProgressStatus.COMPLETED,
            progress=1.0,
            message=message,
            metadata=metadata or {},
        )
        self._tasks[task_id] = update
        
        # Blender progress integration
        wm = None
        if self._runtime is not None:
            try:
                scene = getattr(self._runtime, "get_scene")()
                wm = getattr(scene, "window_manager", None)
            except Exception:
                wm = None
        if wm is None and self._blender_context:
            try:
                wm = self._blender_context.window_manager
            except Exception:
                wm = None
        if wm:
            try:
                wm.progress_update(100)
                wm.progress_end()
            except Exception:
                pass
        
        self._notify(update)

    def fail_task(
        self,
        task_id: str,
        message: str = "Task failed",
        metadata: Optional[dict[str, Any]] = None,
    ) -> None:
        """Mark a task as failed.

        Args:
            task_id: Task identifier
            message: Failure message
            metadata: Additional metadata
        """
        if task_id not in self._tasks:
            self.start_task(task_id, message, metadata)

        current = self._tasks[task_id]
        update = ProgressUpdate(
            task_id=task_id,
            status=ProgressStatus.FAILED,
            progress=current.progress,
            message=message,
            metadata=metadata or current.metadata,
        )
        self._tasks[task_id] = update
        
        # Blender progress integration
        wm = None
        if self._runtime is not None:
            try:
                scene = getattr(self._runtime, "get_scene")()
                wm = getattr(scene, "window_manager", None)
            except Exception:
                wm = None
        if wm is None and self._blender_context:
            try:
                wm = self._blender_context.window_manager
            except Exception:
                wm = None
        if wm:
            try:
                wm.progress_end()
            except Exception:
                pass
        
        self._notify(update)

    def cancel_task(self, task_id: str) -> None:
        """Request cancellation of a task.

        Args:
            task_id: Task to cancel
        """
        self._cancelled_tasks.add(task_id)
        
        if task_id in self._tasks:
            current = self._tasks[task_id]
            update = ProgressUpdate(
                task_id=task_id,
                status=ProgressStatus.CANCELLED,
                progress=current.progress,
                message="Task cancelled",
                metadata=current.metadata,
            )
            self._tasks[task_id] = update
            
            # Blender progress integration
            if self._blender_context:
                try:
                    wm = self._blender_context.window_manager
                    wm.progress_end()
                except Exception:
                    pass
            
            self._notify(update)

    def is_cancelled(self, task_id: str) -> bool:
        """Check if a task has been cancelled.

        Args:
            task_id: Task to check

        Returns:
            True if task is cancelled
        """
        return task_id in self._cancelled_tasks

    def get_progress(self, task_id: str) -> Optional[ProgressUpdate]:
        """Get current progress for a task.

        Args:
            task_id: Task to check

        Returns:
            Progress update or None if not found
        """
        return self._tasks.get(task_id)

    def get_all_progress(self) -> dict[str, ProgressUpdate]:
        """Get progress for all tracked tasks.

        Returns:
            Dictionary of task ID to progress update
        """
        return self._tasks.copy()

    def clear_task(self, task_id: str) -> None:
        """Clear tracking for a specific task.

        Args:
            task_id: Task to clear
        """
        self._tasks.pop(task_id, None)
        self._cancelled_tasks.discard(task_id)

    def clear_all(self) -> None:
        """Clear all tracked tasks."""
        self._tasks.clear()
        self._cancelled_tasks.clear()

    def _notify(self, update: ProgressUpdate) -> None:
        """Notify all registered callbacks.

        Args:
            update: Progress update to send
        """
        for callback in self._callbacks:
            callback(update)

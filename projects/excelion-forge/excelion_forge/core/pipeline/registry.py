"""Pipeline registry for managing and executing task sequences."""

from __future__ import annotations

from dataclasses import dataclass
from dataclasses import field
from typing import Any
from typing import Dict
from typing import List
from typing import Optional
from typing import Set

from .context import PipelineContext
from .error import ErrorHandler
from .error import PipelineError
from .logger import Logger
from .progress import ProgressManager
from .task import Task
from .task import TaskResult
from .task import TaskStatus


@dataclass
class Pipeline:
    """A collection of tasks that can be executed as a unit.

    Manages task dependencies and execution order.

    Attributes:
        pipeline_id: Unique pipeline identifier
        name: Human-readable name
        tasks: Tasks in this pipeline
        context: Shared execution context
    """
    pipeline_id: str
    name: str
    tasks: List[Task] = field(default_factory=list)
    context: PipelineContext = field(default_factory=PipelineContext)

    def add_task(self, task: Task) -> None:
        """Add a task to the pipeline.

        Args:
            task: Task to add
        """
        self.tasks.append(task)

    def get_task(self, task_id: str) -> Optional[Task]:
        """Get a task by ID.

        Args:
            task_id: Task identifier

        Returns:
            Task or None if not found
        """
        for task in self.tasks:
            if task.task_id == task_id:
                return task
        return None

    def get_execution_order(self) -> List[Task]:
        """Get tasks in dependency-resolved execution order.

        Returns:
            Tasks ordered by dependencies

        Raises:
            PipelineError: If circular dependency detected
        """
        visited: Set[str] = set()
        temp: Set[str] = set()
        order: List[Task] = []

        def visit(task: Task) -> None:
            if task.task_id in temp:
                raise PipelineError(
                message=f"Circular dependency detected involving {task.task_id}",
            )
            if task.task_id in visited:
                return

            temp.add(task.task_id)
            
            for dep_id in task.dependencies:
                dep_task = self.get_task(dep_id)
                if dep_task:
                    visit(dep_task)

            temp.remove(task.task_id)
            visited.add(task.task_id)
            order.append(task)

        for task in self.tasks:
            if task.task_id not in visited:
                visit(task)

        return order


class PipelineRegistry:
    """Registry for managing multiple pipelines.

    Provides pipeline registration, retrieval, and execution.
    Integrates with progress, logging, and error handling.
    """

    def __init__(
        self,
        logger: Optional[Logger] = None,
        progress: Optional[ProgressManager] = None,
        error_handler: Optional[ErrorHandler] = None,
    ) -> None:
        self._pipelines: Dict[str, Pipeline] = {}
        self.logger = logger or Logger()
        self.progress = progress or ProgressManager()
        self.error_handler = error_handler or ErrorHandler()

    def register(self, pipeline: Pipeline) -> None:
        """Register a pipeline.

        Args:
            pipeline: Pipeline to register
        """
        self._pipelines[pipeline.pipeline_id] = pipeline
        self.logger.info(f"Registered pipeline: {pipeline.name}")

    def unregister(self, pipeline_id: str) -> None:
        """Unregister a pipeline.

        Args:
            pipeline_id: Pipeline to unregister
        """
        if pipeline_id in self._pipelines:
            del self._pipelines[pipeline_id]
            self.logger.info(f"Unregistered pipeline: {pipeline_id}")

    def get(self, pipeline_id: str) -> Optional[Pipeline]:
        """Get a registered pipeline.

        Args:
            pipeline_id: Pipeline identifier

        Returns:
            Pipeline or None if not found
        """
        return self._pipelines.get(pipeline_id)

    def list_pipelines(self) -> List[Pipeline]:
        """List all registered pipelines.

        Returns:
            List of registered pipelines
        """
        return list(self._pipelines.values())

    def execute_pipeline(
        self,
        pipeline_id: str,
        context: Optional[PipelineContext] = None,
    ) -> Dict[str, TaskResult]:
        """Execute a registered pipeline.

        Args:
            pipeline_id: Pipeline to execute
            context: Optional context to use

        Returns:
            Dictionary of task ID to result

        Raises:
            PipelineError: If pipeline not found
        """
        pipeline = self.get(pipeline_id)
        if not pipeline:
            raise PipelineError(f"Pipeline not found: {pipeline_id}")

        exec_context = context or pipeline.context.clone()
        results: Dict[str, TaskResult] = {}

        self.logger.info(f"Starting pipeline: {pipeline.name}")
        self.progress.start_task(pipeline_id, f"Executing {pipeline.name}")

        try:
            tasks = pipeline.get_execution_order()
            total_tasks = len(tasks)

            for i, task in enumerate(tasks):
                if self.progress.is_cancelled(pipeline_id):
                    task.cancel()
                    continue

                self.progress.update_progress(
                    pipeline_id,
                    (i + 1) / total_tasks,
                    f"Running: {task.name}",
                )

                result = task.run(exec_context)
                results[task.task_id] = result

                if not result.success and result.error:
                    self.error_handler.handle_error(
                        result.error,
                        {"task_id": task.task_id, "pipeline_id": pipeline_id},
                    )
                    self.logger.error(
                        f"Task {task.name} failed: {result.error.message}",
                    )

            self.progress.complete_task(
                pipeline_id,
                f"Completed {pipeline.name}",
            )
            self.logger.info(f"Pipeline completed: {pipeline.name}")

        except PipelineError as e:
            self.progress.fail_task(
                pipeline_id,
                f"Pipeline failed: {e.message}",
            )
            self.error_handler.handle_error(e, {"pipeline_id": pipeline_id})
            raise

        except Exception as e:
            error = PipelineError(
                f"Pipeline execution failed: {str(e)}",
                details={"pipeline_id": pipeline_id},
            )
            self.progress.fail_task(
                pipeline_id,
                f"Pipeline failed: {error.message}",
            )
            self.error_handler.handle_error(error, {"pipeline_id": pipeline_id})
            raise

        return results

    def cancel_pipeline(self, pipeline_id: str) -> None:
        """Cancel a running pipeline.

        Args:
            pipeline_id: Pipeline to cancel
        """
        self.progress.cancel_task(pipeline_id)
        self.logger.info(f"Cancelled pipeline: {pipeline_id}")

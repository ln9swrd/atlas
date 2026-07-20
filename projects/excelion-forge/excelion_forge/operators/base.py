"""Base operator classes for Excelion Forge Blender operators."""

from __future__ import annotations

from typing import Any
from typing import Optional
from typing import Set

import bpy  # type: ignore

from excelion_forge.core.pipeline import Logger
from excelion_forge.core.pipeline import PipelineContext
from excelion_forge.core.pipeline import ProgressManager


class BaseOperator(bpy.types.Operator):
    """Base class for all Excelion Forge operators.

    Provides common functionality like logging, error handling,
    and undo support, and pipeline integration.

    Attributes:
        logger: Central logger instance
        progress: Progress manager instance
        context: Pipeline context for this operation
    """

    bl_options: Set[str] = {"REGISTER"}

    @property
    def logger(self) -> Logger:
        """Get the logger instance (lazy initialized)."""
        if not hasattr(self, "_logger"):
            self._logger = Logger()
        return self._logger

    @property
    def progress(self) -> ProgressManager:
        """Get the progress manager instance (lazy initialized)."""
        if not hasattr(self, "_progress"):
            self._progress = ProgressManager()
        return self._progress

    @property
    def pipeline_context(self) -> PipelineContext:
        """Get or create the pipeline context for this operation."""
        if not hasattr(self, "_pipeline_context"):
            self._pipeline_context = PipelineContext()
        return self._pipeline_context

    @classmethod
    def poll(cls, context: bpy.types.Context) -> bool:
        """Check if the operator can run in the current context.

        Args:
            context: Blender context

        Returns:
            True if operator can execute
        """
        return context is not None

    def execute(self, context: bpy.types.Context) -> Set[str]:
        """Execute the operator logic.

        Subclasses should override this method.

        Args:
            context: Blender context

        Returns:
            Operator result set
        """
        # Set Blender context for progress manager
        self.progress.set_blender_context(context)
        self.logger.warning("BaseOperator.execute() called - override in subclass!")
        return {"FINISHED"}

    def invoke(
        self,
        context: bpy.types.Context,
        event: Any,
    ) -> Set[str]:
        """Invoked by Blender when operator is called interactively.

        Default implementation just calls execute.

        Args:
            context: Blender context
            event: Blender event

        Returns:
            Operator result set
        """
        # Set Blender context for progress manager
        self.progress.set_blender_context(context)
        return self.execute(context)

    def report_info(self, type: Set[str], message: str) -> None:
        """Report a message to Blender and log it.

        Args:
            type: Blender report type set
            message: Message to report
        """
        super().report(type, message)
        
        if "ERROR" in type:
            self.logger.error(message)
        elif "WARNING" in type:
            self.logger.warning(message)
        elif "INFO" in type:
            self.logger.info(message)


class UndoOperator(BaseOperator):
    """Base operator with built-in undo support.

    Automatically includes UNDO in bl_options and provides
    helper methods for undo transaction management.
    """

    bl_options: Set[str] = {"REGISTER", "UNDO"}

    def undo_push(self, context: bpy.types.Context, name: str) -> None:
        """Push an undo state before making changes.

        Args:
            context: Blender context
            name: Name for the undo step
        """
        bpy.ops.ed.undo_push(message=name)

    def with_undo(
        self,
        context: bpy.types.Context,
        name: str,
    ):
        """Context manager for safe undo operations.

        Args:
            context: Blender context
            name: Undo step name
        """
        self.undo_push(context, name)
        return _UndoContext(self)


class _UndoContext:
    """Context manager for undo operations.

    Internal use by UndoOperator.
    """

    def __init__(self, operator: UndoOperator) -> None:
        self.operator = operator

    def __enter__(self) -> None:
        pass

    def __exit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        pass

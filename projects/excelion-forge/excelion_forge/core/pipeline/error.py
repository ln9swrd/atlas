"""Error handling system for Excelion Forge pipelines."""

from __future__ import annotations

from dataclasses import dataclass
from dataclasses import field
from enum import Enum
from typing import Any
from typing import Callable
from typing import Optional


class ErrorSeverity(Enum):
    """Error severity levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class PipelineError(Exception):
    """Base exception for pipeline-related errors.

    Attributes:
        message: Human-readable error message
        severity: Error severity level
        details: Additional error details
        recoverable: Whether the error can be recovered from
    """

    def __init__(
        self,
        message: str,
        severity: ErrorSeverity = ErrorSeverity.MEDIUM,
        details: Optional[dict[str, Any]] = None,
        recoverable: bool = True,
    ) -> None:
        super().__init__(message)
        self.message = message
        self.severity = severity
        self.details = details or {}
        self.recoverable = recoverable


@dataclass
class ErrorRecord:
    """Record of an error occurrence.

    Attributes:
        error: The error that occurred
        timestamp: When the error occurred
        context: Context in which the error occurred
    """
    error: PipelineError
    timestamp: float
    context: dict[str, Any] = field(default_factory=dict)


class ErrorHandler:
    """Centralized error handler for pipeline operations.

    Collects errors, provides recovery strategies, and
    maintains error history for debugging.
    """

    def __init__(self) -> None:
        self._errors: list[ErrorRecord] = []
        self._handlers: dict[
            type[PipelineError],
            list[Callable[[PipelineError], bool]]
        ] = {}
        self._default_handlers: list[Callable[[PipelineError], bool]] = []

    def register_handler(
        self,
        error_type: type[PipelineError],
        handler: Callable[[PipelineError], bool],
    ) -> None:
        """Register a handler for a specific error type.

        Args:
            error_type: Type of error to handle
            handler: Function that takes the error and returns True if handled
        """
        if error_type not in self._handlers:
            self._handlers[error_type] = []
        self._handlers[error_type].append(handler)

    def register_default_handler(
        self,
        handler: Callable[[PipelineError], bool],
    ) -> None:
        """Register a default handler for unhandled errors.

        Args:
            handler: Default error handler function
        """
        self._default_handlers.append(handler)

    def handle_error(
        self,
        error: PipelineError,
        context: Optional[dict[str, Any]] = None,
    ) -> bool:
        """Handle an error by trying registered handlers.

        Args:
            error: The error to handle
            context: Additional context for the error

        Returns:
            True if the error was handled, False otherwise
        """
        import time

        record = ErrorRecord(
            error=error,
            timestamp=time.time(),
            context=context or {},
        )
        self._errors.append(record)

        # Try specific handlers first
        for error_type, handlers in self._handlers.items():
            if isinstance(error, error_type):
                for handler in handlers:
                    if handler(error):
                        return True

        # Try default handlers
        for handler in self._default_handlers:
            if handler(error):
                return True

        return False

    def get_errors(
        self,
        severity: Optional[ErrorSeverity] = None,
        limit: Optional[int] = None,
    ) -> list[ErrorRecord]:
        """Get recorded errors, optionally filtered.

        Args:
            severity: Filter by severity level
            limit: Maximum number of errors to return

        Returns:
            List of error records
        """
        errors = self._errors.copy()
        
        if severity is not None:
            errors = [e for e in errors if e.error.severity == severity]
        
        if limit is not None:
            errors = errors[-limit:]
        
        return errors

    def clear_errors(self) -> None:
        """Clear all recorded errors."""
        self._errors.clear()

    @property
    def has_critical_errors(self) -> bool:
        """Check if any critical errors have occurred."""
        return any(
            e.error.severity == ErrorSeverity.CRITICAL
            for e in self._errors
        )

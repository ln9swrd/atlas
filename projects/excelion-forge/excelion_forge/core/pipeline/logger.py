"""Central logging system for Excelion Forge pipelines."""

from __future__ import annotations

import logging
from enum import Enum
from typing import Any
from typing import Callable
from typing import Optional


class LogLevel(Enum):
    """Log severity levels."""
    DEBUG = logging.DEBUG
    INFO = logging.INFO
    WARNING = logging.WARNING
    ERROR = logging.ERROR
    CRITICAL = logging.CRITICAL


class BlenderLogHandler(logging.Handler):
    """Custom logging handler that prints to Blender's console."""

    def emit(self, record: logging.LogRecord) -> None:
        try:
            msg = self.format(record)
            print(msg)
        except Exception:
            self.handleError(record)


class Logger:
    """Centralized logger for pipeline operations.

    Provides structured logging with different severity levels
    and optional callback integration for UI updates.
    """

    _instance: Optional[Logger] = None
    _logger: logging.Logger
    _callbacks: list[Callable[[LogLevel, str], None]]

    def __new__(cls) -> Logger:
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self) -> None:
        """Initialize the logger instance."""
        self._logger = logging.getLogger("excelion_forge")
        self._logger.setLevel(logging.DEBUG)
        
        # Avoid duplicate handlers
        if not self._logger.handlers:
            # Blender console handler
            blender_handler = BlenderLogHandler()
            blender_handler.setLevel(logging.INFO)
            formatter = logging.Formatter(
                "[Excelion Forge] %(levelname)s: %(message)s"
            )
            blender_handler.setFormatter(formatter)
            self._logger.addHandler(blender_handler)
        
        self._callbacks = []

    def add_callback(self, callback: Callable[[LogLevel, str], None]) -> None:
        """Add a callback to receive log messages.

        Args:
            callback: Function that receives (level, message)
        """
        if callback not in self._callbacks:
            self._callbacks.append(callback)

    def remove_callback(self, callback: Callable[[LogLevel, str], None]) -> None:
        """Remove a previously added callback.

        Args:
            callback: Callback function to remove
        """
        if callback in self._callbacks:
            self._callbacks.remove(callback)

    def _log(self, level: LogLevel, message: str, *args: Any) -> None:
        """Internal log method that handles both logging and callbacks.

        Args:
            level: Log severity level
            message: Log message
            *args: Format arguments for the message
        """
        formatted_message = message % args if args else message
        self._logger.log(level.value, formatted_message)
        
        for callback in self._callbacks:
            callback(level, formatted_message)

    def debug(self, message: str, *args: Any) -> None:
        """Log a debug message.

        Args:
            message: Debug message
            *args: Format arguments
        """
        self._log(LogLevel.DEBUG, message, *args)

    def info(self, message: str, *args: Any) -> None:
        """Log an info message.

        Args:
            message: Info message
            *args: Format arguments
        """
        self._log(LogLevel.INFO, message, *args)

    def warning(self, message: str, *args: Any) -> None:
        """Log a warning message.

        Args:
            message: Warning message
            *args: Format arguments
        """
        self._log(LogLevel.WARNING, message, *args)

    def error(self, message: str, *args: Any) -> None:
        """Log an error message.

        Args:
            message: Error message
            *args: Format arguments
        """
        self._log(LogLevel.ERROR, message, *args)

    def critical(self, message: str, *args: Any) -> None:
        """Log a critical message.

        Args:
            message: Critical message
            *args: Format arguments
        """
        self._log(LogLevel.CRITICAL, message, *args)

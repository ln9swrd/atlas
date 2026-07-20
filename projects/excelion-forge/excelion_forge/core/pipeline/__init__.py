"""Pipeline foundation modules for Excelion Forge."""

from .context import PipelineContext
from .types import ValidationSessionProtocol
from .error import PipelineError
from .error import ErrorHandler
from .logger import Logger
from .progress import ProgressManager
from .task import Task
from .task import TaskResult
from .task import TaskStatus
from .task import FunctionTask
from .registry import Pipeline
from .registry import PipelineRegistry
from .utils import chunk_list
from .utils import safe_get
from .utils import retry
from .utils import format_duration
from .utils import validate_required
from .utils import merge_dicts

__all__ = [
    "PipelineContext",
    "ValidationSessionProtocol",
    "PipelineError",
    "ErrorHandler",
    "Logger",
    "ProgressManager",
    "Task",
    "TaskResult",
    "TaskStatus",
    "FunctionTask",
    "Pipeline",
    "PipelineRegistry",
    "chunk_list",
    "safe_get",
    "retry",
    "format_duration",
    "validate_required",
    "merge_dicts",
]

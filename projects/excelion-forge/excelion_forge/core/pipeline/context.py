"""Context management for Excelion Forge pipelines."""

from __future__ import annotations

from dataclasses import dataclass
from dataclasses import field
from typing import Any
from typing import Optional
from typing import TypeVar

T = TypeVar("T")


@dataclass
class PipelineContext:
    """Execution context for pipeline operations.

    Provides a shared state container for pipeline tasks,
    including configuration, temporary data, and results.

    Attributes:
        config: Configuration settings for the pipeline
        data: Shared data storage for tasks
        results: Results from completed tasks
        metadata: Additional context metadata
    """
    config: dict[str, Any] = field(default_factory=dict)
    data: dict[str, Any] = field(default_factory=dict)
    results: dict[str, Any] = field(default_factory=dict)
    metadata: dict[str, Any] = field(default_factory=dict)
    # Optional runtime adapter (opaque). Pipeline tasks may use this to
    # interact with Blender without importing `bpy` directly.
    runtime: Any = None

    def get(self, key: str, default: Optional[T] = None) -> Optional[T]:
        """Get a value from the context with fallback.

        Args:
            key: Key to look up
            default: Default value if key not found

        Returns:
            The value or default
        """
        return self.data.get(key, default)

    def set(self, key: str, value: Any) -> None:
        """Set a value in the context.

        Args:
            key: Key to set
            value: Value to store
        """
        self.data[key] = value

    def get_result(self, key: str, default: Optional[T] = None) -> Optional[T]:
        """Get a result from the context.

        Args:
            key: Result key
            default: Default value if not found

        Returns:
            The result or default
        """
        return self.results.get(key, default)

    def set_result(self, key: str, value: Any) -> None:
        """Store a result in the context.

        Args:
            key: Result key
            value: Result value
        """
        self.results[key] = value

    def get_config(self, key: str, default: Optional[T] = None) -> Optional[T]:
        """Get a configuration value.

        Args:
            key: Config key
            default: Default value if not found

        Returns:
            Config value or default
        """
        return self.config.get(key, default)

    def set_config(self, key: str, value: Any) -> None:
        """Set a configuration value.

        Args:
            key: Config key
            value: Config value
        """
        self.config[key] = value

    def merge(self, other: PipelineContext) -> None:
        """Merge another context into this one.

        Args:
            other: Context to merge from
        """
        self.config.update(other.config)
        self.data.update(other.data)
        self.results.update(other.results)
        self.metadata.update(other.metadata)

    def clone(self) -> PipelineContext:
        """Create a copy of this context.

        Returns:
            New context with same data
        """
        return PipelineContext(
            config=self.config.copy(),
            data=self.data.copy(),
            results=self.results.copy(),
            metadata=self.metadata.copy(),
        )

    def clear(self) -> None:
        """Clear all context data except config."""
        self.data.clear()
        self.results.clear()
        self.metadata.clear()

    def get_runtime(self) -> Optional[Any]:
        """Return the injected runtime adapter or None if not set."""
        return self.runtime

    def set_runtime(self, runtime: Any) -> None:
        """Set or replace the runtime adapter."""
        self.runtime = runtime

"""Common utility functions for Excelion Forge pipelines."""

from __future__ import annotations

from typing import Any
from typing import Callable
from typing import Dict
from typing import List
from typing import Optional
from typing import TypeVar

T = TypeVar("T")


def chunk_list(items: List[T], chunk_size: int) -> List[List[T]]:
    """Split a list into chunks of specified size.

    Args:
        items: List to split
        chunk_size: Maximum size of each chunk

    Returns:
        List of chunks
    """
    return [
        items[i:i + chunk_size]
        for i in range(0, len(items), chunk_size)
    ]


def safe_get(data: Dict[str, Any], key: str, default: Optional[T] = None) -> Optional[T]:
    """Safely get a value from a dictionary.

    Args:
        data: Dictionary to look up
        key: Key to get
        default: Default value if key not found

    Returns:
        Value or default
    """
    return data.get(key, default)


def retry(
    func: Callable[..., T],
    max_attempts: int = 3,
    delay: float = 1.0,
    exceptions: tuple[type[Exception], ...] = (Exception,),
) -> Callable[..., T]:
    """Decorator to retry a function on failure.

    Args:
        func: Function to wrap
        max_attempts: Maximum number of attempts
        delay: Delay between attempts in seconds
        exceptions: Exceptions to catch and retry

    Returns:
        Wrapped function
    """
    import time

    def wrapper(*args: Any, **kwargs: Any) -> T:
        last_exception: Optional[Exception] = None
        
        for attempt in range(max_attempts):
            try:
                return func(*args, **kwargs)
            except exceptions as e:
                last_exception = e
                if attempt < max_attempts - 1:
                    time.sleep(delay)
        
        if last_exception is not None:
            raise last_exception
        # This should never happen if max_attempts >= 1
        raise RuntimeError("Retry failed unexpectedly")

    return wrapper


def format_duration(seconds: float) -> str:
    """Format a duration in seconds to a human-readable string.

    Args:
        seconds: Duration in seconds

    Returns:
        Formatted duration string
    """
    if seconds < 60:
        return f"{seconds:.2f}s"
    elif seconds < 3600:
        minutes = int(seconds // 60)
        secs = int(seconds % 60)
        return f"{minutes}m {secs}s"
    else:
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        return f"{hours}h {minutes}m {secs}s"


def validate_required(
    data: Dict[str, Any],
    required_keys: List[str],
) -> List[str]:
    """Validate that required keys are present in a dictionary.

    Args:
        data: Dictionary to validate
        required_keys: Keys that must be present

    Returns:
        List of missing keys
    """
    return [key for key in required_keys if key not in data]


def merge_dicts(*dicts: Dict[str, Any]) -> Dict[str, Any]:
    """Merge multiple dictionaries into one.

    Later dictionaries override earlier ones.

    Args:
        *dicts: Dictionaries to merge

    Returns:
        Merged dictionary
    """
    result: Dict[str, Any] = {}
    for d in dicts:
        result.update(d)
    return result

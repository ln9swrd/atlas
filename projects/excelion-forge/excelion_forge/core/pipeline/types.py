from typing import Protocol, Any, List


class ValidationSessionProtocol(Protocol):
    """Blender validation / pipeline execution context contract."""

    id: str
    active: bool
    has_run: bool
    issues: List[Any]

    def add_issue(self, issue: Any) -> None: ...
    def commit(self) -> None: ...
    def rollback(self) -> None: ...

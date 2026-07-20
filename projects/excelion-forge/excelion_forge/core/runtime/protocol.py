from typing import Protocol, Any, Iterable, runtime_checkable, Optional, List


@runtime_checkable
class BpyRuntimeProtocol(Protocol):
    """Abstract runtime contract that hides Blender internals from pipeline.

    All Blender-related values are typed as ``Any`` or opaque handles so the
    rest of the codebase remains testable without importing ``bpy``.
    """

    def get_scene(self) -> Any: ...

    def get_objects(self) -> Iterable[Any]: ...

    def get_object(self, name: str) -> Optional[Any]: ...

    def create_object(self, data: dict) -> Any: ...

    def delete_object(self, obj: Any) -> None: ...

    def get_selected(self) -> List[Any]: ...

    def run_operator(self, op_id: str, **kwargs: Any) -> Any: ...

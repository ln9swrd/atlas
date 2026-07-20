from typing import Any, Optional, List


class FakeBpyAdapter:
    """In-memory fake adapter suitable for unit tests.

    The fake implements the same surface as ``BpyRuntimeProtocol`` but uses
    plain Python objects so tests don't need Blender.
    """

    def __init__(self) -> None:
        self.objects: dict[str, dict[str, Any]] = {}
        self.scene: dict[str, Any] = {"name": "Scene"}
        self.calls: list[tuple[str, dict[str, Any]]] = []

    def get_scene(self) -> Any:
        return self.scene

    def get_objects(self):
        return self.objects.values()

    def get_object(self, name: str) -> Optional[Any]:
        return self.objects.get(name)

    def create_object(self, data: dict) -> Any:
        obj = {"name": data["name"], **data}
        self.objects[obj["name"]] = obj
        return obj

    def delete_object(self, obj: Any) -> None:
        name = getattr(obj, "name", None) or (obj.get("name") if isinstance(obj, dict) else None)
        if name:
            self.objects.pop(name, None)

    def get_selected(self) -> List[Any]:
        return [o for o in self.objects.values() if o.get("selected")]

    def run_operator(self, op_id: str, **kwargs: Any) -> Any:
        self.calls.append((op_id, kwargs))
        return {"op": op_id, "kwargs": kwargs}

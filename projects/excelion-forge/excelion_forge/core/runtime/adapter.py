from typing import Any, Optional, List

try:
    import bpy  # type: ignore
except Exception:  # pragma: no cover - runtime may not have Blender available
    bpy = None  # type: ignore


class BpyAdapter:
    """Production adapter that delegates to the real `bpy` module.

    This module lives behind the `BpyRuntimeProtocol` contract so the rest of
    the codebase does not import `bpy` directly.
    """

    def get_scene(self) -> Any:
        return bpy.context.scene

    def get_objects(self):
        return bpy.data.objects

    def get_object(self, name: str) -> Optional[Any]:
        return bpy.data.objects.get(name)

    def create_object(self, data: dict) -> Any:
        # Minimal example: create a mesh object when provided with required data.
        # Implementations may vary depending on pipeline needs.
        name = data.get("name")
        if not name:
            raise ValueError("object data must include 'name'")
        mesh = bpy.data.meshes.new(name + "_mesh")
        obj = bpy.data.objects.new(name, mesh)
        bpy.context.collection.objects.link(obj)
        return obj

    def delete_object(self, obj: Any) -> None:
        bpy.data.objects.remove(obj)

    def get_selected(self) -> List[Any]:
        return list(bpy.context.selected_objects)

    def run_operator(self, op_id: str, **kwargs: Any) -> Any:
        # op_id should be a dotted path inside bpy.ops, e.g. 'mesh.primitive_cube_add'
        parts = op_id.split(".")
        op = bpy.ops
        for p in parts:
            op = getattr(op, p)
        return op(**kwargs)

"""Minimal bpy type stubs for Excelion Forge development.

These stubs cover only the bpy API surface used in this project.
They allow type checkers (Pyrefly, Pyright, mypy) to resolve bpy
symbols without a running Blender instance.

NOT for runtime use — Blender provides the real bpy at runtime.
"""

from __future__ import annotations

from typing import Any, Callable, Iterator, Type


# ---------------------------------------------------------------------------
# bpy.types
# ---------------------------------------------------------------------------

class _PropertyGroup:
    """Base class for Blender PropertyGroups."""
    name: str
    def __getattr__(self, name: str) -> Any: ...
    def __setattr__(self, name: str, value: Any) -> None: ...


class _CollectionProperty:
    """Blender CollectionProperty that acts as a list of PropertyGroup items."""
    def __len__(self) -> int: ...
    def __iter__(self) -> Iterator[Any]: ...
    def __getitem__(self, index: int) -> Any: ...
    def add(self) -> Any: ...
    def clear(self) -> None: ...
    def remove(self, index: int) -> None: ...


class _UILayout:
    """Blender UI layout handle."""
    alignment: str
    scale_x: float
    scale_y: float
    enabled: bool
    active: bool
    def row(self, *, align: bool = False) -> _UILayout: ...
    def column(self, *, align: bool = False) -> _UILayout: ...
    def box(self) -> _UILayout: ...
    def separator(self, *, factor: float = 1.0) -> None: ...
    def label(self, *, text: str = "", icon: str = "NONE") -> None: ...
    def prop(self, data: Any, property: str, **kwargs: Any) -> None: ...
    def operator(self, operator: str, *, text: str = "", icon: str = "NONE") -> Any: ...
    def menu(self, menu: str, *, text: str = "") -> None: ...
    def split(self, *, factor: float = 0.5, align: bool = False) -> _UILayout: ...
    def __getattr__(self, name: str) -> Any: ...


class _Object:
    """Stub for bpy.types.Object."""
    name: str
    type: str
    location: Any
    rotation_euler: Any
    scale: Any
    data: Any
    def __getattr__(self, name: str) -> Any: ...


class _Context:
    """Stub for bpy.types.Context."""
    active_object: _Object | None
    selected_objects: list[_Object]
    mode: str
    scene: Any
    view_layer: Any
    window_manager: Any
    def __getattr__(self, name: str) -> Any: ...


class _WindowManager:
    """Stub for bpy.types.WindowManager."""
    def fileselect_add(self, operator: Any) -> None: ...
    def __getattr__(self, name: str) -> Any: ...


class _ViewLayer:
    objects: Any
    def __getattr__(self, name: str) -> Any: ...


class types:
    PropertyGroup = _PropertyGroup
    Object = _Object
    Context = _Context
    WindowManager = _WindowManager
    UILayout = _UILayout
    ViewLayer = _ViewLayer

    class Operator:
        bl_idname: str
        bl_label: str
        bl_description: str
        bl_options: set[str]
        def execute(self, context: _Context) -> set[str]: ...
        def invoke(self, context: _Context, event: Any) -> set[str]: ...
        def poll(cls, context: _Context) -> bool: ...
        def report(self, type: set[str], message: str) -> None: ...
        def __getattr__(self, name: str) -> Any: ...

    class Panel:
        bl_label: str
        bl_idname: str
        bl_space_type: str
        bl_region_type: str
        bl_category: str
        layout: "_UILayout"
        def draw(self, context: _Context) -> None: ...

    class AddonPreferences:
        bl_idname: str

    class Menu:
        bl_label: str
        bl_idname: str

    class Node: ...
    class NodeTree: ...
    class Armature:
        bones: Any
        edit_bones: Any

    class Bone:
        name: str
        parent: Any
        children: list[Any]

    class EditBone:
        name: str
        head: Any
        tail: Any
        parent: Any
        children: list[Any]
        use_connect: bool


# ---------------------------------------------------------------------------
# bpy.props
# ---------------------------------------------------------------------------

class props:
    @staticmethod
    def StringProperty(
        *,
        name: str = "",
        description: str = "",
        default: str = "",
        subtype: str = "NONE",
        options: set[str] | None = None,
        update: Callable[..., None] | None = None,
        get: Callable[..., str] | None = None,
        set: Callable[..., None] | None = None,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def BoolProperty(
        *,
        name: str = "",
        description: str = "",
        default: bool = False,
        options: set[str] | None = None,
        update: Callable[..., None] | None = None,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def IntProperty(
        *,
        name: str = "",
        description: str = "",
        default: int = 0,
        min: int = -2**31,
        max: int = 2**31 - 1,
        soft_min: int = -2**31,
        soft_max: int = 2**31 - 1,
        options: set[str] | None = None,
        update: Callable[..., None] | None = None,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def FloatProperty(
        *,
        name: str = "",
        description: str = "",
        default: float = 0.0,
        update: Callable[..., None] | None = None,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def FloatVectorProperty(
        *,
        name: str = "",
        description: str = "",
        default: tuple[float, ...] = (0.0, 0.0, 0.0),
        size: int = 3,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def EnumProperty(
        *,
        name: str = "",
        description: str = "",
        items: list[tuple[str, str, str]] | Callable[..., Any] = ...,
        default: str | None = None,
        options: set[str] | None = None,
        update: Callable[..., None] | None = None,
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def CollectionProperty(
        *,
        type: type,
        name: str = "",
        description: str = "",
        **kwargs: Any,
    ) -> Any: ...

    @staticmethod
    def PointerProperty(
        *,
        type: type,
        name: str = "",
        description: str = "",
        **kwargs: Any,
    ) -> Any: ...


# ---------------------------------------------------------------------------
# bpy.utils
# ---------------------------------------------------------------------------

class utils:
    @staticmethod
    def register_class(cls: type) -> None: ...
    @staticmethod
    def unregister_class(cls: type) -> None: ...
    @staticmethod
    def register_module(module: str, verbose: bool = False) -> None: ...
    @staticmethod
    def unregister_module(module: str, verbose: bool = False) -> None: ...
    @staticmethod
    def script_path_user() -> str: ...
    @staticmethod
    def script_path_pref() -> str: ...


# ---------------------------------------------------------------------------
# bpy.data
# ---------------------------------------------------------------------------

class _DataObjects:
    def get(self, name: str, default: Any = None) -> _Object | None: ...
    def __iter__(self) -> Iterator[_Object]: ...


class data:
    filepath: str
    objects: _DataObjects
    scenes: Any
    armatures: Any
    materials: Any
    meshes: Any
    images: Any
    texts: Any


# ---------------------------------------------------------------------------
# bpy.context  (module-level singleton)
# ---------------------------------------------------------------------------

context: _Context


# ---------------------------------------------------------------------------
# bpy.ops
# ---------------------------------------------------------------------------

class _BpyOp:
    """Blender operator callable — supports both calling and .poll()."""
    def __call__(self, **kwargs: Any) -> set[str]: ...
    def poll(self, context: Any = None) -> bool: ...


class _ops_object:
    select_all: _BpyOp
    mode_set: _BpyOp
    delete: _BpyOp
    armature_add: _BpyOp
    transform_apply: _BpyOp
    select_hierarchy: _BpyOp
    def __getattr__(self, name: str) -> _BpyOp: ...


class _ops_pose:
    select_all: _BpyOp
    def __getattr__(self, name: str) -> _BpyOp: ...


class _ops_wm:
    save_as_mainfile: _BpyOp
    path_select: _BpyOp
    def __getattr__(self, name: str) -> _BpyOp: ...


class _ops_excelion_forge:
    validate_active_rig: _BpyOp
    def __getattr__(self, name: str) -> _BpyOp: ...


class _ops_ed:
    undo_push: _BpyOp
    def __getattr__(self, name: str) -> _BpyOp: ...


class ops:
    object: _ops_object
    pose: _ops_pose
    wm: _ops_wm
    excelion_forge: _ops_excelion_forge
    ed: _ops_ed
    def __getattr__(self, name: str) -> Any: ...

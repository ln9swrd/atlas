import bpy
from bpy.props import StringProperty, BoolProperty, FloatProperty
from bpy.types import PropertyGroup


class ParaModelSettings(PropertyGroup):
    data_path: StringProperty(
        name="Data Path",
        description="Path to projects/paramodel/data/mecha directory",
        default="",
        subtype="DIR_PATH",
    )
    selected_mecha: StringProperty(
        name="Mecha ID",
        description="Selected mecha id (e.g. brave-001)",
        default="brave-001",
    )
    create_empties: BoolProperty(
        name="Create Slot Empties",
        description="Create Empty objects for each Base Body slot",
        default=True,
    )
    create_placeholders: BoolProperty(
        name="Attach Parts",
        description="Attach mesh or placeholder cubes for part_id",
        default=True,
    )
    prefer_mesh: BoolProperty(
        name="Prefer Mesh File",
        description="Import part.mesh when file exists; else placeholder",
        default=True,
    )
    apply_parameters: BoolProperty(
        name="Apply Parameters",
        description="Create root empty; scale by height * working_scale; store mass/mobility/output",
        default=True,
    )
    create_armature: BoolProperty(
        name="Create Armature",
        description="Build SuperRobotRig; parent to root (inherits working scale)",
        default=True,
    )
    working_scale: FloatProperty(
        name="Working Scale",
        description="Viewport scale vs real meters. 0.01 = 1:100 (25m → ~0.25m). 1.0 = real size",
        default=0.01,
        min=0.0001,
        max=10.0,
        soft_min=0.001,
        soft_max=1.0,
    )


classes = (
    ParaModelSettings,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.paramodel = bpy.props.PointerProperty(type=ParaModelSettings)


def unregister():
    del bpy.types.Scene.paramodel
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)

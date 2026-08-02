import bpy
from bpy.props import StringProperty, BoolProperty
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
        description="Create root empty; scale by height; store mass/mobility/output",
        default=True,
    )
    create_armature: BoolProperty(
        name="Create Armature",
        description="Build basic armature from slots; parent slots to bones",
        default=True,
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

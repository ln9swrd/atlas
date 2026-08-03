import bpy
from bpy.types import Panel


class PARAMODEL_PT_main(Panel):
    bl_label = "ParaModel"
    bl_idname = "PARAMODEL_PT_main"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "ParaModel"

    def draw(self, context):
        layout = self.layout
        settings = context.scene.paramodel

        layout.prop(settings, "data_path")
        layout.prop(settings, "selected_mecha")

        col = layout.column(align=True)
        col.prop(settings, "create_empties")
        col.prop(settings, "create_armature")
        col.prop(settings, "create_placeholders")
        col.prop(settings, "prefer_mesh")
        col.prop(settings, "apply_parameters")
        col.prop(settings, "working_scale")

        layout.separator()
        layout.operator("paramodel.load_mecha", icon="IMPORT")
        layout.operator("paramodel.clear_slots", icon="TRASH")

        layout.separator()
        box = layout.box()
        box.label(text="v0.7.2 — working scale 1:100", icon="INFO")


classes = (
    PARAMODEL_PT_main,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)


def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)

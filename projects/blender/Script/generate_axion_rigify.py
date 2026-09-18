import bpy

METARIG_NAME = "Axion_Rigify_Metarig"
RIG_NAME = "axion_rig"

for obj in list(bpy.data.objects):
    if obj.name in {METARIG_NAME, RIG_NAME}:
        bpy.data.objects.remove(obj, do_unlink=True)

bpy.ops.object.mode_set(mode="OBJECT") if bpy.context.object and bpy.context.object.mode != "OBJECT" else None
for obj in bpy.context.selected_objects:
    obj.select_set(False)

bpy.ops.object.armature_human_metarig_add()
metarig = bpy.context.object
metarig.name = METARIG_NAME
metarig.data.name = f"{METARIG_NAME}_Armature"

bpy.context.view_layer.objects.active = metarig
metarig.select_set(True)

bpy.ops.pose.rigify_generate()
rig = bpy.context.object
rig.name = RIG_NAME
rig.data.name = f"{RIG_NAME}_Armature"

bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
print("RIGIFY_GENERATED")
print("METARIG", metarig.name, len(metarig.data.bones))
print("RIG", rig.name, len(rig.data.bones), rig.get("rig_id"))
print("RIG_UI", "rig_ui" in rig)

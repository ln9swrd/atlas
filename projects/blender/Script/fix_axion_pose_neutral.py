import bpy

ARMATURE_NAME = "axion_metarig"

armature = bpy.data.objects.get(ARMATURE_NAME)
if armature is None or armature.type != "ARMATURE":
    raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")

bpy.context.view_layer.objects.active = armature
armature.select_set(True)

if armature.animation_data:
    armature.animation_data.action = None

bpy.context.scene.frame_set(1)
bpy.ops.object.mode_set(mode="POSE")
bpy.ops.pose.select_all(action="SELECT")
bpy.ops.pose.transforms_clear()
bpy.ops.object.mode_set(mode="OBJECT")
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 60
bpy.context.scene.frame_set(1)
bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)

print("AXION_POSE_NEUTRALIZED")
print("ACTIVE_ACTION", armature.animation_data.action.name if armature.animation_data and armature.animation_data.action else None)
print("IK_CONSTRAINTS", sum(1 for bone in armature.pose.bones for constraint in bone.constraints if constraint.type == "IK"))

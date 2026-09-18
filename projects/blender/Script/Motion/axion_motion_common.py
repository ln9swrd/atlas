import bpy
import math

ARMATURE_NAME = "axion_metarig"


def reset_pose(armature):
    for bone in armature.pose.bones:
        bone.rotation_mode = "XYZ"
        bone.location = (0.0, 0.0, 0.0)
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)


def action_slot_for(action, armature):
    identifier = f"OB{armature.name}"
    for slot in action.slots:
        if slot.target_id_type == "OBJECT" and slot.identifier == identifier:
            return slot
    return action.slots.new("OBJECT", armature.name)


def key_pose(armature, frame, pose):
    bpy.context.scene.frame_set(frame)
    reset_pose(armature)
    for name, rotation in pose.get("rotations", {}).items():
        bone = armature.pose.bones.get(name)
        if bone:
            bone.rotation_euler = tuple(math.radians(value) for value in rotation)
    root = armature.pose.bones.get("spine")
    if root:
        root.location = pose.get("location", (0.0, 0.0, 0.0))
        if "root_rotation" in pose:
            root.rotation_euler = tuple(math.radians(value) for value in pose["root_rotation"])
    for bone in armature.pose.bones:
        bone.keyframe_insert(data_path="location", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="scale", frame=frame, group=bone.name)


def create_motion(action_name, frames, poses):
    armature = bpy.data.objects.get(ARMATURE_NAME)
    if armature is None or armature.type != "ARMATURE":
        raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")

    action = bpy.data.actions.get(action_name)
    if action is not None:
        if armature.animation_data and armature.animation_data.action == action:
            armature.animation_data.action = None
        bpy.data.actions.remove(action)
    action = bpy.data.actions.new(action_name)
    slot = action_slot_for(action, armature)
    armature.animation_data_create()
    armature.animation_data.action = action
    armature.animation_data.action_slot = slot

    for frame, pose in zip(frames, poses):
        key_pose(armature, frame, pose)

    action.frame_start = frames[0]
    action.frame_end = frames[-1]
    bpy.context.scene.frame_start = frames[0]
    bpy.context.scene.frame_end = frames[-1]
    bpy.context.scene.frame_set(frames[0])
    bpy.context.view_layer.update()
    print(f"Created {action_name}: frames {frames[0]}-{frames[-1]}")
    return action

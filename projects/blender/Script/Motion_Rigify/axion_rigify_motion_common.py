import bpy
import math
from pathlib import Path

ARMATURE_NAME = "axion_rig"


def reset_controls(rig):
    for bone in rig.pose.bones:
        if bone.name.startswith(("DEF-", "ORG-", "MCH-", "VIS-")):
            continue
        bone.rotation_mode = "XYZ"
        bone.location = (0.0, 0.0, 0.0)
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)


def action_slot_for(action, rig):
    identifier = f"OB{rig.name}"
    for slot in action.slots:
        if slot.target_id_type == "OBJECT" and slot.identifier == identifier:
            return slot
    return action.slots.new("OBJECT", rig.name)


def set_control(rig, name, pose):
    bone = rig.pose.bones.get(name)
    if bone is None:
        return
    bone.rotation_mode = "XYZ"
    bone.location = pose.get("location", (0.0, 0.0, 0.0))
    bone.rotation_euler = tuple(math.radians(v) for v in pose.get("rotation", (0.0, 0.0, 0.0)))
    bone.scale = pose.get("scale", (1.0, 1.0, 1.0))


def key_pose(rig, frame, pose):
    bpy.context.scene.frame_set(frame)
    reset_controls(rig)
    for name, values in pose.items():
        set_control(rig, name, values)
    for bone in rig.pose.bones:
        if bone.name.startswith(("DEF-", "ORG-", "MCH-", "VIS-")):
            continue
        bone.keyframe_insert(data_path="location", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone.name)
        bone.keyframe_insert(data_path="scale", frame=frame, group=bone.name)


def create_motion(action_name, frames, poses):
    rig = bpy.data.objects.get(ARMATURE_NAME)
    if rig is None or rig.type != "ARMATURE":
        raise RuntimeError(f"Rigify armature not found: {ARMATURE_NAME}")
    action = bpy.data.actions.get(action_name)
    if action is not None:
        if rig.animation_data and rig.animation_data.action == action:
            rig.animation_data.action = None
        bpy.data.actions.remove(action)
    action = bpy.data.actions.new(action_name)
    slot = action_slot_for(action, rig)
    rig.animation_data_create()
    rig.animation_data.action = action
    rig.animation_data.action_slot = slot
    for frame, pose in zip(frames, poses):
        key_pose(rig, frame, pose)
    action.frame_start = frames[0]
    action.frame_end = frames[-1]
    bpy.context.scene.frame_start = frames[0]
    bpy.context.scene.frame_end = frames[-1]
    bpy.context.scene.frame_set(frames[0])
    bpy.context.view_layer.update()
    print(f"Created {action_name}: frames {frames[0]}-{frames[-1]}")
    return action

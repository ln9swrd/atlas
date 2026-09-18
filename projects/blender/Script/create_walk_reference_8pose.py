"""
Create an eight-pose walk cycle for RIG-Axion_Rigify_Metarig.
Reference order: Contact L, Down L, Passing L, Up L,
Contact R, Down R, Passing R, Up R.
"""

import bpy
import math
from mathutils import Vector

RIG_NAME = "RIG-Axion_Rigify_Metarig"
ACTION_NAME = "Walk_Cycle_Reference_8Pose"


def key_pose(bone, frame, location=None, rotation=None):
    if location is not None:
        bone.location = location
        bone.keyframe_insert(data_path="location", frame=frame)
    if rotation is not None:
        bone.rotation_mode = "XYZ"
        bone.rotation_euler = rotation
        bone.keyframe_insert(data_path="rotation_euler", frame=frame)


def main():
    rig = bpy.data.objects.get(RIG_NAME)
    if rig is None:
        raise RuntimeError(f"Missing rig: {RIG_NAME}")

    bpy.ops.object.mode_set(mode="OBJECT") if rig.mode != "OBJECT" else None
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)
    bpy.ops.object.mode_set(mode="POSE")

    old_action = bpy.data.actions.get(ACTION_NAME)
    if old_action is not None:
        bpy.data.actions.remove(old_action, do_unlink=True)

    action = bpy.data.actions.new(ACTION_NAME)
    rig.animation_data_create()
    rig.animation_data.action = action

    required = ["root", "foot_ik.L", "foot_ik.R", "hand_ik.L", "hand_ik.R", "chest"]
    bones = {name: rig.pose.bones.get(name) for name in required}
    missing = [name for name, bone in bones.items() if bone is None]
    if missing:
        raise RuntimeError(f"Missing controls: {', '.join(missing)}")

    root = bones["root"]
    left_foot = bones["foot_ik.L"]
    right_foot = bones["foot_ik.R"]
    left_hand = bones["hand_ik.L"]
    right_hand = bones["hand_ik.R"]
    chest = bones["chest"]

    base = {name: bone.location.copy() for name, bone in bones.items()}
    frame_step = 6
    cycle = [
        ("CONTACT L", 0, 1.35, -1.05, 0.00, 0.08, 0.00, 0.00, 5.0),
        ("DOWN L", 6, 0.55, -0.35, -0.08, 0.10, 0.10, -0.10, 2.0),
        ("PASSING L", 12, -0.20, 0.45, 0.30, 0.00, 0.00, 0.00, 0.0),
        ("UP L", 18, -0.55, 0.85, 0.12, -0.08, -0.10, 0.10, -2.0),
        ("CONTACT R", 24, -1.05, 1.35, 0.00, 0.08, 0.00, 0.00, -5.0),
        ("DOWN R", 30, -0.35, 0.55, 0.10, -0.08, -0.10, 0.10, -2.0),
        ("PASSING R", 36, 0.45, -0.20, 0.30, 0.00, 0.00, 0.00, 0.0),
        ("UP R", 42, 0.85, -0.55, 0.12, 0.08, 0.10, -0.10, 2.0),
        ("CONTACT L LOOP", 48, 1.35, -1.05, 0.00, 0.08, 0.00, 0.00, 5.0),
    ]

    for label, frame, left_y, right_y, foot_z, hand_y, left_hand_z, right_hand_z, chest_x in cycle:
        bpy.context.scene.frame_set(frame)

        left_location = base["foot_ik.L"].copy()
        right_location = base["foot_ik.R"].copy()
        left_location.y += left_y
        right_location.y += right_y
        left_location.z += foot_z
        right_location.z += foot_z
        key_pose(left_foot, frame, location=left_location)
        key_pose(right_foot, frame, location=right_location)

        left_hand_location = base["hand_ik.L"].copy()
        right_hand_location = base["hand_ik.R"].copy()
        left_hand_location.y += hand_y
        right_hand_location.y -= hand_y
        left_hand_location.z += left_hand_z
        right_hand_location.z += right_hand_z
        key_pose(left_hand, frame, location=left_hand_location)
        key_pose(right_hand, frame, location=right_hand_location)

        root_location = base["root"].copy()
        root_location.z += 0.06 if label.startswith(("DOWN", "PASSING")) else 0.0
        key_pose(root, frame, location=root_location)
        key_pose(chest, frame, rotation=Vector((math.radians(chest_x), 0.0, 0.0)))

    bpy.context.scene.frame_start = 0
    bpy.context.scene.frame_end = 47
    bpy.context.scene.frame_set(0)
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath, compress=False)

    print(f"CREATED {ACTION_NAME}")
    print("POSES: Contact L, Down L, Passing L, Up L, Contact R, Down R, Passing R, Up R")
    print(f"FRAMES: 0-{48}; playback: 0-47")
    print(f"ACTION_ASSIGNED: {rig.animation_data.action.name}")


main()

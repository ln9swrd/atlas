"""Generate an IK-only walk cycle for ord-grunt_metarig.

Run from Blender with ord-grunt.blend open or in background mode.
The source blend is never overwritten; a separate output blend is written.
"""

import math
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

ARMATURE_NAME = "ord-grunt_metarig"
ACTION_NAME = "ORD_GRUNT_IK_Walk"
OUTPUT_FILE = Path(r"D:\Atlas\projects\blender\Model\ord-grunt_ik_walk.blend")
FPS = 30
FRAME_START = 1
FRAME_END = 33

CONTROL_NAMES = (
    "root",
    "foot_ik.L",
    "foot_ik.R",
    "knee_pole.L",
    "knee_pole.R",
)


def require_armature():
    armature = bpy.data.objects.get(ARMATURE_NAME)
    if armature is None or armature.type != "ARMATURE":
        raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="DESELECT")
    armature.select_set(True)
    bpy.context.view_layer.objects.active = armature
    bpy.ops.object.mode_set(mode="POSE")
    missing = [name for name in CONTROL_NAMES if armature.pose.bones.get(name) is None]
    if missing:
        raise RuntimeError("Missing IK controls: " + ", ".join(missing))
    for side in ("L", "R"):
        shin = armature.pose.bones[f"shin.{side}"]
        ik = shin.constraints.get("IK")
        if ik is None or ik.influence <= 0.0:
            raise RuntimeError(f"Active IK constraint missing on shin.{side}")
        if ik.chain_count != 2:
            raise RuntimeError(f"Expected chain_count=2 on shin.{side}")
        if ik.pole_target != armature or ik.pole_subtarget != f"knee_pole.{side}":
            raise RuntimeError(f"Invalid pole target on shin.{side}")
    return armature


def world_matrix(armature, pose_bone):
    return armature.matrix_world @ pose_bone.matrix


def set_world_matrix(armature, pose_bone, matrix):
    pose_bone.matrix = armature.matrix_world.inverted() @ matrix


def set_world_position(armature, pose_bone, position):
    matrix = world_matrix(armature, pose_bone)
    matrix.translation = Vector(position)
    set_world_matrix(armature, pose_bone, matrix)


def rotated_world_matrix(armature, pose_bone, axis, angle):
    matrix = world_matrix(armature, pose_bone)
    origin = matrix.translation.copy()
    rotation = Matrix.Rotation(angle, 4, axis)
    return Matrix.Translation(origin) @ rotation @ Matrix.Translation(-origin) @ matrix


def capture_controls(armature):
    bpy.context.view_layer.update()
    return {
        name: {
            "location": armature.pose.bones[name].location.copy(),
            "world_location": world_matrix(
                armature, armature.pose.bones[name]
            ).translation.copy(),
            "rotation_mode": armature.pose.bones[name].rotation_mode,
            "rotation_euler": armature.pose.bones[name].rotation_euler.copy(),
            "rotation_quaternion": armature.pose.bones[name].rotation_quaternion.copy(),
        }
        for name in CONTROL_NAMES
    }


def restore_controls(armature, reference):
    for name, values in reference.items():
        bone = armature.pose.bones[name]
        bone.location = values["location"].copy()
        if values["rotation_mode"] == "QUATERNION":
            bone.rotation_quaternion = values["rotation_quaternion"].copy()
        else:
            bone.rotation_euler = values["rotation_euler"].copy()


def key_bone(pose_bone, frame):
    pose_bone.keyframe_insert(data_path="location", frame=frame, group="IK Walk")
    if pose_bone.rotation_mode == "QUATERNION":
        pose_bone.keyframe_insert(
            data_path="rotation_quaternion", frame=frame, group="IK Walk"
        )
    else:
        pose_bone.keyframe_insert(
            data_path="rotation_euler", frame=frame, group="IK Walk"
        )


def create_action(armature):
    old_action = bpy.data.actions.get(ACTION_NAME)
    if old_action is not None:
        if armature.animation_data and armature.animation_data.action == old_action:
            armature.animation_data.action = None
        bpy.data.actions.remove(old_action)

    action = bpy.data.actions.new(ACTION_NAME)
    armature.animation_data_create()
    armature.animation_data.action = action
    if hasattr(action, "slots"):
        slot = action.slots.new("OBJECT", armature.name)
        armature.animation_data.action_slot = slot
    return action


def apply_walk_pose(armature, reference, phase, progress, stride, lift, leg_length):
    restore_controls(armature, reference)

    root = armature.pose.bones["root"]
    root_sway = 0.04 * leg_length * math.sin(phase)
    root.location = reference["root"]["location"] + Vector(
        (
            root_sway,
            progress,
            0.025 * leg_length * (1.0 - math.cos(2.0 * phase)),
        )
    )
    bpy.context.view_layer.update()

    for side, phase_offset in (("L", 0.0), ("R", math.pi)):
        foot_phase = (phase + phase_offset) % (2.0 * math.pi)
        swing = 0.5 * (1.0 - math.cos(foot_phase))
        foot_lift = max(0.0, math.sin(foot_phase)) * lift
        foot = armature.pose.bones[f"foot_ik.{side}"]
        side_sign = 1.0 if side == "L" else -1.0
        lateral_swing = -side_sign * leg_length * 0.04 * math.sin(foot_phase)
        target = reference[f"foot_ik.{side}"]["world_location"] + Vector(
            (root_sway + lateral_swing, swing * stride, foot_lift)
        )
        set_world_position(armature, foot, target)
        foot.rotation_mode = "XYZ"
        foot.rotation_euler = reference[f"foot_ik.{side}"]["rotation_euler"].copy()
        foot.rotation_euler.x += math.radians(10.0) * math.sin(foot_phase)

        bpy.context.view_layer.update()
        hip = Vector(armature.pose.bones[f"thigh.{side}"].head)
        target = Vector(foot.head)
        hip_to_target = target - hip
        max_reach = leg_length * 0.95
        if hip_to_target.length > max_reach:
            target = hip + hip_to_target.normalized() * max_reach
            set_world_position(armature, foot, target)

        pole = armature.pose.bones[f"knee_pole.{side}"]
        pole_target = (hip + target) * 0.5
        pole_target.y -= leg_length * 0.55
        pole_target.x = (hip.x + target.x) * 0.5
        set_world_position(armature, pole, pole_target)

    bpy.context.view_layer.update()


def run():
    armature = require_armature()
    bpy.context.scene.render.fps = FPS
    bpy.context.scene.frame_start = FRAME_START
    bpy.context.scene.frame_end = FRAME_END

    bpy.context.scene.frame_set(FRAME_START)
    reference = capture_controls(armature)
    thigh_length = armature.data.bones["thigh.L"].length
    shin_length = armature.data.bones["shin.L"].length
    leg_length = thigh_length + shin_length
    stride = leg_length * 0.42
    lift = leg_length * 0.16

    action = create_action(armature)
    frame_count = FRAME_END - FRAME_START
    for frame in range(FRAME_START, FRAME_END + 1, 4):
        phase = 2.0 * math.pi * (frame - FRAME_START) / frame_count
        progress = stride * (frame - FRAME_START) / frame_count
        apply_walk_pose(armature, reference, phase, progress, stride, lift, leg_length)
        for name in CONTROL_NAMES:
            key_bone(armature.pose.bones[name], frame)

    action.frame_start = FRAME_START
    action.frame_end = FRAME_END
    bpy.context.scene.frame_set(FRAME_START)
    bpy.context.view_layer.update()
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUTPUT_FILE))
    print(f"Created {ACTION_NAME} on {ARMATURE_NAME}")
    print(f"Saved: {OUTPUT_FILE}")


if __name__ == "__main__":
    run()

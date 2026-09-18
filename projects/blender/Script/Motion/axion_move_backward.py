import bpy
import math

# ============================================================
# AXION - Walk Backward
# Blender 5.2
#
# 33-frame backward walk cycle
#
# Key poses:
#   1  : Left support / Right passing backward
#   9  : Right passing
#   17 : Right support / Left passing backward
#   25 : Left passing
#   33 : Same as frame 1
#
# NOTE:
# Root Y direction is assumed to be backward.
# ============================================================

ARMATURE_NAME = "axion_metarig"
ACTION_NAME = "axion_Walk Backward"

FRAME_START = 1
FRAME_END = 33


# ------------------------------------------------------------
# Utility
# ------------------------------------------------------------

def get_or_create_action(name):
    action = bpy.data.actions.get(name)

    if action is None:
        action = bpy.data.actions.new(name)

    return action


def get_or_create_object_slot(action, armature):

    target_identifier = f"OB{armature.name}"

    for slot in action.slots:
        if (
            slot.target_id_type == 'OBJECT'
            and slot.identifier == target_identifier
        ):
            return slot

    return action.slots.new('OBJECT', armature.name)


def bind_action(armature, action, slot):

    if armature.animation_data is None:
        armature.animation_data_create()

    armature.animation_data.action = action
    armature.animation_data.action_slot = slot

    bpy.context.view_layer.update()


# ------------------------------------------------------------
# Pose Utility
# ------------------------------------------------------------

def clear_pose(armature):

    for bone in armature.pose.bones:

        bone.location = (0.0, 0.0, 0.0)

        bone.rotation_mode = 'XYZ'
        bone.rotation_euler = (0.0, 0.0, 0.0)

        bone.scale = (1.0, 1.0, 1.0)


def set_rotation(bone, x=0.0, y=0.0, z=0.0):

    if bone is not None:

        bone.rotation_mode = 'XYZ'

        bone.rotation_euler = (
            math.radians(x),
            math.radians(y),
            math.radians(z)
        )


def set_location(bone, x=0.0, y=0.0, z=0.0):

    if bone is not None:

        bone.location = (
            x,
            y,
            z
        )


def keyframe_pose(armature, frame, action, slot):

    for bone in armature.pose.bones:

        bone.keyframe_insert(
            data_path="location",
            frame=frame,
            group=bone.name
        )

        bone.keyframe_insert(
            data_path="rotation_euler",
            frame=frame,
            group=bone.name
        )

        bone.keyframe_insert(
            data_path="scale",
            frame=frame,
            group=bone.name
        )


# ------------------------------------------------------------
# Armature
# ------------------------------------------------------------

armature = bpy.data.objects.get(ARMATURE_NAME)

if armature is None:
    raise RuntimeError(
        f"Armature not found: {ARMATURE_NAME}"
    )

if armature.type != 'ARMATURE':
    raise RuntimeError(
        f"Object is not an armature: {ARMATURE_NAME}"
    )


# ------------------------------------------------------------
# Action / Slot
# ------------------------------------------------------------

action = get_or_create_action(
    ACTION_NAME
)

action_slot = get_or_create_object_slot(
    action,
    armature
)

bind_action(
    armature,
    action,
    action_slot
)


# ------------------------------------------------------------
# Reset
# ------------------------------------------------------------

clear_pose(
    armature
)


# ------------------------------------------------------------
# Bones
# ------------------------------------------------------------

root = armature.pose.bones.get("pelvis")

left_thigh = armature.pose.bones.get("thigh.L")
right_thigh = armature.pose.bones.get("thigh.R")

left_shin = armature.pose.bones.get("shin.L")
right_shin = armature.pose.bones.get("shin.R")

left_foot = armature.pose.bones.get("foot.L")
right_foot = armature.pose.bones.get("foot.R")

left_upper_arm = armature.pose.bones.get("upper_arm.L")
right_upper_arm = armature.pose.bones.get("upper_arm.R")


# ============================================================
# FRAME 1
# LEFT SUPPORT
# RIGHT LEG MOVING BACK
# ============================================================

bpy.context.scene.frame_set(1)

set_location(
    root,
    0.0,
    0.0,
    0.0
)

# Left support leg
set_rotation(left_thigh, 12, 0, 0)
set_rotation(left_shin, -8, 0, 0)
set_rotation(left_foot, -3, 0, 0)

# Right leg moving backward
set_rotation(right_thigh, -28, 0, 0)
set_rotation(right_shin, 42, 0, 0)
set_rotation(right_foot, -14, 0, 0)

# Arms opposite legs
set_rotation(left_upper_arm, -18, 0, 0)
set_rotation(right_upper_arm, 18, 0, 0)

keyframe_pose(
    armature,
    1,
    action,
    action_slot
)


# ============================================================
# FRAME 9
# RIGHT LEG PASSES
# ============================================================

bpy.context.scene.frame_set(9)

set_location(
    root,
    0.0,
    -1.5,
    0.5
)

# Left leg leaves support
set_rotation(left_thigh, -8, 0, 0)
set_rotation(left_shin, 35, 0, 0)
set_rotation(left_foot, 10, 0, 0)

# Right leg passes underneath body
set_rotation(right_thigh, 8, 0, 0)
set_rotation(right_shin, 22, 0, 0)
set_rotation(right_foot, -4, 0, 0)

# Arms
set_rotation(left_upper_arm, 12, 0, 0)
set_rotation(right_upper_arm, -12, 0, 0)

keyframe_pose(
    armature,
    9,
    action,
    action_slot
)


# ============================================================
# FRAME 17
# RIGHT SUPPORT
# LEFT LEG MOVING BACK
# ============================================================

bpy.context.scene.frame_set(17)

set_location(
    root,
    0.0,
    -3.0,
    0.0
)

# Right support leg
set_rotation(right_thigh, 12, 0, 0)
set_rotation(right_shin, -8, 0, 0)
set_rotation(right_foot, -3, 0, 0)

# Left leg moving backward
set_rotation(left_thigh, -28, 0, 0)
set_rotation(left_shin, 42, 0, 0)
set_rotation(left_foot, -14, 0, 0)

# Arms
set_rotation(left_upper_arm, 18, 0, 0)
set_rotation(right_upper_arm, -18, 0, 0)

keyframe_pose(
    armature,
    17,
    action,
    action_slot
)


# ============================================================
# FRAME 25
# LEFT LEG PASSES
# ============================================================

bpy.context.scene.frame_set(25)

set_location(
    root,
    0.0,
    -4.5,
    0.5
)

# Left leg passes underneath body
set_rotation(left_thigh, 8, 0, 0)
set_rotation(left_shin, 22, 0, 0)
set_rotation(left_foot, -4, 0, 0)

# Right leg leaves support
set_rotation(right_thigh, -8, 0, 0)
set_rotation(right_shin, 35, 0, 0)
set_rotation(right_foot, 10, 0, 0)

# Arms
set_rotation(left_upper_arm, -12, 0, 0)
set_rotation(right_upper_arm, 12, 0, 0)

keyframe_pose(
    armature,
    25,
    action,
    action_slot
)


# ============================================================
# FRAME 33
# RETURN TO FRAME 1
# ============================================================

bpy.context.scene.frame_set(33)

set_location(
    root,
    0.0,
    -6.0,
    0.0
)

# Left support leg
set_rotation(left_thigh, 12, 0, 0)
set_rotation(left_shin, -8, 0, 0)
set_rotation(left_foot, -3, 0, 0)

# Right leg moving backward
set_rotation(right_thigh, -28, 0, 0)
set_rotation(right_shin, 42, 0, 0)
set_rotation(right_foot, -14, 0, 0)

# Arms
set_rotation(left_upper_arm, -18, 0, 0)
set_rotation(right_upper_arm, 18, 0, 0)

keyframe_pose(
    armature,
    33,
    action,
    action_slot
)


# ------------------------------------------------------------
# Final update
# ------------------------------------------------------------

bpy.context.view_layer.update()


# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------

print("=" * 60)
print("AXION Walk Backward created")
print(f"Action : {action.name}")
print(f"Slot   : {action_slot.identifier}")
print(f"Frames : {FRAME_START} - {FRAME_END}")
print("=" * 60)

# No automatic save.

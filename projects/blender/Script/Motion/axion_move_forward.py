import bpy
import math
import os

# ============================================================
# AXION Walk Forward
# ============================================================
#
# Input:
#   D:\Atlas\projects\blender\anime.blend
#
# Armature:
#   metarig
#
# Output Action:
#   axion_Walk Forward
#
# Output File:
#   D:\Atlas\projects\blender\anime_walk_poc.blend
#
# Scope:
#   - Walk animation only
#   - No bone deletion
#   - No mesh modification
#   - No weight modification
#   - No rig restructuring
# ============================================================


# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

ACTION_NAME = "axion_Walk Forward"

OUTPUT_FILE = r"D:\Atlas\projects\blender\anime.blend"

FPS = 30

FRAME_START = 1
FRAME_CONTACT_L = 1
FRAME_PASS_R = 9
FRAME_CONTACT_R = 17
FRAME_PASS_L = 25
FRAME_END = 33


# ------------------------------------------------------------
# FIND ARMATURE
# ------------------------------------------------------------

def find_armature():

    # First priority: object named metarig
    obj = bpy.data.objects.get("axion_metarig")

    if obj and obj.type == 'ARMATURE':
        return obj

    # Active object
    obj = bpy.context.active_object

    if obj and obj.type == 'ARMATURE':
        return obj

    # First armature
    for obj in bpy.context.scene.objects:
        if obj.type == 'ARMATURE':
            return obj

    return None


# ------------------------------------------------------------
# FIND BONE
# ------------------------------------------------------------

def find_bone(armature, candidates):

    # Exact match
    for name in candidates:

        if name in armature.pose.bones:
            return armature.pose.bones[name]

    # Case insensitive
    lower_map = {
        bone.name.lower(): bone
        for bone in armature.pose.bones
    }

    for name in candidates:

        bone = lower_map.get(name.lower())

        if bone:
            return bone

    return None


# ------------------------------------------------------------
# ROTATION
# ------------------------------------------------------------

def set_rotation(bone, frame, x=0, y=0, z=0):

    if bone is None:
        return

    bone.rotation_mode = 'XYZ'

    bone.rotation_euler = (
        math.radians(x),
        math.radians(y),
        math.radians(z)
    )

    activate_action_channel()

    bone.keyframe_insert(
        data_path="rotation_euler",
        frame=frame
    )


# ------------------------------------------------------------
# LOCATION
# ------------------------------------------------------------

def set_location(bone, frame, x=0, y=0, z=0):

    if bone is None:
        return

    bone.location = (x, y, z)

    activate_action_channel()

    bone.keyframe_insert(
        data_path="location",
        frame=frame
    )


# ------------------------------------------------------------
# CLEAR CURRENT POSE
# ------------------------------------------------------------

def clear_pose():

    bpy.ops.pose.select_all(action='SELECT')
    bpy.ops.pose.transforms_clear()


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------

print("")
print("==========================================")
print("AXION WALK FORWARD - START")
print("==========================================")


# ------------------------------------------------------------
# Find Armature
# ------------------------------------------------------------

armature = find_armature()

if armature is None:

    raise RuntimeError(
        "No armature found. Expected object: metarig"
    )


print("Armature:", armature.name)


# ------------------------------------------------------------
# Activate Armature
# ------------------------------------------------------------

bpy.ops.object.mode_set(mode='OBJECT')

bpy.ops.object.select_all(action='DESELECT')

armature.select_set(True)

bpy.context.view_layer.objects.active = armature


# ------------------------------------------------------------
# Pose Mode
# ------------------------------------------------------------

bpy.ops.object.mode_set(mode='POSE')

clear_pose()


# ------------------------------------------------------------
# Create or reuse Action
# ------------------------------------------------------------

action = bpy.data.actions.get(ACTION_NAME)

if action is None:
    action = bpy.data.actions.new(ACTION_NAME)

armature.animation_data_create()

armature.animation_data.action = action

action_slot = next(
    (
        slot for slot in action.slots
        if slot.target_id_type == "OBJECT"
        and slot.identifier == f"OB{armature.name}"
    ),
    None
)

if action_slot is None:
    action_slot = action.slots.new("OBJECT", armature.name)

armature.animation_data.action_slot = action_slot

print("Created Action:", action.name)


def activate_action_channel():

    armature.animation_data.action = action
    armature.animation_data.action_slot = action_slot


# ------------------------------------------------------------
# FIND BODY BONES
# ------------------------------------------------------------

pelvis = find_bone(
    armature,
    [
        "pelvis",
        "hips",
        "root"
    ]
)

spine = find_bone(
    armature,
    [
        "spine",
        "spine.001"
    ]
)

thigh_L = find_bone(
    armature,
    [
        "thigh.L",
        "upper_leg.L",
        "thigh_fk.L"
    ]
)

thigh_R = find_bone(
    armature,
    [
        "thigh.R",
        "upper_leg.R",
        "thigh_fk.R"
    ]
)

shin_L = find_bone(
    armature,
    [
        "shin.L",
        "lower_leg.L",
        "shin_fk.L"
    ]
)

shin_R = find_bone(
    armature,
    [
        "shin.R",
        "lower_leg.R",
        "shin_fk.R"
    ]
)

foot_L = find_bone(
    armature,
    [
        "foot.L",
        "ankle.L",
        "foot_fk.L"
    ]
)

foot_R = find_bone(
    armature,
    [
        "foot.R",
        "ankle.R",
        "foot_fk.R"
    ]
)

upper_arm_L = find_bone(
    armature,
    [
        "upper_arm.L",
        "upperarm.L",
        "upper_arm_fk.L"
    ]
)

upper_arm_R = find_bone(
    armature,
    [
        "upper_arm.R",
        "upperarm.R",
        "upper_arm_fk.R"
    ]
)

forearm_L = find_bone(
    armature,
    [
        "forearm.L",
        "lower_arm.L",
        "forearm_fk.L"
    ]
)

forearm_R = find_bone(
    armature,
    [
        "forearm.R",
        "lower_arm.R",
        "forearm_fk.R"
    ]
)


# ------------------------------------------------------------
# REPORT BONE DISCOVERY
# ------------------------------------------------------------

print("")
print("========== BONE DISCOVERY ==========")

bones = {
    "pelvis": pelvis,
    "spine": spine,
    "thigh_L": thigh_L,
    "thigh_R": thigh_R,
    "shin_L": shin_L,
    "shin_R": shin_R,
    "foot_L": foot_L,
    "foot_R": foot_R,
    "upper_arm_L": upper_arm_L,
    "upper_arm_R": upper_arm_R,
    "forearm_L": forearm_L,
    "forearm_R": forearm_R,
}

for label, bone in bones.items():

    if bone:
        print(
            f"{label:15s} -> {bone.name}"
        )

    else:
        print(
            f"{label:15s} -> NOT FOUND"
        )


# ------------------------------------------------------------
# WALK POSE 1
# LEFT FOOT FORWARD
# Frame 1
# ------------------------------------------------------------

frame = FRAME_CONTACT_L

# Left leg forward
set_rotation(
    thigh_L,
    frame,
    x=28
)

set_rotation(
    shin_L,
    frame,
    x=-5
)

set_rotation(
    foot_L,
    frame,
    x=-10
)


# Right leg backward
set_rotation(
    thigh_R,
    frame,
    x=-22
)

set_rotation(
    shin_R,
    frame,
    x=28
)

set_rotation(
    foot_R,
    frame,
    x=8
)


# Arm counter swing
set_rotation(
    upper_arm_L,
    frame,
    x=-18
)

set_rotation(
    upper_arm_R,
    frame,
    x=18
)

set_rotation(
    forearm_L,
    frame,
    x=-8
)

set_rotation(
    forearm_R,
    frame,
    x=-8
)


# Pelvis / spine
set_rotation(
    pelvis,
    frame,
    z=-3
)

set_rotation(
    spine,
    frame,
    z=2
)


# ------------------------------------------------------------
# WALK POSE 2
# PASSING
# Frame 9
# ------------------------------------------------------------

frame = FRAME_PASS_R

set_rotation(
    thigh_L,
    frame,
    x=5
)

set_rotation(
    shin_L,
    frame,
    x=-25
)

set_rotation(
    foot_L,
    frame,
    x=8
)

set_rotation(
    thigh_R,
    frame,
    x=8
)

set_rotation(
    shin_R,
    frame,
    x=-5
)

set_rotation(
    foot_R,
    frame,
    x=-5
)


set_rotation(
    upper_arm_L,
    frame,
    x=-5
)

set_rotation(
    upper_arm_R,
    frame,
    x=5
)

set_rotation(
    forearm_L,
    frame,
    x=-5
)

set_rotation(
    forearm_R,
    frame,
    x=-5
)


set_rotation(
    pelvis,
    frame,
    z=0
)

set_rotation(
    spine,
    frame,
    z=0
)


# ------------------------------------------------------------
# WALK POSE 3
# RIGHT FOOT FORWARD
# Frame 17
# ------------------------------------------------------------

frame = FRAME_CONTACT_R

set_rotation(
    thigh_L,
    frame,
    x=-22
)

set_rotation(
    shin_L,
    frame,
    x=28
)

set_rotation(
    foot_L,
    frame,
    x=8
)

set_rotation(
    thigh_R,
    frame,
    x=28
)

set_rotation(
    shin_R,
    frame,
    x=-5
)

set_rotation(
    foot_R,
    frame,
    x=-10
)


set_rotation(
    upper_arm_L,
    frame,
    x=18
)

set_rotation(
    upper_arm_R,
    frame,
    x=-18
)

set_rotation(
    forearm_L,
    frame,
    x=-8
)

set_rotation(
    forearm_R,
    frame,
    x=-8
)


set_rotation(
    pelvis,
    frame,
    z=3
)

set_rotation(
    spine,
    frame,
    z=-2
)


# ------------------------------------------------------------
# WALK POSE 4
# PASSING
# Frame 25
# ------------------------------------------------------------

frame = FRAME_PASS_L

set_rotation(
    thigh_L,
    frame,
    x=8
)

set_rotation(
    shin_L,
    frame,
    x=-5
)

set_rotation(
    foot_L,
    frame,
    x=-5
)

set_rotation(
    thigh_R,
    frame,
    x=5
)

set_rotation(
    shin_R,
    frame,
    x=-25
)

set_rotation(
    foot_R,
    frame,
    x=8
)


set_rotation(
    upper_arm_L,
    frame,
    x=5
)

set_rotation(
    upper_arm_R,
    frame,
    x=-5
)

set_rotation(
    forearm_L,
    frame,
    x=-5
)

set_rotation(
    forearm_R,
    frame,
    x=-5
)


set_rotation(
    pelvis,
    frame,
    z=0
)

set_rotation(
    spine,
    frame,
    z=0
)


# ------------------------------------------------------------
# WALK POSE 5
# RETURN TO FIRST POSE
# Frame 33
# ------------------------------------------------------------

frame = FRAME_END

set_rotation(
    thigh_L,
    frame,
    x=28
)

set_rotation(
    shin_L,
    frame,
    x=-5
)

set_rotation(
    foot_L,
    frame,
    x=-10
)

set_rotation(
    thigh_R,
    frame,
    x=-22
)

set_rotation(
    shin_R,
    frame,
    x=28
)

set_rotation(
    foot_R,
    frame,
    x=8
)


set_rotation(
    upper_arm_L,
    frame,
    x=-18
)

set_rotation(
    upper_arm_R,
    frame,
    x=18
)

set_rotation(
    forearm_L,
    frame,
    x=-8
)

set_rotation(
    forearm_R,
    frame,
    x=-8
)


set_rotation(
    pelvis,
    frame,
    z=-3
)

set_rotation(
    spine,
    frame,
    z=2
)


# ------------------------------------------------------------
# FRAME SETTINGS
# ------------------------------------------------------------

scene = bpy.context.scene

scene.render.fps = FPS

scene.frame_start = FRAME_START

scene.frame_end = FRAME_END

scene.frame_set(FRAME_START)


# ------------------------------------------------------------
# ACTION SETTINGS
# ------------------------------------------------------------

action.frame_start = FRAME_START

action.frame_end = FRAME_END

armature.animation_data.action = action
armature.animation_data.action_slot = action_slot
bpy.context.view_layer.update()


# ------------------------------------------------------------
# RETURN TO OBJECT MODE
# ------------------------------------------------------------

bpy.ops.object.mode_set(mode='OBJECT')


# ------------------------------------------------------------
# FINAL REPORT
# ------------------------------------------------------------

print("")
print("==========================================")
print("AXION WALK FORWARD - COMPLETE")
print("==========================================")

print("Armature :", armature.name)

print("Action   :", action.name)

print(
    "Frames   :",
    FRAME_START,
    "-",
    FRAME_END
)

print("FPS      :", FPS)

print("==========================================")
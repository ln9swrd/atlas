import bpy
import math

# ============================================================
# AXION IDLE — Blender 5.2
# ============================================================

ARMATURE_NAME = "axion_metarig"
ACTION_NAME = "axion_Idle"

START_FRAME = 1
MID_FRAME = 31
END_FRAME = 61


# ============================================================
# BONE MAP
# ============================================================

BONES = {
    "spine": "spine",
    "chest": "spine.003",

    "upper_arm_L": "upper_arm.L",
    "forearm_L": "forearm.L",

    "upper_arm_R": "upper_arm.R",
    "forearm_R": "forearm.R",

    "thigh_L": "thigh.L",
    "shin_L": "shin.L",
    "foot_L": "foot.L",

    "thigh_R": "thigh.R",
    "shin_R": "shin.R",
    "foot_R": "foot.R",
}


# ============================================================
# FIND ARMATURE
# ============================================================

armature = bpy.data.objects.get(ARMATURE_NAME)

if armature is None:
    raise RuntimeError(
        f"Armature not found: {ARMATURE_NAME}"
    )

if armature.type != 'ARMATURE':
    raise RuntimeError(
        f"Object is not an ARMATURE: {ARMATURE_NAME}"
    )


# ============================================================
# VERIFY BONES
# ============================================================

missing = []

for key, bone_name in BONES.items():
    if armature.pose.bones.get(bone_name) is None:
        missing.append(
            f"{key} -> {bone_name}"
        )

if missing:
    raise RuntimeError(
        "Missing required bones:\n" +
        "\n".join(missing)
    )


# ============================================================
# CREATE OR REUSE ACTION
# ============================================================

existing = bpy.data.actions.get(ACTION_NAME)

print(f"Action before: {existing.name if existing else None}")
print(
    "Active Action before:",
    armature.animation_data.action.name
    if armature.animation_data and armature.animation_data.action
    else None
)
print(
    "Active Slot before:",
    armature.animation_data.action_slot.identifier
    if armature.animation_data and armature.animation_data.action_slot
    else None
)

action = existing or bpy.data.actions.new(ACTION_NAME)

armature.animation_data_create()

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

armature.animation_data.action = action
armature.animation_data.action_slot = action_slot

print("Created Action:", action.name)
print("Active Action after assignment:", armature.animation_data.action.name)
print("Active Slot after assignment:", armature.animation_data.action_slot.identifier)


def activate_action_channel():

    armature.animation_data.action = action
    armature.animation_data.action_slot = action_slot


# ============================================================
# BONE ACCESS
# ============================================================

def get_bone(key):

    bone_name = BONES.get(key, key)

    pb = armature.pose.bones.get(bone_name)

    if pb is None:
        raise RuntimeError(
            f"Bone not found: {key} -> {bone_name}"
        )

    return pb


# ============================================================
# ROTATION
# ============================================================

def set_rotation(
    bone_key,
    frame,
    x=0.0,
    y=0.0,
    z=0.0
):

    pb = get_bone(bone_key)

    pb.rotation_mode = 'XYZ'

    pb.rotation_euler = (
        math.radians(x),
        math.radians(y),
        math.radians(z)
    )

    activate_action_channel()

    pb.keyframe_insert(
        data_path="rotation_euler",
        frame=frame
    )


# ============================================================
# LOCATION
# ============================================================

def set_location(
    bone_key,
    frame,
    x=0.0,
    y=0.0,
    z=0.0
):

    pb = get_bone(bone_key)

    pb.location = (x, y, z)

    activate_action_channel()

    pb.keyframe_insert(
        data_path="location",
        frame=frame
    )


# ============================================================
# RESET RELEVANT BONES
# ============================================================

for bone_name in BONES.values():

    pb = armature.pose.bones.get(bone_name)

    if pb is None:
        continue

    pb.rotation_mode = 'XYZ'

    pb.rotation_euler = (
        0.0,
        0.0,
        0.0
    )

    pb.location = (
        0.0,
        0.0,
        0.0
    )


# ============================================================
# FRAME 1
# NEUTRAL IDLE
# ============================================================

f = START_FRAME

# Upper body
set_rotation("spine", f, 0.0, 0.0, -1.0)
set_rotation("chest", f, 0.0, 0.0, -1.0)

# Left arm
set_rotation("upper_arm_L", f, 16.0, 0.0, -4.0)
set_rotation("forearm_L", f, -8.0, 0.0, 0.0)

# Right arm
set_rotation("upper_arm_R", f, 16.0, 0.0, 4.0)
set_rotation("forearm_R", f, -8.0, 0.0, 0.0)

# Left leg
set_rotation("thigh_L", f, 0.0, 0.0, 0.0)
set_rotation("shin_L", f, 0.0, 0.0, 0.0)
set_rotation("foot_L", f, 0.0, 0.0, 0.0)

# Right leg
set_rotation("thigh_R", f, 0.0, 0.0, 0.0)
set_rotation("shin_R", f, 0.0, 0.0, 0.0)
set_rotation("foot_R", f, 0.0, 0.0, 0.0)

# Center
set_location("spine", f, 0.0, 0.0, 0.0)


# ============================================================
# FRAME 31
# SMALL WEIGHT SHIFT
# ============================================================

f = MID_FRAME

# Upper body
set_rotation("spine", f, 0.5, 0.0, 1.0)
set_rotation("chest", f, -0.5, 0.0, 1.0)

# Left arm
set_rotation("upper_arm_L", f, 15.0, 0.0, -5.0)
set_rotation("forearm_L", f, -8.0, 0.0, 0.0)

# Right arm
set_rotation("upper_arm_R", f, 17.0, 0.0, 5.0)
set_rotation("forearm_R", f, -8.0, 0.0, 0.0)

# Legs
set_rotation("thigh_L", f, -1.5, 0.0, 0.0)
set_rotation("thigh_R", f, 1.5, 0.0, 0.0)

# Small vertical movement
set_location("spine", f, 0.0, 0.0, 0.005)


# ============================================================
# FRAME 61
# EXACT LOOP RETURN
# ============================================================

f = END_FRAME

# Upper body
set_rotation("spine", f, 0.0, 0.0, -1.0)
set_rotation("chest", f, 0.0, 0.0, -1.0)

# Left arm
set_rotation("upper_arm_L", f, 16.0, 0.0, -4.0)
set_rotation("forearm_L", f, -8.0, 0.0, 0.0)

# Right arm
set_rotation("upper_arm_R", f, 16.0, 0.0, 4.0)
set_rotation("forearm_R", f, -8.0, 0.0, 0.0)

# Left leg
set_rotation("thigh_L", f, 0.0, 0.0, 0.0)
set_rotation("shin_L", f, 0.0, 0.0, 0.0)
set_rotation("foot_L", f, 0.0, 0.0, 0.0)

# Right leg
set_rotation("thigh_R", f, 0.0, 0.0, 0.0)
set_rotation("shin_R", f, 0.0, 0.0, 0.0)
set_rotation("foot_R", f, 0.0, 0.0, 0.0)

# Center
set_location("spine", f, 0.0, 0.0, 0.0)


# ============================================================
# TIMELINE
# ============================================================

bpy.context.scene.frame_start = START_FRAME
bpy.context.scene.frame_end = END_FRAME
bpy.context.scene.frame_set(START_FRAME)

armature.animation_data.action = action
armature.animation_data.action_slot = action_slot
bpy.context.view_layer.update()


# ============================================================
# VERIFICATION
# ============================================================

if bpy.data.actions.get(ACTION_NAME) is None:
    raise RuntimeError(
        "axion_Idle was not created."
    )

if armature.animation_data is None:
    raise RuntimeError(
        "Animation data was not created."
    )

if armature.animation_data.action != action:
    raise RuntimeError(
        "axion_Idle is not the active Action."
    )


# ============================================================
# FINAL REPORT
# ============================================================

print("")
print("========================================")
print("AXION IDLE READY")
print("========================================")
print(f"Armature : {armature.name}")
print(f"Action   : {action.name}")
print(f"Frames   : {START_FRAME} - {END_FRAME}")
print(f"FPS      : {bpy.context.scene.render.fps}")
print(f"Users    : {action.users}")
print(f"Slots    : {len(action.slots)}")
print(f"Layers   : {len(action.layers)}")
print(f"Strips   : {sum(len(layer.strips) for layer in action.layers)}")
print("Status         : PASS")
print("========================================")
print("")

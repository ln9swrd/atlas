import bpy


# ============================================================
# AXION WALK -> POSE ASSETS
# SAFE REPLACE VERSION
# Blender 5.2.0 LTS
# ============================================================
#
# 목적:
#   수정된 axion_Walk Forward의 4개 핵심 포즈를
#   기존 Pose Asset과 교체한다.
#
# 교체 대상:
#   AXION_Walk_Contact_L
#   AXION_Walk_Passing_R
#   AXION_Walk_Contact_R
#   AXION_Walk_Passing_L
#
# 보호:
#   axion_Walk Forward
#   그 외 모든 Action
#   Mesh
#   Armature / Bone
#   Rig
#
# 기존 Pose Asset은 동일 이름일 경우에만 삭제 후 재생성한다.
#
# Blender 5.2 confirmed operator:
#
#   bpy.ops.poselib.create_pose_asset(
#       pose_name=...
#   )
#
# ============================================================


# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

ARMATURE_NAME = "axion_metarig"

SOURCE_ACTION_NAME = "axion_Walk Forward"


POSES = [
    (1,  "AXION_Walk_Contact_L"),
    (9,  "AXION_Walk_Passing_R"),
    (17, "AXION_Walk_Contact_R"),
    (25, "AXION_Walk_Passing_L"),
]


# ------------------------------------------------------------
# EXACT AXION MOVEMENT BONES
# ------------------------------------------------------------

AXION_WALK_BONES = [
    "spine",
    "spine.003",

    "upper_arm.L",
    "forearm.L",
    "hand.L",

    "upper_arm.R",
    "forearm.R",
    "hand.R",

    "thigh.L",
    "shin.L",
    "foot.L",

    "thigh.R",
    "shin.R",
    "foot.R",
]


# ------------------------------------------------------------
# SAFETY:
# ONLY THESE ACTIONS MAY BE REPLACED
# ------------------------------------------------------------

ALLOWED_REPLACEMENTS = {
    "AXION_Walk_Contact_L",
    "AXION_Walk_Passing_R",
    "AXION_Walk_Contact_R",
    "AXION_Walk_Passing_L",
}


# ------------------------------------------------------------
# FIND ARMATURE
# ------------------------------------------------------------

def find_armature():

    obj = bpy.data.objects.get(
        ARMATURE_NAME
    )

    if obj is None:

        raise RuntimeError(
            "Armature not found: "
            + ARMATURE_NAME
        )

    if obj.type != 'ARMATURE':

        raise RuntimeError(
            "Object is not an armature: "
            + ARMATURE_NAME
        )

    return obj


# ------------------------------------------------------------
# FIND SOURCE ACTION
# ------------------------------------------------------------

def find_source_action():

    action = bpy.data.actions.get(
        SOURCE_ACTION_NAME
    )

    if action is None:

        raise RuntimeError(
            "Source Action not found: "
            + SOURCE_ACTION_NAME
        )

    return action


# ------------------------------------------------------------
# VERIFY AXION BONES
# ------------------------------------------------------------

def verify_axion_bones(armature):

    missing = []

    for bone_name in AXION_WALK_BONES:

        if armature.pose.bones.get(
            bone_name
        ) is None:

            missing.append(
                bone_name
            )

    if missing:

        raise RuntimeError(
            "Missing AXION bones:\n"
            + "\n".join(missing)
        )

    print(
        "[OK] AXION movement bones:",
        len(AXION_WALK_BONES)
    )


# ------------------------------------------------------------
# ACTIVATE ARMATURE
# ------------------------------------------------------------

def activate_armature(armature):

    if armature.mode != 'OBJECT':

        bpy.ops.object.mode_set(
            mode='OBJECT'
        )

    bpy.ops.object.select_all(
        action='DESELECT'
    )

    armature.select_set(
        True
    )

    bpy.context.view_layer.objects.active = (
        armature
    )


# ------------------------------------------------------------
# ENTER POSE MODE
# ------------------------------------------------------------

def enter_pose_mode(armature):

    activate_armature(
        armature
    )

    bpy.ops.object.mode_set(
        mode='POSE'
    )


# ------------------------------------------------------------
# SELECT POSE BONES
# ------------------------------------------------------------
#
# Blender 5.2:
#
# Do not use:
#   bone.select
#   bone.select_set()
#
# Use the Pose operator.
#
# ------------------------------------------------------------

def select_pose_bones():

    bpy.ops.pose.select_all(
        action='DESELECT'
    )

    bpy.ops.pose.select_all(
        action='SELECT'
    )

    selected = bpy.context.selected_pose_bones

    if not selected:

        raise RuntimeError(
            "No Pose Bones selected."
        )

    print(
        "[OK] Selected Pose Bones:",
        len(selected)
    )

    return selected


# ------------------------------------------------------------
# DELETE ONLY ONE EXISTING POSE ASSET
# ------------------------------------------------------------
#
# CRITICAL SAFETY:
#
# This function can ONLY delete one of the four explicitly
# allowed Pose Asset names.
#
# It will NEVER delete:
#   axion_Walk Forward
#   another Action
#   another Asset
#
# ------------------------------------------------------------

def replace_existing_pose_asset(
    pose_name
):

    if pose_name not in ALLOWED_REPLACEMENTS:

        raise RuntimeError(
            "SAFETY STOP: Attempted replacement "
            "outside allowed Pose Asset list:\n"
            + pose_name
        )


    existing = bpy.data.actions.get(
        pose_name
    )

    if existing is None:

        print(
            "[INFO] No existing asset:",
            pose_name
        )

        return


    # --------------------------------------------------------
    # Never allow source Action deletion
    # --------------------------------------------------------

    if existing.name == SOURCE_ACTION_NAME:

        raise RuntimeError(
            "SAFETY STOP: Source Action cannot be deleted."
        )


    # --------------------------------------------------------
    # Check that this is actually an Asset
    # --------------------------------------------------------

    if existing.asset_data is None:

        raise RuntimeError(
            "SAFETY STOP: Action exists with requested "
            "Pose Asset name but is not an Asset:\n"
            + pose_name
        )


    print(
        "[REPLACE] Removing existing Pose Asset:",
        pose_name
    )


    # --------------------------------------------------------
    # Remove ONLY this Action
    # --------------------------------------------------------

    bpy.data.actions.remove(
        existing
    )


    # --------------------------------------------------------
    # Verify removal
    # --------------------------------------------------------

    if bpy.data.actions.get(
        pose_name
    ) is not None:

        raise RuntimeError(
            "Failed to remove existing Pose Asset:\n"
            + pose_name
        )


# ------------------------------------------------------------
# CREATE POSE ASSET
# ------------------------------------------------------------

def create_pose_asset(
    armature,
    source_action,
    frame,
    pose_name
):

    print("")
    print("------------------------------------------")
    print("Creating Pose Asset")
    print("Name :", pose_name)
    print("Frame:", frame)
    print("------------------------------------------")


    # --------------------------------------------------------
    # Safety
    # --------------------------------------------------------

    if pose_name not in ALLOWED_REPLACEMENTS:

        raise RuntimeError(
            "Pose name is not in replacement whitelist:\n"
            + pose_name
        )


    # --------------------------------------------------------
    # Source Action
    # --------------------------------------------------------

    if armature.animation_data is None:

        armature.animation_data_create()


    armature.animation_data.action = (
        source_action
    )


    # --------------------------------------------------------
    # Evaluate frame
    # --------------------------------------------------------

    bpy.context.scene.frame_set(
        frame
    )

    bpy.context.view_layer.update()


    # --------------------------------------------------------
    # Select Pose Bones
    # --------------------------------------------------------

    selected = select_pose_bones()


    print(
        "Selected bones:",
        len(selected)
    )


    # --------------------------------------------------------
    # Replace old Pose Asset
    # --------------------------------------------------------

    replace_existing_pose_asset(
        pose_name
    )


    # --------------------------------------------------------
    # Create new Pose Asset
    #
    # Blender 5.2 API
    # --------------------------------------------------------

    result = bpy.ops.poselib.create_pose_asset(
        pose_name=pose_name
    )


    print(
        "Operator result:",
        result
    )


    # --------------------------------------------------------
    # Find newly created Action
    # --------------------------------------------------------

    new_action = bpy.data.actions.get(
        pose_name
    )


    if new_action is None:

        raise RuntimeError(
            "Pose Asset was not created:\n"
            + pose_name
        )


    # --------------------------------------------------------
    # Verify Asset
    # --------------------------------------------------------

    if new_action.asset_data is None:

        raise RuntimeError(
            "Action created but is not an Asset:\n"
            + pose_name
        )


    print(
        "[OK] Created:",
        new_action.name
    )

    print(
        "     Asset:",
        new_action.asset_data is not None
    )


    return new_action


# ============================================================
# MAIN
# ============================================================

print("")
print("==========================================")
print("AXION WALK POSE ASSET SAFE REPLACEMENT")
print("Blender:", bpy.app.version_string)
print("==========================================")


# ------------------------------------------------------------
# Save current state
# ------------------------------------------------------------

scene = bpy.context.scene

original_frame = (
    scene.frame_current
)


original_object = (
    bpy.context.object
)


original_mode = None

if original_object is not None:

    original_mode = (
        original_object.mode
    )


# ------------------------------------------------------------
# Find armature
# ------------------------------------------------------------

armature = find_armature()

print(
    "[OK] Armature:",
    armature.name
)


# ------------------------------------------------------------
# Find source Action
# ------------------------------------------------------------

source_action = find_source_action()

print(
    "[OK] Source Action:",
    source_action.name
)


# ------------------------------------------------------------
# SOURCE ACTION SAFETY
# ------------------------------------------------------------

if source_action.name in ALLOWED_REPLACEMENTS:

    raise RuntimeError(
        "SAFETY STOP: Source Action has a Pose Asset name."
    )


# ------------------------------------------------------------
# Verify source Action exists
# ------------------------------------------------------------

if bpy.data.actions.get(
    SOURCE_ACTION_NAME
) is not source_action:

    raise RuntimeError(
        "Source Action verification failed."
    )


# ------------------------------------------------------------
# Verify AXION bones
# ------------------------------------------------------------

verify_axion_bones(
    armature
)


# ------------------------------------------------------------
# Activate armature
# ------------------------------------------------------------

activate_armature(
    armature
)


# ------------------------------------------------------------
# Pose Mode
# ------------------------------------------------------------

enter_pose_mode(
    armature
)


# ------------------------------------------------------------
# Create / Replace 4 Pose Assets
# ------------------------------------------------------------

created_assets = []


try:

    for frame, pose_name in POSES:

        asset = create_pose_asset(
            armature=armature,
            source_action=source_action,
            frame=frame,
            pose_name=pose_name
        )

        created_assets.append(
            asset.name
        )


finally:

    # --------------------------------------------------------
    # Restore SOURCE ACTION
    # --------------------------------------------------------

    if armature.animation_data is None:

        armature.animation_data_create()

    armature.animation_data.action = (
        source_action
    )


    # --------------------------------------------------------
    # Restore Object Mode
    # --------------------------------------------------------

    if armature.mode == 'POSE':

        bpy.ops.object.mode_set(
            mode='OBJECT'
        )


    # --------------------------------------------------------
    # Restore Frame
    # --------------------------------------------------------

    scene.frame_set(
        original_frame
    )


# ============================================================
# FINAL SAFETY VERIFICATION
# ============================================================

print("")
print("==========================================")
print("FINAL VERIFICATION")
print("==========================================")


# ------------------------------------------------------------
# Source Action
# ------------------------------------------------------------

source_check = bpy.data.actions.get(
    SOURCE_ACTION_NAME
)


if source_check is source_action:

    print(
        "[OK] Source Action preserved:",
        SOURCE_ACTION_NAME
    )

else:

    print(
        "[FAIL] Source Action verification failed"
    )


# ------------------------------------------------------------
# Verify exactly four assets
# ------------------------------------------------------------

for name in ALLOWED_REPLACEMENTS:

    action = bpy.data.actions.get(
        name
    )

    if action is None:

        print(
            "[FAIL]",
            name
        )

    elif action.asset_data is None:

        print(
            "[FAIL] Not Asset:",
            name
        )

    else:

        print(
            "[OK]",
            name
        )


# ------------------------------------------------------------
# Verify no unexpected deletion
# ------------------------------------------------------------

print("")
print(
    "Total Actions:",
    len(bpy.data.actions)
)


print("")
print("Created / Replaced:")

for name in created_assets:

    print(
        " -",
        name
    )


print("")
print("==========================================")
print("DONE")
print("==========================================")
import bpy


# ============================================================
# ARMATURE INFORMATION EXTRACTOR
# ============================================================
#
# Purpose:
#     Read-only inspection of Blender Armature.
#
# Output:
#     Blender System Console / Scripting Console
#
# No mesh modification
# No bone modification
# No rig modification
# No action modification
# No asset modification
# No file save
# ============================================================


ARMATURE_NAME = "axion_metarig"


# ------------------------------------------------------------
# FIND ARMATURE
# ------------------------------------------------------------

def find_armature():

    obj = bpy.data.objects.get(ARMATURE_NAME)

    if obj is not None and obj.type == "ARMATURE":
        return obj

    for obj in bpy.context.scene.objects:

        if obj.type == "ARMATURE":
            return obj

    return None


# ------------------------------------------------------------
# PRINT HEADER
# ------------------------------------------------------------

def header(title):

    print("")
    print("=" * 70)
    print(title)
    print("=" * 70)


# ------------------------------------------------------------
# ARMATURE OBJECT INFO
# ------------------------------------------------------------

def print_armature_info(armature):

    header("ARMATURE OBJECT")

    print("Object Name      :", armature.name)
    print("Object Type      :", armature.type)
    print("Data Name        :", armature.data.name)
    print("Mode             :", armature.mode)
    print("Visible          :", armature.visible_get())
    print("Selected         :", armature.select_get())
    print("Location         :", tuple(armature.location))
    print("Rotation         :", tuple(armature.rotation_euler))
    print("Scale            :", tuple(armature.scale))


# ------------------------------------------------------------
# ARMATURE DATA INFO
# ------------------------------------------------------------

def print_armature_data(armature):

    header("ARMATURE DATA")

    data = armature.data

    print("Armature Data    :", data.name)
    print("Bone Count       :", len(data.bones))
    print("Display Type     :", data.display_type)
    print("Pose Position    :", data.pose_position)
    print("Axes Position    :", data.axes_position)


# ------------------------------------------------------------
# BONE INFO
# ------------------------------------------------------------

def print_bone_info(armature):

    header("BONES")

    bones = armature.data.bones

    for index, bone in enumerate(bones, 1):

        parent_name = (
            bone.parent.name
            if bone.parent
            else "-"
        )

        child_names = [
            child.name
            for child in bone.children
        ]

        print("")
        print("Bone", index)
        print("  Name       :", bone.name)
        print("  Parent     :", parent_name)
        print("  Children   :", child_names)
        print("  Head       :", tuple(bone.head_local))
        print("  Tail       :", tuple(bone.tail_local))
        print("  Length     :", bone.length)
        print("  Deform     :", bone.use_deform)
        print("  Connected  :", bone.use_connect)
        print("  Hidden     :", bone.hide)


# ------------------------------------------------------------
# POSE BONE INFO
# ------------------------------------------------------------

def print_pose_bones(armature):

    header("POSE BONES")

    for index, pose_bone in enumerate(
        armature.pose.bones,
        1
    ):

        print("")
        print("Pose Bone", index)
        print("  Name       :", pose_bone.name)
        print("  Parent     :",
              pose_bone.parent.name
              if pose_bone.parent
              else "-")

        print(
            "  Rotation Mode :",
            pose_bone.rotation_mode
        )

        print(
            "  Location      :",
            tuple(pose_bone.location)
        )

        print(
            "  Rotation      :",
            tuple(pose_bone.rotation_euler)
        )

        print(
            "  Scale         :",
            tuple(pose_bone.scale)
        )


# ------------------------------------------------------------
# CONSTRAINT INFO
# ------------------------------------------------------------

def print_constraints(armature):

    header("CONSTRAINTS")

    total = 0

    for pose_bone in armature.pose.bones:

        if len(pose_bone.constraints) == 0:
            continue

        for constraint in pose_bone.constraints:

            total += 1

            print("")
            print("Bone       :", pose_bone.name)
            print("Constraint :", constraint.name)
            print("Type       :", constraint.type)

            if hasattr(constraint, "target"):
                target = constraint.target

                print(
                    "Target     :",
                    target.name
                    if target
                    else "-"
                )

            if hasattr(constraint, "subtarget"):

                print(
                    "Subtarget  :",
                    constraint.subtarget
                    if constraint.subtarget
                    else "-"
                )

    print("")
    print("Total Constraints:", total)


# ------------------------------------------------------------
# ACTION INFO
# ------------------------------------------------------------

def print_action_info(armature):

    header("CURRENT ACTION")

    if armature.animation_data is None:

        print("Animation Data : None")
        return

    action = armature.animation_data.action

    if action is None:

        print("Current Action : None")
        return

    print("Action Name     :", action.name)
    print("Action Users    :", action.users)

    if action.asset_data:

        print("Is Asset        : True")

    else:

        print("Is Asset        : False")

    print(
        "Frame Range     :",
        tuple(action.frame_range)
    )

    print(
        "Pose Markers    :",
        len(action.pose_markers)
    )

    for marker in action.pose_markers:

        print(
            "  Marker:",
            marker.name,
            "| Frame:",
            marker.frame
        )


# ------------------------------------------------------------
# ALL ACTIONS
# ------------------------------------------------------------

def print_all_actions():

    header("ALL ACTIONS IN FILE")

    actions = list(bpy.data.actions)

    print(
        "Action Count:",
        len(actions)
    )

    for index, action in enumerate(
        actions,
        1
    ):

        print("")
        print("Action", index)
        print("  Name       :", action.name)
        print("  Users      :", action.users)
        print("  Frame Range:",
              tuple(action.frame_range))

        print(
            "  Asset      :",
            action.asset_data is not None
        )


# ------------------------------------------------------------
# ACTION F-CURVE / ANIMATED BONE INFO
# ------------------------------------------------------------

def print_action_channels(armature):

    header("CURRENT ACTION CHANNELS")

    if armature.animation_data is None:

        print("No animation data.")
        return

    action = armature.animation_data.action

    if action is None:

        print("No current Action.")
        return

    print(
        "Action:",
        action.name
    )

    # Blender 4.x actions can use layers/slots.
    # We inspect the action through its RNA data
    # where available.

    try:

        for layer in action.layers:

            print("")
            print("Layer:", layer.name)

            for strip in layer.strips:

                print(
                    "  Strip:",
                    strip.name
                )

                for channelbag in strip.channelbags:

                    print(
                        "    Channel Bag:",
                        channelbag
                    )

                    for fcurve in channelbag.fcurves:

                        print(
                            "      FCurve:",
                            fcurve.data_path,
                            "| index:",
                            fcurve.array_index
                        )

    except AttributeError:

        print(
            "Layer/strip API not available "
            "in this Blender version."
        )


# ------------------------------------------------------------
# SCENE INFO
# ------------------------------------------------------------

def print_scene_info():

    header("SCENE")

    scene = bpy.context.scene

    print(
        "Scene Name      :",
        scene.name
    )

    print(
        "Current Frame   :",
        scene.frame_current
    )

    print(
        "FPS             :",
        scene.render.fps
    )

    print(
        "Start Frame     :",
        scene.frame_start
    )

    print(
        "End Frame       :",
        scene.frame_end
    )


# ============================================================
# MAIN
# ============================================================

print("")
print("")
print("############################################################")
print("# ARMATURE INFORMATION EXTRACTOR")
print("############################################################")


armature = find_armature()


if armature is None:

    raise RuntimeError(
        "Armature not found: "
        + ARMATURE_NAME
    )


print_armature_info(
    armature
)

print_armature_data(
    armature
)

print_bone_info(
    armature
)

print_pose_bones(
    armature
)

print_constraints(
    armature
)

print_action_info(
    armature
)

print_all_actions()

print_action_channels(
    armature
)

print_scene_info()


header("EXTRACTION COMPLETE")

print("Armature:", armature.name)
print("Bones   :", len(armature.data.bones))

if armature.animation_data:
    if armature.animation_data.action:
        print(
            "Action  :",
            armature.animation_data.action.name
        )
    else:
        print("Action  : None")
else:
    print("Action  : None")

print("")
print("STATUS: PASS")
print("Read-only extraction completed.")
print("")
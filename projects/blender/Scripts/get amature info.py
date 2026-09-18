import bpy

# ============================================================
# Selected Armature Structure Inspector
# READ-ONLY
# ============================================================

def inspect_selected_armature():

    obj = bpy.context.active_object

    # --------------------------------------------------------
    # Validate selection
    # --------------------------------------------------------
    if obj is None:
        print("ERROR: No active object selected.")
        return

    if obj.type != 'ARMATURE':
        print(f"ERROR: Selected object '{obj.name}' is not an Armature.")
        print(f"Object type: {obj.type}")
        return

    arm = obj
    data = arm.data

    print("\n")
    print("=" * 80)
    print("ARMATURE STRUCTURE REPORT")
    print("=" * 80)

    print(f"Armature Object : {arm.name}")
    print(f"Armature Data   : {data.name}")
    print(f"Bone Count      : {len(data.bones)}")
    print(f"Pose Bones      : {len(arm.pose.bones)}")
    print(f"Location        : {tuple(round(v, 4) for v in arm.location)}")
    print(f"Rotation Mode   : {arm.rotation_mode}")
    print("=" * 80)

    # --------------------------------------------------------
    # General object information
    # --------------------------------------------------------
    print("\n[OBJECT TRANSFORM]")

    print("Location:")
    print("  ", tuple(round(v, 4) for v in arm.location))

    print("Rotation:")
    print("  ", tuple(round(v, 4) for v in arm.rotation_euler))

    print("Scale:")
    print("  ", tuple(round(v, 4) for v in arm.scale))

    # --------------------------------------------------------
    # Bone hierarchy
    # --------------------------------------------------------
    print("\n")
    print("=" * 80)
    print("BONE HIERARCHY")
    print("=" * 80)

    def print_bone(bone, depth=0):

        indent = "    " * depth

        parent = bone.parent.name if bone.parent else "None"

        children = [child.name for child in bone.children]

        print(
            f"{indent}- {bone.name}"
            f" | parent={parent}"
            f" | children={children}"
        )

        print(
            f"{indent}  head="
            f"{tuple(round(v, 4) for v in bone.head)}"
        )

        print(
            f"{indent}  tail="
            f"{tuple(round(v, 4) for v in bone.tail)}"
        )

        print(
            f"{indent}  length="
            f"{round(bone.length, 4)}"
        )

        print(
            f"{indent}  roll="
            f"{round(bone.roll, 4)}"
        )

        print(
            f"{indent}  use_connect="
            f"{bone.use_connect}"
        )

        for child in bone.children:
            print_bone(child, depth + 1)

    # Root bones
    root_bones = [
        bone for bone in data.bones
        if bone.parent is None
    ]

    print(f"\nRoot Bones: {len(root_bones)}")

    for root in root_bones:
        print_bone(root)

    # --------------------------------------------------------
    # Pose Bone information
    # --------------------------------------------------------
    print("\n")
    print("=" * 80)
    print("POSE BONE INFORMATION")
    print("=" * 80)

    for pb in arm.pose.bones:

        print(f"\n[{pb.name}]")

        print(f"  rotation_mode : {pb.rotation_mode}")

        print(
            "  location      : "
            + str(tuple(round(v, 4) for v in pb.location))
        )

        print(
            "  rotation_euler: "
            + str(tuple(round(v, 4) for v in pb.rotation_euler))
        )

        print(
            "  quaternion    : "
            + str(tuple(round(v, 4) for v in pb.rotation_quaternion))
        )

        print(
            "  scale         : "
            + str(tuple(round(v, 4) for v in pb.scale))
        )

        # Constraints
        if pb.constraints:
            print("  constraints:")

            for c in pb.constraints:
                print(
                    f"    - {c.name}"
                    f" | type={c.type}"
                    f" | influence={round(c.influence, 4)}"
                )

                if hasattr(c, "target") and c.target:
                    print(
                        f"      target={c.target.name}"
                    )

                if hasattr(c, "subtarget") and c.subtarget:
                    print(
                        f"      subtarget={c.subtarget}"
                    )

    # --------------------------------------------------------
    # Armature modifiers on other objects
    # --------------------------------------------------------
    print("\n")
    print("=" * 80)
    print("OBJECTS USING THIS ARMATURE")
    print("=" * 80)

    users = []

    for obj2 in bpy.data.objects:

        for modifier in obj2.modifiers:

            if modifier.type == 'ARMATURE':
                if modifier.object == arm:
                    users.append(obj2.name)

    if users:
        for name in users:
            print(f"- {name}")
    else:
        print("None")

    # --------------------------------------------------------
    # Actions
    # --------------------------------------------------------
    print("\n")
    print("=" * 80)
    print("ANIMATION DATA")
    print("=" * 80)

    if arm.animation_data:
        print(
            "Current Action:",
            arm.animation_data.action.name
            if arm.animation_data.action
            else "None"
        )

        if arm.animation_data.action:

            action = arm.animation_data.action

            print(f"Action Frame Range: {action.frame_range}")

            print(f"FCurve Count: {len(action.fcurves)}")

    else:
        print("No animation data.")

    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------
    print("\n")
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)

    print(f"Armature       : {arm.name}")
    print(f"Bone Count     : {len(data.bones)}")
    print(f"Root Bone Count: {len(root_bones)}")

    print("\nRoot Bones:")

    for bone in root_bones:
        print(f"  - {bone.name}")

    print("\nBone Names:")

    for bone in data.bones:
        print(f"  - {bone.name}")

    print("\n")
    print("=" * 80)
    print("END OF REPORT")
    print("=" * 80)


# ============================================================
# RUN
# ============================================================

inspect_selected_armature()
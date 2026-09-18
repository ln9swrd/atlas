import bpy
from mathutils import Vector


ARMATURE_NAME = "axion_metarig"


def world_head(armature, bone_name):
    bone = armature.data.bones.get(bone_name)
    if bone is None:
        raise RuntimeError(f"Required deform bone not found: {bone_name}")
    return armature.matrix_world @ bone.head_local


def add_control_bone(edit_bones, name, head, tail):
    bone = edit_bones.get(name) or edit_bones.new(name)
    bone.head = head
    bone.tail = tail
    bone.use_deform = False
    bone.parent = None
    return bone


def ensure_control_bones(armature):
    bpy.context.view_layer.objects.active = armature
    armature.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    edit_bones = armature.data.edit_bones

    controls = {
        "hand_ik.L": (world_head(armature, "hand.L"), world_head(armature, "hand.L") + armature.matrix_world.to_3x3() @ Vector((0.0, 0.0, 0.25))),
        "hand_ik.R": (world_head(armature, "hand.R"), world_head(armature, "hand.R") + armature.matrix_world.to_3x3() @ Vector((0.0, 0.0, 0.25))),
        "foot_ik.L": (world_head(armature, "foot.L"), world_head(armature, "foot.L") + armature.matrix_world.to_3x3() @ Vector((0.0, 0.0, 0.25))),
        "foot_ik.R": (world_head(armature, "foot.R"), world_head(armature, "foot.R") + armature.matrix_world.to_3x3() @ Vector((0.0, 0.0, 0.25))),
        "pole_arm.L": (world_head(armature, "forearm.L") + Vector((0.0, -0.8, 0.0)), world_head(armature, "forearm.L") + Vector((0.0, -0.8, 0.25))),
        "pole_arm.R": (world_head(armature, "forearm.R") + Vector((0.0, -0.8, 0.0)), world_head(armature, "forearm.R") + Vector((0.0, -0.8, 0.25))),
        "pole_leg.L": (world_head(armature, "shin.L") + Vector((0.0, 0.0, 0.8)), world_head(armature, "shin.L") + Vector((0.0, 0.0, 1.05))),
        "pole_leg.R": (world_head(armature, "shin.R") + Vector((0.0, 0.0, 0.8)), world_head(armature, "shin.R") + Vector((0.0, 0.0, 1.05))),
    }

    for name, (head, tail) in controls.items():
        local_head = armature.matrix_world.inverted() @ head
        local_tail = armature.matrix_world.inverted() @ tail
        add_control_bone(edit_bones, name, local_head, local_tail)

    bpy.ops.object.mode_set(mode="POSE")


def add_ik_constraint(armature, deform_name, target_name, pole_name):
    pose_bone = armature.pose.bones[deform_name]
    for constraint in list(pose_bone.constraints):
        if constraint.type == "IK" and constraint.name.startswith("AXION_IK"):
            pose_bone.constraints.remove(constraint)

    constraint = pose_bone.constraints.new("IK")
    constraint.name = f"AXION_IK_{deform_name}"
    constraint.target = armature
    constraint.subtarget = target_name
    constraint.pole_target = armature
    constraint.pole_subtarget = pole_name
    constraint.chain_count = 2
    constraint.influence = 1.0


def main():
    armature = bpy.data.objects.get(ARMATURE_NAME)
    if armature is None or armature.type != "ARMATURE":
        raise RuntimeError(f"Armature not found: {ARMATURE_NAME}")

    ensure_control_bones(armature)
    add_ik_constraint(armature, "forearm.L", "hand_ik.L", "pole_arm.L")
    add_ik_constraint(armature, "forearm.R", "hand_ik.R", "pole_arm.R")
    add_ik_constraint(armature, "shin.L", "foot_ik.L", "pole_leg.L")
    add_ik_constraint(armature, "shin.R", "foot_ik.R", "pole_leg.R")
    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.context.view_layer.update()
    bpy.ops.wm.save_as_mainfile(filepath=bpy.data.filepath)
    print("AXION_IK_APPLIED")
    print("CONTROL_BONES", [name for name in armature.data.bones.keys() if name.startswith(("hand_ik", "foot_ik", "pole_"))])
    print("IK_CONSTRAINTS", [(bone.name, constraint.name, constraint.subtarget, constraint.pole_subtarget) for bone in armature.pose.bones for constraint in bone.constraints if constraint.type == "IK"])


if __name__ == "__main__":
    main()
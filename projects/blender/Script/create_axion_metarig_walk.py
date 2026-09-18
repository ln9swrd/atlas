import bpy
from mathutils import Matrix, Quaternion, Vector


ACTION_NAME = "AXION_Metarig_Walk_TEST"
OUTPUT_FILE = "D:/Atlas/projects/blender/axion.blend"
KEY_FRAMES = (1, 5, 9, 13, 17, 21, 25, 29, 33)
REQUIRED_BONES = (
    "spine", "spine.001", "spine.002", "spine.003", "spine.004", "spine.005", "spine.006",
    "pelvis.L", "pelvis.R", "thigh.L", "thigh.R", "shin.L", "shin.R",
    "foot.L", "foot.R", "toe.L", "toe.R",
    "shoulder.L", "shoulder.R", "upper_arm.L", "upper_arm.R",
    "forearm.L", "forearm.R", "hand.L", "hand.R",
)
SIDE_PAIRS = {
    "pelvis.L": "pelvis.R", "thigh.L": "thigh.R", "shin.L": "shin.R",
    "foot.L": "foot.R", "toe.L": "toe.R", "shoulder.L": "shoulder.R",
    "upper_arm.L": "upper_arm.R", "forearm.L": "forearm.R", "hand.L": "hand.R",
}


def find_metarig():
    metarig = bpy.data.objects.get("metarig")
    if not metarig or metarig.type != "ARMATURE":
        raise RuntimeError("Target metarig object named 'metarig' was not found")
    if metarig.data.get("rig_id"):
        raise RuntimeError("Object 'metarig' has generated-rig metadata; refusing ambiguity")
    return metarig


def ensure_safe_target(metarig):
    if bpy.data.actions.get(ACTION_NAME):
        raise RuntimeError("Action already exists; refusing to overwrite: " + ACTION_NAME)
    if metarig.animation_data and (metarig.animation_data.action or metarig.animation_data.nla_tracks):
        raise RuntimeError("Metarig already has Animation Data; refusing to alter it")
    missing = [name for name in REQUIRED_BONES if not metarig.pose.bones.get(name)]
    if missing:
        raise RuntimeError("Required metarig bones are missing: " + ", ".join(missing))


def axis_index_for_world_direction(metarig, bone_name, direction):
    bone = metarig.data.bones[bone_name]
    direction = Vector(direction).normalized()
    columns = [bone.matrix_local.to_3x3().col[index].normalized() for index in range(3)]
    return max(range(3), key=lambda index: abs(columns[index].dot(direction)))


def rotate_joint(metarig, baseline, bone_name, world_axis, angle):
    index = axis_index_for_world_direction(metarig, bone_name, world_axis)
    rest_axis = metarig.data.bones[bone_name].matrix_local.to_3x3().col[index].normalized()
    signed_angle = angle if rest_axis.dot(Vector(world_axis)) >= 0.0 else -angle
    current_basis = metarig.pose.bones[bone_name].matrix_basis.copy()
    metarig.pose.bones[bone_name].matrix_basis = Matrix.Rotation(
        signed_angle, 4, "XYZ"[index]
    ) @ current_basis


def translate_joint(metarig, baseline, bone_name, world_delta):
    bone = metarig.pose.bones[bone_name]
    local_delta = metarig.data.bones[bone_name].matrix_local.to_3x3().inverted() @ Vector(world_delta)
    bone.matrix_basis = baseline[bone_name].copy()
    bone.location += local_delta


def reset_pose(metarig, baseline):
    for name in REQUIRED_BONES:
        metarig.pose.bones[name].matrix_basis = baseline[name].copy()


def world_head(metarig, name):
    return Vector(metarig.matrix_world @ metarig.pose.bones[name].head)


def rotate_bone_vector(metarig, name, target_vector):
    bone = metarig.pose.bones[name]
    world_matrix = metarig.matrix_world @ bone.matrix
    current_vector = (metarig.matrix_world @ bone.tail) - (metarig.matrix_world @ bone.head)
    delta = current_vector.rotation_difference(Vector(target_vector))
    rotation = delta.to_matrix().to_4x4()
    rotation.translation = world_matrix.translation
    bone.matrix = metarig.matrix_world.inverted() @ rotation @ Matrix.Translation(-world_matrix.translation) @ world_matrix


def local_rotation_delta(bone, axis_index, angle):
    if bone.rotation_mode != "QUATERNION":
        raise RuntimeError("FK solver requires quaternion rotation mode: " + bone.name)
    axis = Vector((1.0, 0.0, 0.0)) if axis_index == 0 else Vector((0.0, 1.0, 0.0)) if axis_index == 1 else Vector((0.0, 0.0, 1.0))
    bone.rotation_quaternion = Quaternion(axis, angle) @ bone.rotation_quaternion


def solve_rotation_step(metarig, bone_name, target, chain_names):
    bone = metarig.pose.bones[bone_name]
    base_basis = {name: metarig.pose.bones[name].matrix_basis.copy() for name in chain_names}
    current = world_head(metarig, "foot." + bone_name[-1])
    error = Vector(target) - current
    if error.length <= 0.001:
        return error.length
    jacobian = []
    epsilon = 0.0001
    for axis_index in range(3):
        for name in chain_names:
            metarig.pose.bones[name].matrix_basis = base_basis[name].copy()
        local_rotation_delta(bone, axis_index, epsilon)
        bpy.context.view_layer.update()
        displaced = world_head(metarig, "foot." + bone_name[-1])
        derivative = (displaced - current) / epsilon
        jacobian.append(derivative)
    for name in chain_names:
        metarig.pose.bones[name].matrix_basis = base_basis[name].copy()
    bpy.context.view_layer.update()

    normal = [[0.0, 0.0, 0.0] for _ in range(3)]
    rhs = [0.0, 0.0, 0.0]
    for row in range(3):
        for column in range(3):
            normal[row][column] = sum(jacobian[row][axis] * jacobian[column][axis] for axis in range(3))
        rhs[row] = sum(jacobian[row][axis] * error[axis] for axis in range(3))
        normal[row][row] += 0.0001
    matrix = Matrix(normal)
    delta_local = matrix.inverted_safe() @ Vector(rhs)
    base_error = error.length
    candidate_basis = {name: metarig.pose.bones[name].matrix_basis.copy() for name in chain_names}
    for scale in (1.0, 0.5, 0.25, 0.125, 0.0625, 0.03125):
        for name in chain_names:
            metarig.pose.bones[name].matrix_basis = candidate_basis[name].copy()
        for axis_index, angle in enumerate(delta_local):
            local_rotation_delta(bone, axis_index, max(-0.08, min(0.08, angle * scale)))
        bpy.context.view_layer.update()
        new_error = (Vector(target) - world_head(metarig, "foot." + bone_name[-1])).length
        if new_error < base_error:
            return new_error
    for name in chain_names:
        metarig.pose.bones[name].matrix_basis = candidate_basis[name].copy()
    bpy.context.view_layer.update()
    return base_error


def pin_foot(metarig, side, target):
    chain_names = ("thigh." + side, "shin." + side)
    for _ in range(20):
        solve_rotation_step(metarig, chain_names[0], target, chain_names)
        bpy.context.view_layer.update()
        solve_rotation_step(metarig, chain_names[1], target, chain_names)
        bpy.context.view_layer.update()
        if (Vector(target) - world_head(metarig, "foot." + side)).length <= 0.001:
            break


def set_arm_swing(metarig, baseline, side, forward):
    sign = 1.0 if forward else -1.0
    rotate_joint(metarig, baseline, "shoulder." + side, (1, 0, 0), -0.035 * sign)
    rotate_joint(metarig, baseline, "upper_arm." + side, (1, 0, 0), -0.22 * sign)
    rotate_joint(metarig, baseline, "forearm." + side, (1, 0, 0), 0.18 * sign)
    rotate_joint(metarig, baseline, "hand." + side, (1, 0, 0), -0.04 * sign)


def set_body(metarig, baseline, height, weight, yaw):
    translate_joint(metarig, baseline, "spine", (weight, 0.0, height))
    translate_joint(metarig, baseline, "pelvis.L", (weight * 0.35, 0.0, height))
    translate_joint(metarig, baseline, "pelvis.R", (weight * 0.35, 0.0, height))
    rotate_joint(metarig, baseline, "spine", (0, 0, 1), yaw)
    rotate_joint(metarig, baseline, "spine.001", (0, 0, 1), -yaw * 0.45)
    rotate_joint(metarig, baseline, "spine.002", (0, 0, 1), -yaw * 0.30)
    rotate_joint(metarig, baseline, "spine.003", (0, 0, 1), -yaw * 0.18)
    rotate_joint(metarig, baseline, "spine.004", (0, 0, 1), yaw * 0.06)
    rotate_joint(metarig, baseline, "spine.005", (0, 0, 1), -yaw * 0.03)


def set_leg(metarig, baseline, side, lead, passing=False, push=False):
    sign = 1.0 if lead else -1.0
    pitch = -0.16 if lead else 0.10
    if passing:
        pitch = 0.26 if not lead else -0.18
    if push:
        pitch = -0.28 if lead else 0.20
    rotate_joint(metarig, baseline, "thigh." + side, (1, 0, 0), pitch)
    rotate_joint(metarig, baseline, "shin." + side, (1, 0, 0), 0.22 if lead else -0.14)
    rotate_joint(metarig, baseline, "foot." + side, (1, 0, 0), 0.08 * sign)
    rotate_joint(metarig, baseline, "toe." + side, (1, 0, 0), 0.12 * sign)


def create_contact_pose(metarig, baseline, leading_side):
    reset_pose(metarig, baseline)
    trailing_side = "R" if leading_side == "L" else "L"
    set_leg(metarig, baseline, leading_side, True)
    set_leg(metarig, baseline, trailing_side, False)
    set_body(metarig, baseline, 0.0, 14.0 if leading_side == "L" else -14.0, 0.035 if leading_side == "L" else -0.035)
    set_arm_swing(metarig, baseline, "L", leading_side == "R")
    set_arm_swing(metarig, baseline, "R", leading_side == "L")


def create_down_pose(metarig, baseline, leading_side):
    create_contact_pose(metarig, baseline, leading_side)
    bpy.context.view_layer.update()
    support_target = world_head(metarig, "foot." + leading_side)
    set_body(metarig, baseline, -42.0, 14.0 if leading_side == "L" else -14.0, 0.025 if leading_side == "L" else -0.025)
    rotate_joint(metarig, baseline, "shin." + leading_side, (1, 0, 0), -0.16)
    pin_foot(metarig, leading_side, support_target)


def create_passing_pose(metarig, baseline, leading_side):
    create_contact_pose(metarig, baseline, leading_side)
    bpy.context.view_layer.update()
    support_target = world_head(metarig, "foot." + leading_side)
    swing_side = "R" if leading_side == "L" else "L"
    set_leg(metarig, baseline, leading_side, True, passing=False)
    set_leg(metarig, baseline, swing_side, False, passing=True)
    set_body(metarig, baseline, 0.0, 24.0 if leading_side == "L" else -24.0, 0.02 if leading_side == "L" else -0.02)
    rotate_joint(metarig, baseline, "thigh." + swing_side, (1, 0, 0), -0.30)
    rotate_joint(metarig, baseline, "shin." + swing_side, (1, 0, 0), 0.42)
    translate_joint(metarig, baseline, "foot." + swing_side, (0.0, 25.0, 85.0))
    translate_joint(metarig, baseline, "toe." + swing_side, (0.0, 25.0, 85.0))
    pin_foot(metarig, leading_side, support_target)


def create_up_pose(metarig, baseline, leading_side):
    create_contact_pose(metarig, baseline, leading_side)
    trailing_side = "R" if leading_side == "L" else "L"
    set_body(metarig, baseline, 46.0, 18.0 if leading_side == "L" else -18.0, -0.02 if leading_side == "L" else 0.02)
    set_leg(metarig, baseline, leading_side, True, push=True)
    set_leg(metarig, baseline, trailing_side, False, push=True)
    rotate_joint(metarig, baseline, "foot." + leading_side, (1, 0, 0), -0.20)
    rotate_joint(metarig, baseline, "toe." + leading_side, (1, 0, 0), -0.28)


def capture_basis(metarig):
    bpy.context.view_layer.update()
    return {name: metarig.pose.bones[name].matrix_basis.copy() for name in REQUIRED_BONES}


def mirror_basis(metarig, pose):
    reflection = Matrix(((-1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1)))
    for name, matrix in pose.items():
        mirrored_name = SIDE_PAIRS.get(name, SIDE_PAIRS.get(name.replace(".R", ".L"), name))
        metarig.pose.bones[mirrored_name].matrix_basis = reflection @ matrix @ reflection


def key_pose(metarig, frame):
    for name in REQUIRED_BONES:
        bone = metarig.pose.bones[name]
        bone.keyframe_insert(data_path="location", frame=frame, group="Metarig Walk")
        rotation_path = "rotation_quaternion" if bone.rotation_mode == "QUATERNION" else "rotation_euler"
        bone.keyframe_insert(data_path=rotation_path, frame=frame, group="Metarig Walk")
        bone.keyframe_insert(data_path="scale", frame=frame, group="Metarig Walk")


def main():
    if not bpy.data.filepath:
        raise RuntimeError("The current Blender file has not been saved")
    metarig = find_metarig()
    ensure_safe_target(metarig)
    baseline = {name: metarig.pose.bones[name].matrix_basis.copy() for name in REQUIRED_BONES}
    action = bpy.data.actions.new(ACTION_NAME)
    action.use_fake_user = True
    metarig.animation_data_create()
    metarig.animation_data.action = action

    left_pose_functions = {1: create_contact_pose, 5: create_down_pose, 9: create_passing_pose, 13: create_up_pose}
    left_poses = {}
    for frame, pose_function in left_pose_functions.items():
        bpy.context.scene.frame_set(frame)
        pose_function(metarig, baseline, "L")
        bpy.context.view_layer.update()
        left_poses[frame] = capture_basis(metarig)
        key_pose(metarig, frame)

    for frame, source_frame in ((17, 1), (21, 5), (25, 9), (29, 13)):
        bpy.context.scene.frame_set(frame)
        mirror_basis(metarig, left_poses[source_frame])
        bpy.context.view_layer.update()
        key_pose(metarig, frame)

    bpy.context.scene.frame_set(33)
    for name, matrix in left_poses[1].items():
        metarig.pose.bones[name].matrix_basis = matrix.copy()
    bpy.context.view_layer.update()
    key_pose(metarig, 33)

    action.frame_start = 1
    action.frame_end = 33
    bpy.context.scene.render.fps = 30
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 33
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_FILE)
    print("AXION_METARIG_WALK_CREATED", metarig.name, ACTION_NAME, "frames=1..33", "fps=30")


main()
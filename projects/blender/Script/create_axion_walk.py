import bpy
from mathutils import Matrix, Vector


ACTION_NAME = "AXION_Walk_Forward_TEST"
OUTPUT_FILE = "D:/Atlas/projects/blender/axion.blend"
KEY_FRAMES = (1, 5, 9, 13, 17, 21, 25, 29, 33)
REQUIRED_CONTROLS = (
    "root", "hips", "torso", "chest", "neck", "head",
    "foot_ik.L", "foot_ik.R", "toe_ik.L", "toe_ik.R",
    "thigh_ik_target.L", "thigh_ik_target.R",
    "hand_ik.L", "hand_ik.R",
    "upper_arm_ik_target.L", "upper_arm_ik_target.R",
)


def find_generated_rig():
    candidates = [
        obj for obj in bpy.data.objects
        if obj.type == "ARMATURE" and obj.data.get("rig_id")
    ]
    if len(candidates) != 1:
        raise RuntimeError(
            "Expected exactly one Rigify generated rig, found: "
            + ", ".join(obj.name for obj in candidates)
        )
    return candidates[0]


def ensure_safe_target(rig):
    if bpy.data.actions.get(ACTION_NAME):
        raise RuntimeError("Action already exists; refusing to overwrite: " + ACTION_NAME)
    if rig.animation_data and rig.animation_data.nla_tracks:
        raise RuntimeError("Target rig has NLA tracks; refusing to alter animation data")
    missing = [name for name in REQUIRED_CONTROLS if not rig.pose.bones.get(name)]
    if missing:
        raise RuntimeError("Required Rigify controls are missing: " + ", ".join(missing))


def world_matrix(rig, bone):
    return rig.matrix_world @ bone.matrix


def set_world_matrix(rig, bone, matrix):
    bone.matrix = rig.matrix_world.inverted() @ matrix


def set_world_position(rig, name, position):
    bone = rig.pose.bones[name]
    matrix = world_matrix(rig, bone)
    matrix.translation = Vector(position)
    set_world_matrix(rig, bone, matrix)


def rotate_world(rig, name, axis, angle):
    bone = rig.pose.bones[name]
    matrix = world_matrix(rig, bone)
    origin = matrix.translation.copy()
    rotation = Matrix.Rotation(angle, 4, axis)
    rotated = Matrix.Translation(origin) @ rotation @ Matrix.Translation(-origin) @ matrix
    set_world_matrix(rig, bone, rotated)


def reset_pose(rig, reference):
    for name in REQUIRED_CONTROLS:
        set_world_matrix(rig, rig.pose.bones[name], reference[name].copy())


def point(reference, name):
    return reference[name].translation.copy()


def mirrored_point(reference, name, center_x):
    value = point(reference, name)
    value.x = 2.0 * center_x - value.x
    return value


def set_foot(rig, side, position, lift=0.0):
    foot_position = Vector(position)
    foot_position.z += lift
    set_world_position(rig, "foot_ik." + side, foot_position)
    set_world_position(rig, "toe_ik." + side, foot_position + Vector((0.0, 55.0, 0.0)))


def set_knee_pole(rig, side, hip_position, foot_position, swing=False):
    midpoint = (Vector(hip_position) + Vector(foot_position)) * 0.5
    pole = midpoint + Vector((0.0, -620.0, 0.0))
    if swing:
        pole += Vector((0.0, 180.0, 45.0))
    set_world_position(rig, "thigh_ik_target." + side, pole)


def set_arm(rig, side, hand_position, swing_forward):
    hand = Vector(hand_position)
    hand.y += 90.0 if swing_forward else -90.0
    hand.z += 20.0 if swing_forward else -10.0
    set_world_position(rig, "hand_ik." + side, hand)
    shoulder = world_matrix(rig, rig.pose.bones["shoulder." + side]).translation.copy()
    elbow = (shoulder + hand) * 0.5
    elbow.y += 180.0 if swing_forward else -180.0
    set_world_position(rig, "upper_arm_ik_target." + side, elbow)


def set_body(rig, reference, pelvis_height, weight_x, rotation_z):
    hips = point(reference, "hips") + Vector((weight_x, 0.0, pelvis_height))
    set_world_position(rig, "hips", hips)
    rotate_world(rig, "hips", "Z", rotation_z)
    rotate_world(rig, "torso", "Z", -rotation_z * 0.45)
    rotate_world(rig, "chest", "Z", -rotation_z * 0.30)
    rotate_world(rig, "neck", "Z", rotation_z * 0.08)
    rotate_world(rig, "head", "Z", -rotation_z * 0.04)


def create_contact_pose(rig, reference, leading_side):
    reset_pose(rig, reference)
    center_x = (point(reference, "foot_ik.L").x + point(reference, "foot_ik.R").x) * 0.5
    trailing_side = "R" if leading_side == "L" else "L"
    leading = point(reference, "foot_ik." + leading_side)
    trailing = mirrored_point(reference, "foot_ik." + leading_side, center_x)
    leading.y += 120.0
    trailing.y -= 110.0
    set_foot(rig, leading_side, leading)
    set_foot(rig, trailing_side, trailing)
    hips = point(reference, "hips")
    set_knee_pole(rig, leading_side, hips, leading)
    set_knee_pole(rig, trailing_side, hips, trailing)
    weight = 18.0 if leading_side == "L" else -18.0
    rotation = 0.045 if leading_side == "L" else -0.045
    set_body(rig, reference, 0.0, weight, rotation)
    set_arm(rig, "L", point(reference, "hand_ik.L"), leading_side == "R")
    set_arm(rig, "R", point(reference, "hand_ik.R"), leading_side == "L")


def create_down_pose(rig, reference, leading_side):
    create_contact_pose(rig, reference, leading_side)
    leading = point(reference, "foot_ik." + leading_side)
    leading.y += 120.0
    set_foot(rig, leading_side, leading)
    weight = 18.0 if leading_side == "L" else -18.0
    hips = point(reference, "hips") + Vector((weight, 0.0, -48.0))
    set_world_position(rig, "hips", hips)
    set_knee_pole(rig, leading_side, hips, leading, swing=True)
    rotate_world(rig, "torso", "X", 0.025)
    rotate_world(rig, "chest", "X", 0.018)


def create_passing_pose(rig, reference, leading_side):
    create_contact_pose(rig, reference, leading_side)
    swing_side = "R" if leading_side == "L" else "L"
    support = point(reference, "foot_ik." + leading_side)
    support.y += 120.0
    swing = mirrored_point(reference, "foot_ik." + leading_side, 0.0)
    swing.y += 35.0
    set_foot(rig, leading_side, support)
    set_foot(rig, swing_side, swing, lift=105.0)
    weight = 30.0 if leading_side == "L" else -30.0
    hips = point(reference, "hips") + Vector((weight, 0.0, 0.0))
    set_world_position(rig, "hips", hips)
    set_knee_pole(rig, leading_side, hips, support)
    set_knee_pole(rig, swing_side, hips, swing, swing=True)
    rotation = -0.018 if leading_side == "L" else 0.018
    rotate_world(rig, "torso", "Z", rotation)
    rotate_world(rig, "chest", "Z", rotation * 0.66)


def create_up_pose(rig, reference, leading_side):
    create_contact_pose(rig, reference, leading_side)
    trailing_side = "R" if leading_side == "L" else "L"
    push = point(reference, "foot_ik." + leading_side)
    push.y += 65.0
    push.z += 28.0
    next_foot = mirrored_point(reference, "foot_ik." + leading_side, 0.0)
    next_foot.y += 120.0
    set_foot(rig, leading_side, push)
    set_foot(rig, trailing_side, next_foot)
    weight = 20.0 if leading_side == "L" else -20.0
    hips = point(reference, "hips") + Vector((weight, 0.0, 52.0))
    set_world_position(rig, "hips", hips)
    set_knee_pole(rig, leading_side, hips, push)
    set_knee_pole(rig, trailing_side, hips, next_foot, swing=True)
    rotation = -0.025 if leading_side == "L" else 0.025
    rotate_world(rig, "hips", "Z", rotation)


def key_controls(rig, frame):
    for name in REQUIRED_CONTROLS:
        bone = rig.pose.bones[name]
        bone.keyframe_insert(data_path="location", frame=frame, group="Walk Controls")
        if bone.rotation_mode == "QUATERNION":
            bone.keyframe_insert(data_path="rotation_quaternion", frame=frame, group="Walk Controls")
        else:
            bone.keyframe_insert(data_path="rotation_euler", frame=frame, group="Walk Controls")


def capture_pose(rig):
    bpy.context.view_layer.update()
    return {
        name: world_matrix(rig, rig.pose.bones[name]).copy()
        for name in REQUIRED_CONTROLS
    }


def capture_local_pose(rig):
    bpy.context.view_layer.update()
    pose = {}
    for name in REQUIRED_CONTROLS:
        bone = rig.pose.bones[name]
        pose[name] = {
            "location": bone.location.copy(),
            "rotation_mode": bone.rotation_mode,
            "rotation_quaternion": bone.rotation_quaternion.copy(),
            "rotation_euler": bone.rotation_euler.copy(),
            "scale": bone.scale.copy(),
        }
    return pose


def capture_basis_pose(rig):
    bpy.context.view_layer.update()
    return {
        name: rig.pose.bones[name].matrix_basis.copy()
        for name in REQUIRED_CONTROLS
    }


def apply_local_pose(rig, pose):
    for name, values in pose.items():
        bone = rig.pose.bones[name]
        bone.location = values["location"].copy()
        bone.scale = values["scale"].copy()
        if values["rotation_mode"] == "QUATERNION":
            bone.rotation_quaternion = values["rotation_quaternion"].copy()
        else:
            bone.rotation_euler = values["rotation_euler"].copy()


def mirror_pose(rig, pose, center_x):
    reflection = Matrix((
        (-1.0, 0.0, 0.0, 0.0),
        (0.0, 1.0, 0.0, 0.0),
        (0.0, 0.0, 1.0, 0.0),
        (0.0, 0.0, 0.0, 1.0),
    ))
    for name, matrix in pose.items():
        mirrored_matrix = reflection @ matrix @ reflection
        side = name.rsplit(".", 1)[-1]
        mirrored_name = name[:-1] + ("R" if side == "L" else "L") if side in ("L", "R") else name
        rig.pose.bones[mirrored_name].matrix_basis = mirrored_matrix


def main():
    if not bpy.data.filepath:
        raise RuntimeError("The current Blender file has not been saved")
    rig = find_generated_rig()
    ensure_safe_target(rig)
    previous_action = rig.animation_data.action if rig.animation_data else None
    if previous_action:
        rig.animation_data.action = None
        bpy.context.view_layer.update()
    reference = {
        name: world_matrix(rig, rig.pose.bones[name]).copy()
        for name in REQUIRED_CONTROLS
    }
    action = bpy.data.actions.new(ACTION_NAME)
    action.use_fake_user = True
    rig.animation_data_create()
    rig.animation_data.action = action

    left_pose_functions = {
        1: create_contact_pose,
        5: create_down_pose,
        9: create_passing_pose,
        13: create_up_pose,
    }
    left_poses = {}
    left_local_poses = {}
    left_basis_poses = {}
    for frame, pose_function in left_pose_functions.items():
        bpy.context.scene.frame_set(frame)
        pose_function(rig, reference, "L")
        bpy.context.view_layer.update()
        left_poses[frame] = capture_pose(rig)
        left_local_poses[frame] = capture_local_pose(rig)
        left_basis_poses[frame] = capture_basis_pose(rig)
        key_controls(rig, frame)

    center_x = point(reference, "hips").x
    for frame, source_frame in ((17, 1), (21, 5), (25, 9), (29, 13)):
        bpy.context.scene.frame_set(frame)
        mirror_pose(rig, left_basis_poses[source_frame], center_x)
        bpy.context.view_layer.update()
        key_controls(rig, frame)

    bpy.context.scene.frame_set(33)
    apply_local_pose(rig, left_local_poses[1])
    bpy.context.view_layer.update()
    key_controls(rig, 33)

    action.frame_start = 1
    action.frame_end = 33
    bpy.context.scene.render.fps = 30
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 33
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=OUTPUT_FILE)
    print("AXION_WALK_TEST_CREATED", rig.name, ACTION_NAME, "frames=1..33", "fps=30")


main()
import bpy
import json
from mathutils import Vector


ACTION_NAME = "AXION_Walk_Forward_TEST"
REFERENCE_ACTION_NAME = "AXION_Walk_Forward"
SAMPLE_BONES = (
    "foot_ik.L", "foot_ik.R", "toe_ik.L", "toe_ik.R",
    "thigh_ik_target.L", "thigh_ik_target.R",
    "hips", "hand_ik.L", "hand_ik.R",
)


def position(rig, name):
    bpy.context.view_layer.update()
    return Vector((rig.matrix_world @ rig.pose.bones[name].matrix).translation)


def close(first, second, tolerance=1e-3):
    return (Vector(first) - Vector(second)).length <= tolerance


def mirrored(first, second, center_x, tolerance=1e-3):
    expected = Vector(first)
    expected.x = 2.0 * center_x - expected.x
    return close(expected, second, tolerance)


def pole_clear(rig, frame, side):
    bpy.context.scene.frame_set(frame)
    hip = position(rig, "hips")
    foot = position(rig, "foot_ik." + side)
    pole = position(rig, "thigh_ik_target." + side)
    leg = foot - hip
    pole_vector = pole - (hip + foot) * 0.5
    return leg.length > 0.0 and pole_vector.length > 0.0 and leg.cross(pole_vector).length > 1.0


def main():
    rig = bpy.data.objects.get("rig")
    action = bpy.data.actions.get(ACTION_NAME)
    reference_action = bpy.data.actions.get(REFERENCE_ACTION_NAME)
    if not rig or not action:
        raise RuntimeError("Generated rig or AXION_Walk_Forward_TEST action is missing")
    if not rig.animation_data or rig.animation_data.action != action:
        raise RuntimeError("AXION_Walk_Forward_TEST is not assigned to the generated rig")

    samples = {}
    for frame in (1, 5, 9, 13, 17, 21, 25, 29, 33):
        bpy.context.scene.frame_set(frame)
        samples[frame] = {
            name: tuple(position(rig, name)) for name in SAMPLE_BONES
        }

    center_x = (samples[1]["hips"][0] + samples[17]["hips"][0]) * 0.5
    checks = {
        "test_action_exists_and_assigned": True,
        "existing_action_preserved": reference_action is not None and reference_action != action,
        "action_frame_range": list(action.curve_frame_range),
        "scene_frame_range": [bpy.context.scene.frame_start, bpy.context.scene.frame_end],
        "fps": bpy.context.scene.render.fps,
        "frame_1_equals_33": all(
            close(samples[1][name], samples[33][name]) for name in SAMPLE_BONES
        ),
        "frame_1_17_mirrored": all(
            mirrored(samples[1][left], samples[17][right], center_x)
            for left, right in (
                ("foot_ik.L", "foot_ik.R"),
                ("foot_ik.R", "foot_ik.L"),
                ("hand_ik.L", "hand_ik.R"),
                ("hand_ik.R", "hand_ik.L"),
            )
        ),
        "frame_5_21_mirrored": all(
            mirrored(samples[5][left], samples[21][right], center_x)
            for left, right in (("foot_ik.L", "foot_ik.R"), ("foot_ik.R", "foot_ik.L"))
        ),
        "frame_9_25_mirrored": all(
            mirrored(samples[9][left], samples[25][right], center_x)
            for left, right in (("foot_ik.L", "foot_ik.R"), ("foot_ik.R", "foot_ik.L"))
        ),
        "frame_13_29_mirrored": all(
            mirrored(samples[13][left], samples[29][right], center_x)
            for left, right in (("foot_ik.L", "foot_ik.R"), ("foot_ik.R", "foot_ik.L"))
        ),
        "left_contact_down_foot_fixed": close(samples[1]["foot_ik.L"], samples[5]["foot_ik.L"]),
        "right_contact_down_foot_fixed": close(samples[17]["foot_ik.R"], samples[21]["foot_ik.R"]),
        "left_passing_support_fixed": close(samples[1]["foot_ik.L"], samples[9]["foot_ik.L"]),
        "right_passing_support_fixed": close(samples[17]["foot_ik.R"], samples[25]["foot_ik.R"]),
        "left_passing_swing_lift": samples[9]["foot_ik.R"][2] > samples[1]["foot_ik.R"][2],
        "right_passing_swing_lift": samples[25]["foot_ik.L"][2] > samples[17]["foot_ik.L"][2],
        "left_pelvis_down_contact_up": samples[5]["hips"][2] < samples[1]["hips"][2] < samples[13]["hips"][2],
        "right_pelvis_down_contact_up": samples[21]["hips"][2] < samples[17]["hips"][2] < samples[29]["hips"][2],
        "opposite_arm_swing": (
            samples[1]["hand_ik.R"][1] > samples[1]["hand_ik.L"][1]
            and samples[17]["hand_ik.L"][1] > samples[17]["hand_ik.R"][1]
        ),
        "left_knee_pole_clear": pole_clear(rig, 9, "R") and pole_clear(rig, 1, "L"),
        "right_knee_pole_clear": pole_clear(rig, 25, "L") and pole_clear(rig, 17, "R"),
    }
    excluded = {"action_frame_range", "scene_frame_range", "fps"}
    checks["all_reference_checks"] = all(
        value for key, value in checks.items() if key not in excluded
    )
    print("AXION_WALK_TEST_VALIDATION_BEGIN")
    print(json.dumps(checks, indent=2, default=str))
    print("SAMPLES", json.dumps(samples, default=str))
    print("AXION_WALK_TEST_VALIDATION_END")
    if not checks["all_reference_checks"]:
        raise RuntimeError("One or more reference-based AXION walk checks failed")


main()
import bpy
import json
from mathutils import Vector


ACTION_NAME = "AXION_Metarig_Walk_TEST"
SAMPLE_FRAMES = (1, 5, 9, 13, 17, 21, 25, 29, 33)
SAMPLE_BONES = (
    "spine", "thigh.L", "thigh.R", "shin.L", "shin.R",
    "foot.L", "foot.R", "toe.L", "toe.R", "hand.L", "hand.R",
)
SIDE_PAIRS = (
    ("foot.L", "foot.R"), ("foot.R", "foot.L"),
    ("toe.L", "toe.R"), ("toe.R", "toe.L"),
    ("hand.L", "hand.R"), ("hand.R", "hand.L"),
)


def world_head(metarig, name):
    return Vector(metarig.matrix_world @ Vector(metarig.pose.bones[name].head))


def world_tail(metarig, name):
    return Vector(metarig.matrix_world @ Vector(metarig.pose.bones[name].tail))


def close(first, second, tolerance=1e-3):
    return (Vector(first) - Vector(second)).length <= tolerance


def mirrored(first, second, center_x, tolerance=1e-3):
    expected = Vector(first)
    expected.x = 2.0 * center_x - expected.x
    return close(expected, second, tolerance)


def chain_valid(metarig, side):
    thigh_tail = world_tail(metarig, "thigh." + side)
    shin_head = world_head(metarig, "shin." + side)
    shin_tail = world_tail(metarig, "shin." + side)
    foot_head = world_head(metarig, "foot." + side)
    foot_tail = world_tail(metarig, "foot." + side)
    toe_head = world_head(metarig, "toe." + side)
    return (
        (thigh_tail - shin_head).length < 1.0
        and (shin_tail - foot_head).length < 1.0
        and (foot_tail - toe_head).length < 1.0
    )


def main():
    metarig = bpy.data.objects.get("metarig")
    action = bpy.data.actions.get(ACTION_NAME)
    if not metarig or metarig.type != "ARMATURE":
        raise RuntimeError("Metarig object is missing")
    if not action:
        raise RuntimeError("AXION_Metarig_Walk_TEST action is missing")
    if not metarig.animation_data or metarig.animation_data.action != action:
        raise RuntimeError("AXION_Metarig_Walk_TEST is not assigned to metarig")

    samples = {}
    for frame in SAMPLE_FRAMES:
        bpy.context.scene.frame_set(frame)
        bpy.context.view_layer.update()
        samples[frame] = {
            name: tuple(world_head(metarig, name)) for name in SAMPLE_BONES
        }

    center_x = samples[1]["spine"][0]
    checks = {
        "action_exists_and_assigned": True,
        "action_frame_range": list(action.curve_frame_range),
        "scene_frame_range": [bpy.context.scene.frame_start, bpy.context.scene.frame_end],
        "fps": bpy.context.scene.render.fps,
        "nine_key_pose_frames_sampled": len(samples) == 9,
        "frame_1_equals_33": all(close(samples[1][name], samples[33][name]) for name in SAMPLE_BONES),
        "frame_1_17_mirrored": all(
            mirrored(samples[1][left], samples[17][right], center_x)
            for left, right in SIDE_PAIRS
        ),
        "frame_5_21_mirrored": all(
            mirrored(samples[5][left], samples[21][right], center_x)
            for left, right in SIDE_PAIRS[:4]
        ),
        "frame_9_25_mirrored": all(
            mirrored(samples[9][left], samples[25][right], center_x)
            for left, right in SIDE_PAIRS[:4]
        ),
        "frame_13_29_mirrored": all(
            mirrored(samples[13][left], samples[29][right], center_x)
            for left, right in SIDE_PAIRS[:4]
        ),
        "left_contact_down_foot_fixed": close(samples[1]["foot.L"], samples[5]["foot.L"]),
        "right_contact_down_foot_fixed": close(samples[17]["foot.R"], samples[21]["foot.R"]),
        "left_passing_swing_lift": samples[9]["foot.R"][2] > samples[1]["foot.R"][2],
        "right_passing_swing_lift": samples[25]["foot.L"][2] > samples[17]["foot.L"][2],
        "left_pelvis_down_contact_up": samples[5]["spine"][2] < samples[1]["spine"][2] < samples[13]["spine"][2],
        "right_pelvis_down_contact_up": samples[21]["spine"][2] < samples[17]["spine"][2] < samples[29]["spine"][2],
        "opposite_arm_swing": (
            samples[1]["hand.R"][1] > samples[1]["hand.L"][1]
            and samples[17]["hand.L"][1] > samples[17]["hand.R"][1]
        ),
        "left_leg_chain_connected": chain_valid(metarig, "L"),
        "right_leg_chain_connected": chain_valid(metarig, "R"),
    }
    excluded = {"action_frame_range", "scene_frame_range", "fps"}
    checks["all_metarig_checks"] = all(
        value for key, value in checks.items() if key not in excluded
    )
    print("AXION_METARIG_WALK_VALIDATION_BEGIN")
    print(json.dumps(checks, indent=2, default=str))
    print("SAMPLES", json.dumps(samples, default=str))
    print("AXION_METARIG_WALK_VALIDATION_END")
    if not checks["all_metarig_checks"]:
        raise RuntimeError("One or more metarig walk checks failed")


main()
"""
Create a first-pass mecha animation reel for:
C:/Users/ln9swrd/Documents/blender/models/shin getter robo/shin getter robo11.blend

Run from a terminal with Blender installed:

blender --background --python scripts/blender/animate_shin_getter_robo.py

Optional arguments after "--":

blender --background --python scripts/blender/animate_shin_getter_robo.py -- ^
  --input "C:/Users/ln9swrd/Documents/blender/models/shin getter robo/shin getter robo11.blend" ^
  --output "D:/Excelion/home/svknght7/excelion-forge/blender/shin_getter_robo11_animated.blend" ^
  --fps 30

The script inspects the rig first, prints armature/bone/action/NLA information,
then creates a blocking animation for the requested Shin Getter Robo sequence:
1. 겟타선 태동
2. 겟타선 모으기
3. 날개 전개
4. 위로 상승
5. 스토나 썬샤인 준비
6. 스토나 썬샤인 응축
7. 스토나 썬샤인 시전
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from typing import Iterable

import bpy
from mathutils import Euler, Vector


DEFAULT_BLEND = Path(
    r"D:\Excelion\home\svknght7\excelion-forge\blender\source\shin getter robo11.blend"
)

ACTION_NAME = "EX_Shin_Getter_Robo_Sequence"
FRAME_END = 150


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate Shin Getter Robo blocking animation.")
    parser.add_argument("--input", type=Path, default=DEFAULT_BLEND, help="Source .blend file")
    parser.add_argument("--output", type=Path, default=None, help="Output .blend file")
    parser.add_argument("--fps", type=int, default=30, help="Scene frame rate")
    args = parser.parse_args(args_after_blender_separator())
    if args.output is None:
        output_dir = Path("D:/Excelion/home/svknght7/excelion-forge/blender/exports")
        output_dir.mkdir(parents=True, exist_ok=True)
        args.output = output_dir / f"{args.input.stem}_animated.blend"
    return args


def args_after_blender_separator() -> list[str]:
    import sys

    if "--" not in sys.argv:
        return []
    return sys.argv[sys.argv.index("--") + 1 :]


def open_blend(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Blend file not found: {path}")
    bpy.ops.wm.open_mainfile(filepath=str(path))


def visible_meshes() -> list[bpy.types.Object]:
    return [
        obj
        for obj in bpy.context.scene.objects
        if obj.type == "MESH" and obj.visible_get() and not obj.hide_viewport
    ]


def find_armature() -> bpy.types.Object | None:
    armatures = [obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE"]
    if not armatures:
        return None
    armatures.sort(key=lambda obj: len(obj.data.bones), reverse=True)
    return armatures[0]


def find_root_object() -> bpy.types.Object | None:
    meshes = visible_meshes()
    if not meshes:
        return None
    meshes.sort(key=lambda obj: obj.dimensions.length, reverse=True)
    return meshes[0]


def print_rig_summary(armature: bpy.types.Object | None) -> None:
    print("=== Rig inspection ===")
    print(f"Rig type: {'Armature' if armature else 'Object parts / blocking'}")
    if armature is None:
        print("Armature: not found")
        return

    print(f"Armature: {armature.name}")
    print(f"Bone count: {len(armature.pose.bones)}")
    bone_names = [bone.name for bone in armature.pose.bones]
    print("Bones:")
    for bone_name in bone_names[:80]:
        print(f"  - {bone_name}")
    if len(bone_names) > 80:
        print(f"  ... ({len(bone_names) - 80} more)")

    action_names = sorted(action.name for action in bpy.data.actions)
    print("Existing actions:")
    for action_name in action_names[:40]:
        print(f"  - {action_name}")
    if len(action_names) > 40:
        print(f"  ... ({len(action_names) - 40} more)")

    nla_tracks = []
    if armature.animation_data:
        nla_tracks = [track.name for track in armature.animation_data.nla_tracks]
    print("NLA tracks:")
    if nla_tracks:
        for track_name in nla_tracks:
            print(f"  - {track_name}")
    else:
        print("  - (none)")


def clear_generated_animation(obj: bpy.types.Object) -> None:
    if obj.animation_data and obj.animation_data.action:
        if obj.animation_data.action.name.startswith("EX_"):
            obj.animation_data.action = None
    for track in obj.animation_data.nla_tracks if obj.animation_data else []:
        if track.name.startswith("EX_"):
            obj.animation_data.nla_tracks.remove(track)


def ensure_action(obj: bpy.types.Object, name: str) -> bpy.types.Action:
    obj.animation_data_create()
    action = bpy.data.actions.new(name)
    action.use_fake_user = True
    obj.animation_data.action = action
    return action


def remap_frame(frame: int) -> int:
    return max(1, min(FRAME_END, int(round(frame))))


def set_scene(fps: int) -> None:
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = FRAME_END
    scene.frame_set(1)
    scene.render.fps = fps
    scene.unit_settings.system = "METRIC"
    add_markers(
        {
            remap_frame(1): "1. 태동",
            remap_frame(50): "2. 모으기",
            remap_frame(110): "3. 날개 전개",
            remap_frame(120): "4. 상승",
            remap_frame(130): "5. 준비",
            remap_frame(140): "6. 응축",
            remap_frame(145): "7. 시전",
            remap_frame(150): "Final Hold",
        }
    )


def add_markers(markers: dict[int, str]) -> None:
    scene = bpy.context.scene
    scene.timeline_markers.clear()
    for frame, name in markers.items():
        scene.timeline_markers.new(name, frame=frame)


def bone_matches(name: str, keywords: Iterable[str]) -> bool:
    lower_name = name.lower()
    return any(keyword in lower_name for keyword in keywords)


def side_matches(name: str, side: str) -> bool:
    lower_name = name.lower()
    if side == "L":
        return (
            ".l" in lower_name
            or "_l" in lower_name
            or "left" in lower_name
            or " l " in f" {lower_name} "
        )
    return (
        ".r" in lower_name
        or "_r" in lower_name
        or "right" in lower_name
        or " r " in f" {lower_name} "
    )


def find_pose_bones(
    armature: bpy.types.Object, keywords: Iterable[str], side: str | None = None
) -> list[bpy.types.PoseBone]:
    bones = []
    for bone in armature.pose.bones:
        if side and not side_matches(bone.name, side):
            continue
        if bone_matches(bone.name, keywords):
            bones.append(bone)
    return bones


def first_pose_bone(
    armature: bpy.types.Object, keywords: Iterable[str], side: str | None = None
) -> bpy.types.PoseBone | None:
    bones = find_pose_bones(armature, keywords, side)
    return bones[0] if bones else None


def fallback_side_bone(armature: bpy.types.Object, side: str, index: int = 0) -> bpy.types.PoseBone | None:
    candidates = [bone for bone in armature.pose.bones if side_matches(bone.name, side)]
    candidates.sort(key=lambda bone: bone.bone.head_local.z, reverse=True)
    if index < len(candidates):
        return candidates[index]
    return None


def set_bone_rotation(
    bone: bpy.types.PoseBone | None,
    frame: int,
    xyz_degrees: tuple[float, float, float],
) -> None:
    if bone is None:
        return
    bone.rotation_mode = "XYZ"
    bone.rotation_euler = Euler(tuple(math.radians(value) for value in xyz_degrees), "XYZ")
    bone.keyframe_insert(data_path="rotation_euler", frame=remap_frame(frame))


def set_bone_location(
    bone: bpy.types.PoseBone | None,
    frame: int,
    xyz: tuple[float, float, float],
) -> None:
    if bone is None:
        return
    bone.location = Vector(xyz)
    bone.keyframe_insert(data_path="location", frame=remap_frame(frame))


def insert_rest_pose(armature: bpy.types.Object, frame: int) -> None:
    frame = remap_frame(frame)
    for bone in armature.pose.bones:
        bone.rotation_mode = "XYZ"
        bone.location = (0.0, 0.0, 0.0)
        bone.rotation_euler = (0.0, 0.0, 0.0)
        bone.scale = (1.0, 1.0, 1.0)
        bone.keyframe_insert(data_path="location", frame=frame)
        bone.keyframe_insert(data_path="rotation_euler", frame=frame)
        bone.keyframe_insert(data_path="scale", frame=frame)


def animate_armature(armature: bpy.types.Object) -> None:
    clear_generated_animation(armature)
    ensure_action(armature, ACTION_NAME)
    make_active_object(armature)

    root = first_pose_bone(armature, ["root", "hips", "pelvis", "center", "cog"])
    chest = first_pose_bone(armature, ["spine", "chest", "torso", "body"])
    head = first_pose_bone(armature, ["head", "neck"])

    upper_arm_l = first_pose_bone(armature, ["upperarm", "upper_arm", "arm", "shoulder"], "L")
    upper_arm_r = first_pose_bone(armature, ["upperarm", "upper_arm", "arm", "shoulder"], "R")
    lower_arm_l = first_pose_bone(armature, ["forearm", "lowerarm", "lower_arm", "elbow"], "L")
    lower_arm_r = first_pose_bone(armature, ["forearm", "lowerarm", "lower_arm", "elbow"], "R")
    hand_l = first_pose_bone(armature, ["hand", "wrist", "fist"], "L")
    hand_r = first_pose_bone(armature, ["hand", "wrist", "fist"], "R")
    thigh_l = first_pose_bone(armature, ["thigh", "upperleg", "upper_leg", "leg"], "L")
    thigh_r = first_pose_bone(armature, ["thigh", "upperleg", "upper_leg", "leg"], "R")
    shin_l = first_pose_bone(armature, ["shin", "calf", "lowerleg", "lower_leg", "knee"], "L")
    shin_r = first_pose_bone(armature, ["shin", "calf", "lowerleg", "lower_leg", "knee"], "R")

    wing_l = first_pose_bone(armature, ["wing", "fin", "flap"], "L")
    wing_r = first_pose_bone(armature, ["wing", "fin", "flap"], "R")

    upper_arm_l = upper_arm_l or fallback_side_bone(armature, "L", 0)
    upper_arm_r = upper_arm_r or fallback_side_bone(armature, "R", 0)
    lower_arm_l = lower_arm_l or fallback_side_bone(armature, "L", 1)
    lower_arm_r = lower_arm_r or fallback_side_bone(armature, "R", 1)
    thigh_l = thigh_l or fallback_side_bone(armature, "L", 2)
    thigh_r = thigh_r or fallback_side_bone(armature, "R", 2)
    wing_l = wing_l or upper_arm_l
    wing_r = wing_r or upper_arm_r

    for frame in (1, 50, 110, 120, 130, 140, 145, 150):
        insert_rest_pose(armature, frame)

    # 1. 겟타선 태동: slow rising energy.
    for frame, lift, pitch in ((1, 0.0, 0), (15, 0.015, -2), (30, 0.0, -1)):
        set_bone_location(root, frame, (0.0, 0.0, lift))
        set_bone_rotation(chest, frame, (pitch, 0, 0))
        set_bone_rotation(head, frame, (-pitch * 0.4, 0, 0))

    # 2. 겟타선 모으기: arms pull inward with an uneven, more natural brace.
    for frame, lean, arm_pitch_l, arm_pitch_r, forearm_l, forearm_r, hand_l_rot, hand_r_rot in (
        (45, -6, -12, -10, -20, -16, (0, 0, 6), (0, 0, -4)),
        (50, -8, -18, -14, -24, -18, (0, 0, 10), (0, 0, -8)),
        (70, -4, -10, -8, -20, -14, (0, 0, 4), (0, 0, -2)),
    ):
        set_bone_rotation(chest, frame, (lean, 0, 0))
        set_bone_rotation(upper_arm_l, frame, (arm_pitch_l, -16, -10))
        set_bone_rotation(upper_arm_r, frame, (arm_pitch_r, 14, 8))
        set_bone_rotation(lower_arm_l, frame, (forearm_l, 0, -6))
        set_bone_rotation(lower_arm_r, frame, (forearm_r, 0, 4))
        set_bone_rotation(hand_l, frame, hand_l_rot)
        set_bone_rotation(hand_r, frame, hand_r_rot)

    # 3. 날개 전개: shoulders widen and the wing-like bones open unevenly.
    for frame, wing_open_l, wing_open_r, shoulder_up_l, shoulder_up_r in (
        (90, 12, 16, 8, 10),
        (105, 20, 24, 14, 16),
        (110, 16, 18, 10, 12),
    ):
        set_bone_rotation(chest, frame, (-2, 0, 1))
        set_bone_rotation(upper_arm_l, frame, (shoulder_up_l, -22, -14))
        set_bone_rotation(upper_arm_r, frame, (shoulder_up_r, 18, 12))
        set_bone_rotation(wing_l, frame, (0, 0, wing_open_l))
        set_bone_rotation(wing_r, frame, (0, 0, -wing_open_r))

    # 4. 위로 상승: the body lifts and leans upward with a slight twist.
    for frame, raise_z, lean, twist in ((120, 0.34, -1, 1), (135, 0.52, -4, 2), (150, 0.44, -2, 1)):
        set_bone_location(root, frame, (0.0, 0.0, raise_z))
        set_bone_rotation(chest, frame, (lean, 0, twist))
        set_bone_rotation(head, frame, (twist * 0.2, 0, 0))

    # 5. 스토나 썬샤인 준비: both hands rise, but not as a perfect mirror.
    for frame, arm_raise_l, arm_raise_r, hand_up_l, hand_up_r, hand_z_l, hand_z_r in (
        (125, -32, -38, 16, 14, 0.16, 0.12),
        (135, -50, -58, 24, 18, 0.24, 0.18),
        (145, -42, -48, 20, 15, 0.20, 0.14),
    ):
        set_bone_rotation(chest, frame, (-4, 0, 1))
        set_bone_rotation(upper_arm_l, frame, (arm_raise_l, -28, -18))
        set_bone_rotation(upper_arm_r, frame, (arm_raise_r, 24, 18))
        set_bone_rotation(lower_arm_l, frame, (-22, 0, -8))
        set_bone_rotation(lower_arm_r, frame, (-22, 0, 8))
        set_bone_rotation(hand_l, frame, (0, 0, hand_up_l))
        set_bone_rotation(hand_r, frame, (0, 0, -hand_up_r))
        set_bone_location(hand_l, frame, (-0.02, 0.02, hand_z_l))
        set_bone_location(hand_r, frame, (0.02, 0.02, hand_z_r))

    # 6. 스토나 썬샤인 응축: the hands arc across the body in an uneven sweep.
    for frame, side_shift_l, side_shift_r, chest_tilt, hand_l_pos, hand_r_pos in (
        (130, -18, -30, -4, (-0.08, 0.18, 0.18), (0.10, 0.12, 0.14)),
        (140, -24, -40, -6, (-0.12, 0.10, 0.12), (0.12, 0.06, 0.10)),
        (145, -20, -34, -3, (0.10, -0.02, 0.05), (-0.08, -0.06, 0.08)),
    ):
        set_bone_rotation(chest, frame, (chest_tilt, 0, 1))
        set_bone_rotation(upper_arm_l, frame, (-16, -36, side_shift_l))
        set_bone_rotation(upper_arm_r, frame, (-20, 34, -side_shift_r))
        set_bone_rotation(lower_arm_l, frame, (-28, 0, -10))
        set_bone_rotation(lower_arm_r, frame, (-28, 0, 10))
        set_bone_rotation(hand_l, frame, (0, -18, 0))
        set_bone_rotation(hand_r, frame, (0, 18, 0))
        set_bone_location(hand_l, frame, hand_l_pos)
        set_bone_location(hand_r, frame, hand_r_pos)

    # 7. 스토나 썬샤인 시전: hands thrust forward with different emphasis.
    for frame, forward_push_l, forward_push_r, chest_lift, hand_l_rot, hand_r_rot in (
        (140, 24, 30, 6, (0, 0, 14), (0, 0, -12)),
        (145, 38, 46, 8, (0, 0, 18), (0, 0, -14)),
        (150, 28, 32, 4, (0, 0, 16), (0, 0, -12)),
    ):
        set_bone_location(root, frame, (0.0, 0.0, 0.30))
        set_bone_rotation(chest, frame, (chest_lift, 0, 1))
        set_bone_rotation(upper_arm_l, frame, (-70, -18, forward_push_l))
        set_bone_rotation(upper_arm_r, frame, (-72, 18, -forward_push_r))
        set_bone_rotation(lower_arm_l, frame, (-12, 0, -4))
        set_bone_rotation(lower_arm_r, frame, (-12, 0, 4))
        set_bone_rotation(hand_l, frame, hand_l_rot)
        set_bone_rotation(hand_r, frame, hand_r_rot)

    # Final hold and settle.
    set_bone_location(root, 145, (0.0, 0.0, 0.28))
    set_bone_rotation(chest, 145, (-2, 0, 1))
    set_bone_rotation(head, 145, (1, 0, 0.2))
    set_bone_rotation(upper_arm_l, 145, (-10, -8, 6))
    set_bone_rotation(upper_arm_r, 145, (-8, 10, -4))
    set_bone_rotation(wing_l, 145, (0, 0, 8))
    set_bone_rotation(wing_r, 145, (0, 0, -8))
    set_bone_location(hand_l, 145, (-0.02, -0.01, 0.06))
    set_bone_location(hand_r, 145, (0.02, -0.01, 0.04))

    set_bone_location(root, 150, (0.0, 0.0, 0.28))
    set_bone_rotation(chest, 150, (-2, 0, 1))
    set_bone_rotation(head, 150, (0, 0, 0.1))
    set_bone_rotation(upper_arm_l, 150, (-6, -8, 4))
    set_bone_rotation(upper_arm_r, 150, (-4, 8, -2))
    set_bone_location(hand_l, 150, (-0.01, -0.02, 0.04))
    set_bone_location(hand_r, 150, (0.01, -0.02, 0.03))

    make_interpolation_constant_then_ease(armature)


def make_active_object(obj: bpy.types.Object) -> None:
    """Best-effort active selection without relying on mode switching."""
    try:
        bpy.ops.object.mode_set(mode="OBJECT")
    except RuntimeError:
        pass

    for scene_obj in bpy.context.scene.objects:
        scene_obj.select_set(False)

    obj.hide_set(False)
    obj.hide_viewport = False
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def animate_object_blocking(obj: bpy.types.Object) -> None:
    clear_generated_animation(obj)
    ensure_action(obj, ACTION_NAME)

    original_location = obj.location.copy()
    original_rotation = obj.rotation_euler.copy()
    obj.rotation_mode = "XYZ"

    keyed_transforms = {
        1: ((0, 0, 0), (0, 0, 0), 1.0),
        20: ((0, 0, 0.01), (0, 0, 0), 1.0),
        45: ((0, 0, 0.02), (-6, 0, 0), 1.0),
        80: ((0, 0, 0.03), (-8, 0, 0), 1.0),
        120: ((0, 0, 0.16), (-3, 0, 0), 1.02),
        160: ((0, 0, 0.22), (0, 0, 0), 1.03),
        205: ((0, 0, 0.24), (8, 0, 0), 1.04),
        250: ((0, 0, 0.2), (10, 0, 0), 1.05),
        330: ((0, 0, 0.08), (2, 0, 0), 1.02),
        360: ((0, 0, 0), (0, 0, 0), 1.0),
    }

    for frame, (loc_delta, rot_delta_deg, scale) in keyed_transforms.items():
        obj.location = original_location + Vector(loc_delta)
        obj.rotation_euler = Euler(
            tuple(original_rotation[i] + math.radians(rot_delta_deg[i]) for i in range(3)),
            "XYZ",
        )
        obj.scale = (scale, scale, scale)
        obj.keyframe_insert(data_path="location", frame=frame)
        obj.keyframe_insert(data_path="rotation_euler", frame=frame)
        obj.keyframe_insert(data_path="scale", frame=frame)

    make_interpolation_constant_then_ease(obj)


def make_interpolation_constant_then_ease(obj: bpy.types.Object) -> None:
    if not obj.animation_data or not obj.animation_data.action:
        return

    action = obj.animation_data.action
    fcurves = getattr(action, "fcurves", None)
    if not fcurves:
        return

    for fcurve in fcurves:
        for point in fcurve.keyframe_points:
            point.interpolation = "BEZIER"


def set_material_alpha(obj: bpy.types.Object, alpha: float) -> None:
    for slot in obj.material_slots:
        material = slot.material
        if not material or not getattr(material, "node_tree", None):
            continue
        for node in material.node_tree.nodes:
            if node.type != "BSDF_PRINCIPLED":
                continue
            alpha_input = node.inputs.get("Alpha")
            if alpha_input is not None:
                alpha_input.default_value = alpha
                break


def rename_object_and_data(obj: bpy.types.Object | None, new_name: str) -> bpy.types.Object | None:
    if obj is None:
        return None

    candidate_name = new_name
    counter = 1
    while candidate_name in bpy.data.objects and bpy.data.objects[candidate_name] is not obj:
        candidate_name = f"{new_name}.{counter}"
        counter += 1

    if obj.name != candidate_name:
        obj.name = candidate_name
    if obj.data and obj.data.name != candidate_name:
        obj.data.name = candidate_name
    return obj


def keyframe_visibility(obj: bpy.types.Object | None, frame: int, visible: bool) -> None:
    if obj is None:
        return
    obj.hide_viewport = not visible
    obj.hide_render = not visible
    obj.keyframe_insert(data_path="hide_viewport", frame=remap_frame(frame))
    obj.keyframe_insert(data_path="hide_render", frame=remap_frame(frame))


def prepare_special_objects() -> None:
    aura = rename_object_and_data(bpy.data.objects.get("Getter_Aura"), "EX_Getter_Aura")
    wing = rename_object_and_data(bpy.data.objects.get("Plane.005"), "EX_Wing_Plane")

    if aura is not None:
        aura.hide_set(False)
        keyframe_visibility(aura, 1, False)
        keyframe_visibility(aura, 80, True)
        aura.hide_viewport = False
        aura.hide_render = False

    if wing is not None:
        wing.hide_set(False)
        keyframe_visibility(wing, 1, False)
        keyframe_visibility(wing, 110, True)
        wing.hide_viewport = False
        wing.hide_render = False


def animate_getter_aura() -> None:
    aura = bpy.data.objects.get("EX_Getter_Aura") or bpy.data.objects.get("Getter_Aura")
    if aura is None:
        return

    aura.hide_set(False)
    aura.hide_viewport = True
    aura.hide_render = True
    set_material_alpha(aura, 1.0)

    aura.keyframe_insert(data_path="hide_viewport", frame=remap_frame(1))
    aura.keyframe_insert(data_path="hide_render", frame=remap_frame(1))
    aura.hide_viewport = False
    aura.hide_render = False
    aura.keyframe_insert(data_path="hide_viewport", frame=remap_frame(80))
    aura.keyframe_insert(data_path="hide_render", frame=remap_frame(80))
    aura.hide_viewport = False
    aura.hide_render = False
    set_material_alpha(aura, 1.0)


def add_camera_and_light(target: bpy.types.Object | None) -> None:
    if target is None:
        return

    center = target.location
    distance = max(target.dimensions.length * 1.2, 8.0)
    height = max(target.dimensions.z * 0.65, 3.0)

    camera = bpy.data.objects.get("Camera.001")
    if camera is None:
        camera = bpy.data.objects.get("EX_Camera_Demo")
    if camera is None:
        camera_data = bpy.data.cameras.new("EX_Camera_Demo")
        camera = bpy.data.objects.new("EX_Camera_Demo", camera_data)
        bpy.context.collection.objects.link(camera)

    camera.location = (center.x - distance * 0.65, center.y - distance, center.z + height)
    look_at(camera, Vector((center.x, center.y, center.z + height * 0.45)))
    camera.data.lens = 35
    bpy.context.scene.camera = camera

    light = bpy.data.objects.get("EX_Key_Light")
    if light is None:
        light_data = bpy.data.lights.new("EX_Key_Light", type="AREA")
        light = bpy.data.objects.new("EX_Key_Light", light_data)
        bpy.context.collection.objects.link(light)

    light.location = (center.x - 3.0, center.y - 4.0, center.z + height * 1.4)
    light.data.energy = 600
    light.data.size = 5


def look_at(obj: bpy.types.Object, target: Vector) -> None:
    direction = target - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def save_output(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(path))


def main() -> None:
    args = parse_args()
    open_blend(args.input)
    set_scene(args.fps)

    armature = find_armature()
    root_object = armature or find_root_object()
    print_rig_summary(armature)

    prepare_special_objects()
    animate_getter_aura()

    if armature:
        print(f"Animating armature: {armature.name}")
        animate_armature(armature)
    else:
        obj = find_root_object()
        if obj is None:
            raise RuntimeError("No Armature or visible Mesh object found to animate.")
        print(f"No armature found. Animating object blocking on: {obj.name}")
        animate_object_blocking(obj)

    add_camera_and_light(root_object)
    save_output(args.output)
    print(f"Saved animated blend: {args.output}")


if __name__ == "__main__":
    main()

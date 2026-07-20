"""Core business logic for pose manipulation and mirroring."""

from __future__ import annotations

from excelion_forge.core.rules.primitives.sidedness import SIDE_SUFFIX_RE


def find_mirror_bone_name(name: str) -> str | None:
    """Return the name of the mirrored opposite bone, preserving casing and separators."""
    match = SIDE_SUFFIX_RE.search(name)
    if not match:
        return None

    suffix = match.group(1)
    start, end = match.span(1)

    if suffix.lower() == "l":
        opposite = "r" if suffix.islower() else "R"
    else:
        opposite = "l" if suffix.islower() else "L"

    return name[:start] + opposite + name[end:]


def calculate_mirrored_location(
    loc: list[float] | tuple[float, float, float]
) -> tuple[float, float, float]:
    """Invert X coordinate for location mirroring."""
    return (-loc[0], loc[1], loc[2])


def calculate_mirrored_quaternion(
    q: list[float] | tuple[float, float, float, float]
) -> tuple[float, float, float, float]:
    """Invert Y and Z components for quaternion rotation mirroring (W, X, -Y, -Z)."""
    return (q[0], q[1], -q[2], -q[3])


def calculate_mirrored_euler(
    rot: list[float] | tuple[float, float, float]
) -> tuple[float, float, float]:
    """Invert Y and Z angles for Euler rotation mirroring (X, -Y, -Z)."""
    return (rot[0], -rot[1], -rot[2])


def calculate_mirrored_axis_angle(
    aa: list[float] | tuple[float, float, float, float]
) -> tuple[float, float, float, float]:
    """Invert Y and Z components of the rotation axis (Angle, X, -Y, -Z)."""
    return (aa[0], aa[1], -aa[2], -aa[3])


def is_bone_selected(pb: object) -> bool:
    """Check if the pose bone is selected, supporting both Blender API and mock objects."""
    bone = getattr(pb, "bone", None)
    if bone is not None:
        return bool(getattr(bone, "select", False))
    return bool(getattr(pb, "select", False))


def extract_pose_transforms(pb: object) -> dict[str, list[float]]:
    """Backup active transforms of a pose bone."""
    return {
        "location": list(getattr(pb, "location", (0.0, 0.0, 0.0))),
        "rotation_quaternion": list(getattr(pb, "rotation_quaternion", (1.0, 0.0, 0.0, 0.0))),
        "rotation_euler": list(getattr(pb, "rotation_euler", (0.0, 0.0, 0.0))),
        "rotation_axis_angle": list(getattr(pb, "rotation_axis_angle", (0.0, 0.0, 1.0, 0.0))),
        "scale": list(getattr(pb, "scale", (1.0, 1.0, 1.0))),
    }


def apply_pose_transforms(pb: object, data: dict[str, list[float]]) -> None:
    """Apply transform dataset back onto a pose bone."""
    if hasattr(pb, "location"):
        for i in range(3):
            pb.location[i] = data["location"][i]

    mode = getattr(pb, "rotation_mode", "QUATERNION")
    if mode == "QUATERNION":
        if hasattr(pb, "rotation_quaternion"):
            for i in range(4):
                pb.rotation_quaternion[i] = data["rotation_quaternion"][i]
    elif mode == "AXIS_ANGLE":
        if hasattr(pb, "rotation_axis_angle"):
            for i in range(4):
                pb.rotation_axis_angle[i] = data["rotation_axis_angle"][i]
    else:
        if hasattr(pb, "rotation_euler"):
            for i in range(3):
                pb.rotation_euler[i] = data["rotation_euler"][i]

    if hasattr(pb, "scale"):
        for i in range(3):
            pb.scale[i] = data["scale"][i]


def mirror_transforms(data: dict[str, list[float]]) -> dict[str, list[float]]:
    """Return a mirrored copy of the given transform dataset."""
    return {
        "location": list(calculate_mirrored_location(data["location"])),
        "rotation_quaternion": list(calculate_mirrored_quaternion(data["rotation_quaternion"])),
        "rotation_euler": list(calculate_mirrored_euler(data["rotation_euler"])),
        "rotation_axis_angle": list(calculate_mirrored_axis_angle(data["rotation_axis_angle"])),
        "scale": list(data["scale"]),
    }


def mirror_pose(target: object, selected_only: bool = False) -> int:
    """Mirror pose for an armature target, swapping L/R bone sets and self-mirroring Center bones.

    Returns the count of bones modified.
    """
    pose = getattr(target, "pose", None)
    if pose is None:
        return 0

    bones = getattr(pose, "bones", None)
    if not bones:
        return 0

    bones_map = {pb.name: pb for pb in bones}
    processed: set[str] = set()
    modified_count = 0

    for name, pb in bones_map.items():
        if name in processed:
            continue

        opp_name = find_mirror_bone_name(name)
        if opp_name and opp_name in bones_map:
            opp_pb = bones_map[opp_name]

            if selected_only:
                if not (is_bone_selected(pb) or is_bone_selected(opp_pb)):
                    continue

            # Backup source data
            a_data = extract_pose_transforms(pb)
            b_data = extract_pose_transforms(opp_pb)

            # Swap mirroring
            apply_pose_transforms(pb, mirror_transforms(b_data))
            apply_pose_transforms(opp_pb, mirror_transforms(a_data))

            processed.add(name)
            processed.add(opp_name)
            modified_count += 2
        else:
            # Center or side-less bone: mirror against itself
            if selected_only and not is_bone_selected(pb):
                continue

            a_data = extract_pose_transforms(pb)
            apply_pose_transforms(pb, mirror_transforms(a_data))

            processed.add(name)
            modified_count += 1

    return modified_count

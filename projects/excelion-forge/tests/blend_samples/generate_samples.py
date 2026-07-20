"""Generate .blend regression sample files for Excelion Forge.

실행 방법:
    blender --background --python tests/blend_samples/generate_samples.py

5개의 .blend 파일이 tests/blend_samples/ 에 생성됩니다.
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import bpy
except ImportError:
    print("ERROR: This script must be run inside Blender (bpy not found).")
    sys.exit(1)

_OUTPUT_DIR = Path(__file__).parent


def _reset_scene() -> None:
    """Remove all objects from the current scene."""
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def _new_armature(name: str) -> bpy.types.Object:
    """Create and return a new armature object."""
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    obj = bpy.context.active_object
    assert obj is not None, "armature_add must set active_object"
    obj.name = name
    obj.data.name = name + "_data"
    return obj


def _save(filename: str) -> None:
    """Save the current .blend file to the output directory."""
    path = str(_OUTPUT_DIR / filename)
    bpy.ops.wm.save_as_mainfile(filepath=path)
    print(f"  Saved: {path}")


# ---------------------------------------------------------------------------
# Sample 1: valid_rig.blend
# ---------------------------------------------------------------------------
def generate_valid_rig() -> None:
    """Single root bone, two children, applied transforms. Expects 0 issues."""
    _reset_scene()
    obj = _new_armature("Armature_Valid")

    edit_bones = obj.data.edit_bones
    root = edit_bones[0]
    root.name = "Root"
    root.tail = (0, 0, 1)

    spine = edit_bones.new("Spine")
    spine.head = (0, 0, 1)
    spine.tail = (0, 0, 2)
    spine.parent = root

    chest = edit_bones.new("Chest")
    chest.head = (0, 0, 2)
    chest.tail = (0, 0, 3)
    chest.parent = spine

    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    _save("valid_rig.blend")


# ---------------------------------------------------------------------------
# Sample 2: invalid_transform.blend
# ---------------------------------------------------------------------------
def generate_invalid_transform() -> None:
    """Root bone, unapplied location. Expects ARMATURE_TRANSFORM_NOT_APPLIED."""
    _reset_scene()
    obj = _new_armature("Armature_BadTransform")

    edit_bones = obj.data.edit_bones
    root = edit_bones[0]
    root.name = "Root"
    root.tail = (0, 0, 1)

    bpy.ops.object.mode_set(mode="OBJECT")
    obj.location = (1.0, 0.0, 0.0)  # intentionally NOT applied
    _save("invalid_transform.blend")


# ---------------------------------------------------------------------------
# Sample 3: invalid_duplicate_bone.blend
# ---------------------------------------------------------------------------
def generate_invalid_duplicate_bone() -> None:
    """Two root bones (Blender 5 prevents true duplicate names via API).

    Expects MULTIPLE_ROOT_BONES. DUPLICATE_BONE_NAME is covered by unit tests.
    """
    _reset_scene()
    obj = _new_armature("Armature_DupBone")

    edit_bones = obj.data.edit_bones
    root = edit_bones[0]
    root.name = "Root"
    root.tail = (0, 0, 1)

    second_root = edit_bones.new("RootB")
    second_root.head = (1, 0, 0)
    second_root.tail = (1, 0, 1)

    bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    _save("invalid_duplicate_bone.blend")


# ---------------------------------------------------------------------------
# Sample 4: invalid_empty_bone.blend
# ---------------------------------------------------------------------------
def generate_invalid_empty_bone() -> None:
    """One bone with an empty name (attempted). Expects BONE_NAME_EMPTY.

    Note: Blender may not allow truly empty bone names at the API level.
    This sample uses a whitespace-only name as closest approximation.
    """
    _reset_scene()
    obj = _new_armature("Armature_EmptyBone")

    edit_bones = obj.data.edit_bones
    root = edit_bones[0]
    root.name = "Root"
    root.tail = (0, 0, 1)

    empty_bone = edit_bones.new(" ")  # whitespace name
    empty_bone.head = (1, 0, 0)
    empty_bone.tail = (1, 0, 1)

    bpy.ops.object.mode_set(mode="OBJECT")
    _save("invalid_empty_bone.blend")


# ---------------------------------------------------------------------------
# Sample 5: invalid_multi_issue.blend
# ---------------------------------------------------------------------------
def generate_invalid_multi_issue() -> None:
    """Multiple root bones AND unapplied transform. Expects multiple issues."""
    _reset_scene()
    obj = _new_armature("Armature_MultiIssue")

    edit_bones = obj.data.edit_bones
    root = edit_bones[0]
    root.name = "Root"
    root.tail = (0, 0, 1)

    second_root = edit_bones.new("RootB")
    second_root.head = (1, 0, 0)
    second_root.tail = (1, 0, 1)

    bpy.ops.object.mode_set(mode="OBJECT")
    obj.location = (0.5, 0.0, 0.0)  # unapplied transform
    _save("invalid_multi_issue.blend")


if __name__ == "__main__":
    print("Generating Excelion Forge regression samples...")
    generate_valid_rig()
    generate_invalid_transform()
    generate_invalid_duplicate_bone()
    generate_invalid_empty_bone()
    generate_invalid_multi_issue()
    print("Done. All samples saved to:", _OUTPUT_DIR)

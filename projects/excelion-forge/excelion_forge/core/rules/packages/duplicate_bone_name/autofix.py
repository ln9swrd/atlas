"""Auto-fix helpers for duplicate bone name issues."""

from __future__ import annotations

from typing import Any

from excelion_forge.core.models import ArmatureModel, BoneModel
from excelion_forge.core.rules.primitives import make_unique_name


def apply_duplicate_bone_name_fixes(armature: ArmatureModel) -> list[dict[str, Any]]:
    """Rename duplicate bones to make names unique."""
    if not armature.bones:
        return []

    original_names = [bone.name.strip() for bone in armature.bones]
    reserved_names = {name for name in original_names if name}
    existing_names: set[str] = set()
    operations: list[dict[str, Any]] = []
    updated_bones: list[BoneModel] = []

    for bone in armature.bones:
        base_name = bone.name.strip()
        if not base_name:
            updated_bones.append(bone)
            continue

        if base_name in existing_names:
            new_name = make_unique_name(base_name, reserved_names | existing_names)
            updated_bones.append(
                BoneModel(
                    name=new_name,
                    head=bone.head,
                    tail=bone.tail,
                    parent=bone.parent,
                    index=bone.index,
                )
            )
            operations.append({"old_name": base_name, "new_name": new_name})
            existing_names.add(new_name)
            reserved_names.add(new_name)
        else:
            updated_bones.append(bone)
            existing_names.add(base_name)

    armature.bones[:] = updated_bones
    return operations

"""Auto-fix helpers for invalid bone character issues."""

from __future__ import annotations

from typing import Any

from excelion_forge.core.models import ArmatureModel, BoneModel
from excelion_forge.core.rules.primitives.naming import sanitize_name


def apply_invalid_bone_character_fixes(armature: ArmatureModel) -> list[dict[str, Any]]:
    if not armature.bones:
        return []

    operations: list[dict[str, Any]] = []
    updated_bones: list[BoneModel] = []
    for bone in armature.bones:
        old_name = bone.name
        new_name = sanitize_name(old_name)
        if new_name != old_name and new_name:
            updated_bones.append(
                BoneModel(
                    name=new_name,
                    head=bone.head,
                    tail=bone.tail,
                    parent=bone.parent,
                    index=bone.index,
                )
            )
            operations.append({"old_name": old_name, "new_name": new_name})
        else:
            updated_bones.append(bone)

    armature.bones[:] = updated_bones
    return operations

from __future__ import annotations

from typing import Dict, Iterable, List

from .armature import ArmatureModel
from .bone import BoneModel


def build_armature_model(
    name: str,
    bones: Iterable[BoneModel],
    source: str | None = None,
) -> ArmatureModel:
    bone_list: List[BoneModel] = list(bones)
    # Note: bone_map may have fewer keys than bones.length if there are duplicate names.
    # This is valid for ArmatureModel - duplicate name detection is a validator concern.
    bone_map: Dict[str, BoneModel] = {bone.name: bone for bone in bone_list}

    return ArmatureModel(name=name, bones=bone_list, bone_map=bone_map, source=source)

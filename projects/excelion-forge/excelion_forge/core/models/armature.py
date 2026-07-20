from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional

from .bone import BoneModel


@dataclass(frozen=True)
class ArmatureModel:
    name: str
    bones: List[BoneModel]
    bone_map: Dict[str, BoneModel]
    source: Optional[str] = None

    def __post_init__(self) -> None:
        # Note: ArmatureModel allows duplicate bone names.
        # bone_map will have fewer keys than bones.length if duplicates exist.
        # Duplicate name detection is a validator concern, not a structural one.
        
        # Validate that all bones are referenced in bone_map (by unique name)
        for bone in self.bones:
            if bone.name not in self.bone_map:
                raise ValueError(
                    f"ArmatureModel bone_map missing entry for bone '{bone.name}'"
                )

        if len(self.bone_map) != len(set(self.bone_map.keys())):
            raise ValueError("ArmatureModel bone_map contains duplicate bone names")

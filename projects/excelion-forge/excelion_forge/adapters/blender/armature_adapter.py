"""Adapter to convert Blender armature objects to core domain models."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from ...core.models import ArmatureModel


class BlenderArmatureAdapter:
    """Convert Blender bpy.types.Object (armature) or mock to ArmatureModel."""

    @staticmethod
    def extract(obj: Any) -> ArmatureModel:
        from ...core.models import BoneModel, build_armature_model

        if getattr(obj, "type", None) != "ARMATURE":
            raise ValueError(f"Expected armature object, got {getattr(obj, 'type', 'unknown')}")

        armature_data = getattr(obj, "data", None)
        if armature_data is None:
            raise ValueError(f"Armature object '{obj.name}' has no data")

        bones_data = getattr(armature_data, "bones", None)
        if bones_data is None:
            raise ValueError(f"Armature object '{obj.name}' has no bones attribute")

        bone_models = []
        for index, bone in enumerate(bones_data):
            bone_name: str = str(getattr(bone, "name", ""))
            if not bone_name:
                raise ValueError(f"Bone at index {index} has no name")

            # Try to get head/tail from real Blender bone, fallback to (0, 0, 0) for mock
            head_local = getattr(bone, "head_local", None)
            tail_local = getattr(bone, "tail_local", None)
            
            head: tuple = tuple(head_local) if head_local is not None else (0.0, 0.0, 0.0)
            tail: tuple = tuple(tail_local) if tail_local is not None else (0.0, 0.0, 0.0)

            parent_bone = getattr(bone, "parent", None)
            parent_name: str | None = str(getattr(parent_bone, "name", "")) if parent_bone else None

            bone_models.append(
                BoneModel(
                    name=bone_name,
                    head=head,
                    tail=tail,
                    parent=parent_name,
                    index=index,
                )
            )

        armature_name: str = str(getattr(obj, "name", "Armature"))
        return build_armature_model(
            name=armature_name,
            bones=bone_models,
            source="blender",
        )

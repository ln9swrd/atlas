"""
EXCELION Forge - Material & Texture Inspector Executor (v1.2)
Validates PBR material node setups, texture packing rules, and 2^n resolution constraints.
"""
from typing import Dict, Any, List
from forge.core.contracts import ExecutionContract
import math


class MaterialInspectorExecutor(ExecutionContract):
    """
    Validates materials, texture packing (ORM), and texture dimension rules.
    """

    def __init__(self):
        self._initialized = True

    def initialize(self) -> None:
        self._initialized = True

    def cleanup(self) -> None:
        self._initialized = False

    def validate(self, context: Dict[str, Any]) -> bool:
        return "materials" in context or "textures" in context or "inspect_materials" in context

    def _is_power_of_two(self, n: int) -> bool:
        return n > 0 and (n & (n - 1)) == 0

    def inspect_material(self, mat_info: Dict[str, Any]) -> List[Dict[str, Any]]:
        findings = []
        name = mat_info.get("name", "")

        # Naming Rule
        if not (name.startswith("M_") or name.startswith("MI_")):
            findings.append({
                "rule": "MaterialNamingRule",
                "severity": "WARNING",
                "message": f"Material '{name}' does not follow naming convention (M_ or MI_ prefix).",
            })

        # ORM Packed Texture Rule
        has_orm = mat_info.get("has_orm_texture", True)
        if not has_orm:
            findings.append({
                "rule": "TexturePackingRule",
                "severity": "WARNING",
                "message": f"Material '{name}' missing Occlusion-Roughness-Metallic (ORM) packed texture.",
            })

        return findings

    def inspect_texture(self, tex_info: Dict[str, Any]) -> List[Dict[str, Any]]:
        findings = []
        name = tex_info.get("name", "")
        width = tex_info.get("width", 2048)
        height = tex_info.get("height", 2048)

        if not self._is_power_of_two(width) or not self._is_power_of_two(height):
            findings.append({
                "rule": "PowerOfTwoRule",
                "severity": "ERROR",
                "message": f"Texture '{name}' resolution ({width}x{height}) is not power of two.",
            })

        return findings

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        if not self._initialized:
            raise RuntimeError("MaterialInspectorExecutor not initialized")

        materials = context.get("materials", [{"name": "M_Default_Mech", "has_orm_texture": True}])
        textures = context.get("textures", [{"name": "T_Mech_ORM", "width": 2048, "height": 2048}])

        all_findings: List[Dict[str, Any]] = []

        for mat in materials:
            all_findings.extend(self.inspect_material(mat))

        for tex in textures:
            all_findings.extend(self.inspect_texture(tex))

        errors = [f for f in all_findings if f["severity"] == "ERROR"]
        is_passed = len(errors) == 0

        return {
            "success": is_passed,
            "status": "PASS" if is_passed else "FAIL",
            "findings": all_findings,
            "inspected_materials": len(materials),
            "inspected_textures": len(textures),
        }

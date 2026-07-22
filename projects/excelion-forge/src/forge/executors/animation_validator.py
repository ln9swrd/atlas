"""
EXCELION Forge - Animation Validator Executor (v0.2)
"""

from typing import Dict, Any, List
from forge.core.contracts import ExecutionContract

class AnimationValidator(ExecutionContract):
    """
    Animation Validator for EXCELION Forge.
    Validates keyframe range, skin deformation, and bone hierarchy integrity.
    """
    def __init__(self):
        self._initialized = True

    def initialize(self):
        self._initialized = True

    def cleanup(self):
        self._initialized = False

    def validate(self, context: Dict[str, Any]) -> bool:
        return "action_name" in context or "armature_name" in context

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        if not self._initialized:
            raise RuntimeError("Animation validator not initialized")

        action_name = context.get("action_name", "Anim_Default")
        frame_start = context.get("frame_start", 1)
        frame_end = context.get("frame_end", 60)
        bone_names = context.get("bone_names", ["root", "pelvis", "hand_r"])
        unweighted_vertices = context.get("unweighted_vertices", 0)

        findings: List[Dict[str, Any]] = []

        if frame_end <= frame_start:
            findings.append({
                "rule": "AnimationFrameRangeRule",
                "severity": "ERROR",
                "message": f"Invalid frame range: start={frame_start}, end={frame_end}"
            })

        if "root" not in bone_names:
            findings.append({
                "rule": "RootBonePresenceRule",
                "severity": "ERROR",
                "message": "Armature missing 'root' bone for animation export"
            })

        if unweighted_vertices > 0:
            findings.append({
                "rule": "SkinDeformationRule",
                "severity": "WARNING",
                "message": f"Found {unweighted_vertices} unweighted vertices"
            })

        is_passed = len([f for f in findings if f["severity"] == "ERROR"]) == 0

        return {
            "success": is_passed,
            "action_name": action_name,
            "findings": findings,
            "total_findings": len(findings),
            "status": "PASS" if is_passed else "FAIL"
        }

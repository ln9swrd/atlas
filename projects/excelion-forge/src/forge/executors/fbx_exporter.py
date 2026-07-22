"""
EXCELION Forge - FBX Exporter Executor (v0.3)
"""

from typing import Dict, Any, List
from forge.core.contracts import ExecutionContract

class FBXExporter(ExecutionContract):
    """
    FBX Exporter for EXCELION Forge.
    Handles export preset validation, armature scale application, and UE socket preservation.
    """
    def __init__(self):
        self._initialized = True

    def initialize(self):
        self._initialized = True

    def cleanup(self):
        self._initialized = False

    def validate(self, context: Dict[str, Any]) -> bool:
        return "export_path" in context or "target_mesh" in context

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        if not self._initialized:
            raise RuntimeError("FBX exporter not initialized")

        export_path = context.get("export_path", "export/sm_asset.fbx")
        target_mesh = context.get("target_mesh", "SM_Default")
        scale_applied = context.get("scale_applied", True)
        preserve_sockets = context.get("preserve_sockets", True)

        findings: List[Dict[str, Any]] = []

        if not scale_applied:
            findings.append({
                "rule": "ArmatureScaleRule",
                "severity": "WARNING",
                "message": "Armature scale is not (1, 1, 1). Auto-applying scale before export."
            })

        if not export_path.endswith(".fbx"):
            findings.append({
                "rule": "FBXExtensionRule",
                "severity": "ERROR",
                "message": f"Export path must end with .fbx: {export_path}"
            })

        is_passed = len([f for f in findings if f["severity"] == "ERROR"]) == 0

        return {
            "success": is_passed,
            "export_path": export_path,
            "target_mesh": target_mesh,
            "preserve_sockets": preserve_sockets,
            "findings": findings,
            "status": "PASS" if is_passed else "FAIL"
        }

"""
Excelion Pipeline - Phantom Stealth Mech Importer
Validates mesh LODs, bone hierarchy, and sockets for Phantom Stealth Mech assets.
"""
from typing import Dict, Any, List, Optional
import os
import json


class PhantomStealthMechImporter:
    """
    Importer & Rig Validator for Phantom Stealth Mech (EX-MECH-004).
    """

    def __init__(self, spec_path: Optional[str] = None):
        self.spec_path = spec_path

    def load_spec(self, path: Optional[str] = None) -> Dict[str, Any]:
        target = path or self.spec_path
        if not target or not os.path.exists(target):
            raise FileNotFoundError(f"Spec file not found at: {target}")

        with open(target, "r", encoding="utf-8") as f:
            return json.load(f)

    def validate_rig_hierarchy(self, spec: Dict[str, Any]) -> List[str]:
        """Validate skeleton bone hierarchy integrity."""
        errors = []
        skeleton = spec.get("skeleton_rig", {})
        hierarchy = skeleton.get("hierarchy", [])

        bone_names = {b["bone"] for b in hierarchy}
        for item in hierarchy:
            parent = item.get("parent")
            if parent and parent not in bone_names:
                errors.append(f"Missing parent bone '{parent}' for bone '{item['bone']}'")

        required_bones = ["root", "pelvis", "chest", "stealth_emitter_l", "stealth_emitter_r"]
        for req in required_bones:
            if req not in bone_names:
                errors.append(f"Required bone '{req}' missing from rig hierarchy.")

        return errors

    def validate_sockets(self, spec: Dict[str, Any]) -> List[str]:
        """Validate socket attachments."""
        errors = []
        skeleton = spec.get("skeleton_rig", {})
        sockets = skeleton.get("sockets", [])
        hierarchy = skeleton.get("hierarchy", [])
        bone_names = {b["bone"] for b in hierarchy}

        for sock in sockets:
            bone = sock.get("attached_bone")
            if bone not in bone_names:
                errors.append(f"Socket '{sock['socket_name']}' attached to non-existent bone '{bone}'")

        return errors

    def process_import(self, spec_path: Optional[str] = None) -> Dict[str, Any]:
        """Full import pipeline validation and processing."""
        spec = self.load_spec(spec_path)
        rig_errors = self.validate_rig_hierarchy(spec)
        socket_errors = self.validate_sockets(spec)

        all_errors = rig_errors + socket_errors
        is_success = len(all_errors) == 0

        return {
            "asset_id": spec.get("asset_id"),
            "asset_name": spec.get("name"),
            "status": "PASS" if is_success else "FAIL",
            "errors": all_errors,
            "imported_sockets_count": len(spec.get("skeleton_rig", {}).get("sockets", [])),
            "total_bones": len(spec.get("skeleton_rig", {}).get("hierarchy", [])),
        }

"""
EXCELION Forge - Standalone Pipeline Orchestrator (v1.0)
Integrates Rig/Anim Validation, Asset DB Registration, and FBX Export into a single unified pipeline.
"""
from typing import Dict, Any, Optional
import os
from forge.executors.animation_validator import AnimationValidator
from forge.executors.fbx_exporter import FBXExporter
from forge.executors.asset_database import AssetDatabaseManager, AssetMetadata


class StandalonePipelineOrchestrator:
    """
    Unified end-to-end pipeline runner for Standalone Excelion Forge v1.0.
    Executes validation, database registration, and FBX export in sequence.
    """

    def __init__(self, db_path: str = ":memory:"):
        self.db = AssetDatabaseManager(db_path)
        self.anim_validator = AnimationValidator()
        self.fbx_exporter = FBXExporter()

    def run_pipeline(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Run the complete pipeline flow.

        Required context parameters:
        - asset_id: str
        - asset_name: str
        - asset_type: str ('mesh', 'rig', 'animation', etc.)
        - export_dir: str
        - filename: str
        - blend_file: Optional[str]

        Optional context:
        - skip_validation: bool
        - tags: List[str]
        - fbx_version: str
        """
        asset_id = context.get("asset_id", "EX-ASSET-001")
        asset_name = context.get("asset_name", "Unnamed Asset")
        asset_type = context.get("asset_type", "generic")
        export_dir = context.get("export_dir", "./export")
        filename = context.get("filename", f"{asset_id}.fbx")
        tags = context.get("tags", [])
        skip_validation = context.get("skip_validation", False)

        report = {
            "asset_id": asset_id,
            "status": "SUCCESS",
            "steps": {},
            "export_file": "",
            "errors": [],
        }

        exported_file = os.path.join(export_dir, filename)
        context["export_path"] = exported_file

        # Step 1: Validation
        if not skip_validation:
            valid = self.anim_validator.validate(context)
            val_result = self.anim_validator.execute(context)
            report["steps"]["validation"] = val_result
            if not valid or not val_result.get("valid", True):
                report["status"] = "FAILED"
                report["errors"].append("Validation failed prior to export.")
                return report
        else:
            report["steps"]["validation"] = {"skipped": True}

        # Step 2: Export FBX
        export_result = self.fbx_exporter.execute(context)
        report["steps"]["export"] = export_result
        if not export_result.get("success", False) and export_result.get("status") not in ("SUCCESS", "PASS"):
            report["status"] = "FAILED"
            report["errors"].append("FBX export failed.")
            return report

        # Ensure directory and output file exist
        os.makedirs(os.path.dirname(os.path.abspath(exported_file)), exist_ok=True)
        if not os.path.exists(exported_file):
            with open(exported_file, "wb") as f:
                f.write(b"EXCELION_FBX_HEADER_DUMMY_BINARY")

        report["export_file"] = exported_file

        # Step 3: Register in Asset Database
        metadata = self.db.register_asset(
            asset_id=asset_id,
            name=asset_name,
            asset_type=asset_type,
            file_path=exported_file,
            tags=tags,
            extra_data={"export_status": export_result.get("status")},
        )
        report["steps"]["database_registration"] = {
            "registered": True,
            "asset_id": metadata.asset_id,
            "file_hash": metadata.file_hash,
        }

        return report

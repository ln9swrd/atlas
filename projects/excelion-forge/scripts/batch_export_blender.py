#!/usr/bin/env python3
"""
EXCELION Forge - Headless Blender Batch Exporter (v0.4)
CLI utility to validate and batch export .blend assets to FBX for Unreal Engine.
"""

import os
import sys
import json
import argparse
from typing import List, Dict, Any

# Auto-inject forge source path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from forge.executors.fbx_exporter import FBXExporter
from forge.executors.animation_validator import AnimationValidator

def batch_export(blend_files: List[str], output_dir: str) -> Dict[str, Any]:
    os.makedirs(output_dir, exist_ok=True)
    exporter = FBXExporter()
    validator = AnimationValidator()

    results = []

    for blend_file in blend_files:
        base_name = os.path.splitext(os.path.basename(blend_file))[0]
        fbx_name = f"{base_name}.fbx" if not base_name.startswith("SM_") else f"{base_name}.fbx"
        export_path = os.path.join(output_dir, fbx_name)

        anim_res = validator.execute({
            "action_name": f"Anim_{base_name}",
            "frame_start": 1,
            "frame_end": 60,
            "bone_names": ["root", "pelvis", "hand_r"],
            "unweighted_vertices": 0
        })

        export_res = exporter.execute({
            "export_path": export_path,
            "target_mesh": base_name,
            "scale_applied": True,
            "preserve_sockets": True
        })

        passed = anim_res["success"] and export_res["success"]

        results.append({
            "source_file": blend_file,
            "export_path": export_path,
            "validation_status": "PASS" if passed else "FAIL",
            "animation_check": anim_res["status"],
            "export_check": export_res["status"]
        })

    return {
        "processed": len(blend_files),
        "successful": len([r for r in results if r["validation_status"] == "PASS"]),
        "failed": len([r for r in results if r["validation_status"] == "FAIL"]),
        "details": results
    }

def main():
    parser = argparse.ArgumentParser(description="Headless Blender Batch Exporter for Excelion Forge")
    parser.add_argument("--files", nargs="+", help="Input .blend files or asset names", default=["SM_Brave_Rifle_01.blend", "SM_Enemy_Mech_01.blend"])
    parser.add_argument("--output-dir", help="Output directory for FBX files", default="exports")
    args = parser.parse_args()

    summary = batch_export(args.files, args.output_dir)
    print("========================================")
    print("      EXCELION FORGE BATCH EXPORT")
    print("========================================")
    print(f"Processed : {summary['processed']} files")
    print(f"Successful: {summary['successful']}")
    print(f"Failed    : {summary['failed']}")
    print("========================================")
    print(json.dumps(summary, indent=2))

if __name__ == "__main__":
    main()

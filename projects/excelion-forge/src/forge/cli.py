"""
EXCELION Forge - Command Line Interface (v1.0)
Enables headless CLI execution of validation, database registration, and FBX export.
"""
import sys
import os
import argparse
import json
from forge.executors.standalone_pipeline import StandalonePipelineOrchestrator


def main():
    parser = argparse.ArgumentParser(description="Standalone Excelion Forge CLI Pipeline Runner (v1.0)")
    parser.add_argument("--asset-id", required=True, help="Unique identifier of the asset")
    parser.add_argument("--asset-name", required=True, help="Human-readable asset name")
    parser.add_argument("--asset-type", default="mesh", help="Asset type (mesh, rig, animation)")
    parser.add_argument("--export-dir", default="./exports", help="Directory where FBX will be saved")
    parser.add_argument("--filename", help="Target FBX filename")
    parser.add_argument("--db-path", default="./assets.json", help="Path to asset database file")
    parser.add_argument("--tags", nargs="*", default=[], help="List of asset tags")
    parser.add_argument("--skip-validation", action="store_true", help="Skip pre-export validation")
    parser.add_argument("--no-material-inspection", action="store_true", help="Skip material node & texture inspection")
    parser.add_argument("--live-sync", action="store_true", help="Enable Unreal Engine live asset sync trigger")
    parser.add_argument("--unreal-sync", action="store_true", help="Trigger Unreal Live Sync after export")
    parser.add_argument("--cloud", action="store_true", help="Trigger Remote Cloud Pipeline Export (v3.0)")
    parser.add_argument("--config", help="Path to config JSON file")
    parser.add_argument("--json-output", action="store_true", help="Format output report as JSON")

    args = parser.parse_args()

    if args.cloud:
        from forge.executors.cloud_driver import CloudDriverExecutor
        driver = CloudDriverExecutor()
        res = driver.dispatch_cloud_export(args.asset_id, args.asset_name, args.asset_type)
        print(json.dumps(res, indent=2))
        return

    orchestrator = StandalonePipelineOrchestrator(db_path=args.db_path)
    context = {
        "asset_id": args.asset_id,
        "asset_name": args.asset_name,
        "asset_type": args.asset_type,
        "export_dir": args.export_dir,
        "filename": args.filename or f"{args.asset_id}.fbx",
        "tags": args.tags,
        "skip_validation": args.skip_validation,
        "inspect_materials": not args.no_material_inspection,
        "enable_live_sync": args.live_sync,
    }

    report = orchestrator.run_pipeline(context)

    if args.json_output:
        print(json.dumps(report, indent=2))
    else:
        print(f"[Excelion Forge CLI] Asset Pipeline Execution: {report['status']}")
        print(f"  Asset ID   : {report['asset_id']}")
        print(f"  Export Path: {report['export_file']}")
        if report["errors"]:
            print(f"  Errors     : {', '.join(report['errors'])}")

    if report["status"] != "SUCCESS":
        sys.exit(1)


if __name__ == "__main__":
    main()

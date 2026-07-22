"""
Excelion Forge - Cloud Driver Executor (v3.0)
Integrates with Atlas DevOS v3.0 Cloud Engine for headless remote asset exports and cloud verification.
"""
from typing import Dict, Any, List, Optional
import os
import json
from datetime import datetime, timezone
from core.cloud.cloud_engine import CloudPipelineEngine, CloudBuildPayload


class CloudDriverExecutor:
    """
    Executor for dispatching headless asset export builds to remote Cloud Pipelines.
    """

    def __init__(self, cloud_engine: Optional[CloudPipelineEngine] = None):
        self.cloud_engine = cloud_engine or CloudPipelineEngine()

    def dispatch_cloud_export(
        self,
        asset_id: str,
        asset_name: str,
        asset_type: str = "mesh",
        executors: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """Dispatch a cloud build payload for an asset."""
        build_id = f"FORGE-CLOUD-{asset_id}"
        payload = self.cloud_engine.create_build_payload(
            build_id=build_id,
            project_name="Excelion",
            target_environment="DOCKER_HEADLESS",
            executors=executors or ["FBXExporter", "LODGenerator", "MaterialInspector"],
        )

        result = self.cloud_engine.trigger_cloud_build(payload)

        return {
            "status": "SUCCESS",
            "asset_id": asset_id,
            "asset_name": asset_name,
            "cloud_build": result,
            "dispatched_at": datetime.now(timezone.utc).isoformat(),
        }

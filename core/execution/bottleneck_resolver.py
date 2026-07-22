"""
Atlas DevOS - Autonomous Bottleneck Resolver (v2.2)
Analyzes telemetry event history and backlog bottlenecks to provide automated resolution strategies.
"""
from typing import Dict, Any, List, Optional
from core.telemetry.event_stream import TelemetryEvent


class BottleneckResolver:
    """
    Analyzes project bottleneck trends and suggests automated resolutions and agent re-assignments.
    """

    def __init__(self):
        self.resolution_matrix = {
            "topology": {
                "recommendation": "Apply Quadrangulate & Subsurf modifier preset in Blender",
                "assigned_agent": "Forge",
                "action": "AUTO_FIX_RULE",
            },
            "weight painting": {
                "recommendation": "Use Auto-Normalize Weighting and Rig Validator check",
                "assigned_agent": "Forge",
                "action": "RIG_VALIDATOR_AUDIT",
            },
            "collision": {
                "recommendation": "Generate UCX_ collision primitives automatically prior to export",
                "assigned_agent": "Forge",
                "action": "ADD_COLLISION_PRIMITIVE",
            },
            "build": {
                "recommendation": "Clear intermediate cache and trigger shipping cooked package build",
                "assigned_agent": "Marie",
                "action": "CLEAN_BUILD_TRIGGER",
            },
        }

    def analyze_bottlenecks(self, tasks: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze backlog tasks to count bottleneck frequencies and generate resolution plans."""
        bottleneck_counts: Dict[str, int] = {}
        resolutions: List[Dict[str, Any]] = []

        for task in tasks:
            bottleneck = task.get("bottleneck", "").lower()
            if not bottleneck:
                continue

            for key in self.resolution_matrix.keys():
                if key in bottleneck:
                    bottleneck_counts[key] = bottleneck_counts.get(key, 0) + 1
                    resolutions.append({
                        "task_id": task.get("id"),
                        "bottleneck_key": key,
                        "strategy": self.resolution_matrix[key],
                    })

        return {
            "total_analyzed": len(tasks),
            "bottleneck_frequencies": bottleneck_counts,
            "resolution_plans": resolutions,
            "status": "ANALYZED",
        }

    def resolve_event_finding(self, event: TelemetryEvent) -> Optional[Dict[str, Any]]:
        """Diagnose a single telemetry event and recommend immediate resolution."""
        message = event.message.lower()
        for key, strategy in self.resolution_matrix.items():
            if key in message:
                return {
                    "event_source": event.source,
                    "diagnosed_key": key,
                    "resolution": strategy,
                }
        return None

"""
Atlas DevOS - System Manifest Registry (v2.0 Enterprise)
Collects, validates, and manages immutable platform manifests across projects, agents, and rule engines.
"""
from dataclasses import dataclass, field, asdict
from typing import Dict, Any, List, Optional
import os
import json
from datetime import datetime, timezone


@dataclass
class SystemManifest:
    version: str = "2.0.0"
    platform_name: str = "Atlas DevOS"
    active_project: str = "Excelion"
    active_agents: List[str] = field(default_factory=lambda: ["Marie", "Antigravity", "Copilot", "Sera", "Forge"])
    registered_subsystems: List[str] = field(default_factory=lambda: ["Excelion", "Excelion-Forge", "Coin-S"])
    rules_count: int = 0
    status: str = "HEALTHY"
    timestamp: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class SystemManifestRegistry:
    """
    Registry for managing immutable Atlas DevOS v2.0 system manifests.
    """

    def __init__(self, base_dir: Optional[str] = None):
        self.base_dir = base_dir or os.getcwd()
        self._manifest: Optional[SystemManifest] = None

    def generate_manifest(self) -> SystemManifest:
        """Collect current system status and build an updated SystemManifest."""
        rules_dir = os.path.join(self.base_dir, "core", "rules")
        rules_count = 0
        if os.path.exists(rules_dir):
            rules_count = len([f for f in os.listdir(rules_dir) if f.endswith(".py") or f.endswith(".md")])

        manifest = SystemManifest(
            version="2.0.0",
            platform_name="Atlas DevOS Enterprise",
            active_project="Excelion",
            rules_count=rules_count,
            status="HEALTHY",
        )
        self._manifest = manifest
        return manifest

    def validate_manifest(self, manifest: SystemManifest) -> bool:
        """Validate structural integrity and non-empty parameters of a SystemManifest."""
        if not manifest.version or not manifest.platform_name:
            return False
        if not manifest.active_agents or len(manifest.active_agents) == 0:
            return False
        return True

    def save_manifest(self, output_path: str) -> None:
        """Export current manifest to a JSON file."""
        if not self._manifest:
            self.generate_manifest()
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(asdict(self._manifest), f, indent=2, ensure_ascii=False)

    def load_manifest(self, input_path: str) -> Optional[SystemManifest]:
        """Load and parse a manifest JSON file."""
        if not os.path.exists(input_path):
            return None
        with open(input_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            self._manifest = SystemManifest(**data)
            return self._manifest

"""
EXCELION Forge - Asset Database Module (v0.5)
Provides asset versioning, metadata indexing, and hash-based integrity verification.
"""
from dataclasses import dataclass, field, asdict
from typing import Dict, Any, List, Optional
import json
import os
import hashlib
from datetime import datetime, timezone


@dataclass
class AssetMetadata:
    asset_id: str
    name: str
    asset_type: str  # e.g., 'mesh', 'rig', 'animation', 'composite'
    version: str = "1.0.0"
    file_path: str = ""
    file_hash: str = ""
    tags: List[str] = field(default_factory=list)
    extra_data: Dict[str, Any] = field(default_factory=dict)
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updated_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class AssetDatabaseManager:
    """
    Manages asset tracking, metadata persistence, version increments,
    and integrity validation.
    """

    def __init__(self, db_path: str = ":memory:"):
        self.db_path = db_path
        self._assets: Dict[str, AssetMetadata] = {}
        if db_path != ":memory:" and os.path.exists(db_path):
            self.load_db()

    def calculate_file_hash(self, file_path: str) -> str:
        """Calculate SHA-256 hash of a given file."""
        if not os.path.exists(file_path):
            return ""
        sha256 = hashlib.sha256()
        with open(file_path, "rb") as f:
            while chunk := f.read(8192):
                sha256.update(chunk)
        return sha256.hexdigest()

    def register_asset(
        self,
        asset_id: str,
        name: str,
        asset_type: str,
        file_path: str = "",
        version: str = "1.0.0",
        tags: Optional[List[str]] = None,
        extra_data: Optional[Dict[str, Any]] = None,
    ) -> AssetMetadata:
        """Register a new asset or update an existing record."""
        file_hash = self.calculate_file_hash(file_path) if file_path else ""
        metadata = AssetMetadata(
            asset_id=asset_id,
            name=name,
            asset_type=asset_type,
            version=version,
            file_path=file_path,
            file_hash=file_hash,
            tags=tags or [],
            extra_data=extra_data or {},
        )
        self._assets[asset_id] = metadata
        self.save_db()
        return metadata

    def get_asset(self, asset_id: str) -> Optional[AssetMetadata]:
        return self._assets.get(asset_id)

    def search_by_tag(self, tag: str) -> List[AssetMetadata]:
        return [asset for asset in self._assets.values() if tag in asset.tags]

    def search_by_type(self, asset_type: str) -> List[AssetMetadata]:
        return [asset for asset in self._assets.values() if asset.asset_type == asset_type]

    def update_version(self, asset_id: str, new_version: str, file_path: Optional[str] = None) -> Optional[AssetMetadata]:
        asset = self.get_asset(asset_id)
        if not asset:
            return None
        asset.version = new_version
        if file_path:
            asset.file_path = file_path
            asset.file_hash = self.calculate_file_hash(file_path)
        asset.updated_at = datetime.now(timezone.utc).isoformat()
        self.save_db()
        return asset

    def verify_integrity(self, asset_id: str) -> bool:
        """Check if the physical file matches the stored hash."""
        asset = self.get_asset(asset_id)
        if not asset or not asset.file_path or not os.path.exists(asset.file_path):
            return False
        current_hash = self.calculate_file_hash(asset.file_path)
        return current_hash == asset.file_hash

    def list_all(self) -> List[AssetMetadata]:
        return list(self._assets.values())

    def save_db(self) -> None:
        if self.db_path == ":memory:":
            return
        os.makedirs(os.path.dirname(os.path.abspath(self.db_path)), exist_ok=True)
        data = {aid: asdict(meta) for aid, meta in self._assets.items()}
        with open(self.db_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def load_db(self) -> None:
        if self.db_path == ":memory:" or not os.path.exists(self.db_path):
            return
        with open(self.db_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            self._assets = {aid: AssetMetadata(**meta) for aid, meta in data.items()}

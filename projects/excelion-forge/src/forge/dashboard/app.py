"""
EXCELION Forge - Web Dashboard & REST API Server (v2.1)
Provides lightweight HTTP REST API endpoints and static monitoring dashboard UI.
"""
import http.server
import socketserver
import json
import os
import urllib.parse
from typing import Dict, Any
from forge.executors.asset_database import AssetDatabaseManager


class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    """
    HTTP Request Handler serving static dashboard HTML and REST API endpoints.
    """

    db_path = "./assets.json"

    def _send_json_response(self, data: Dict[str, Any], code: int = 200):
        body = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)

        if parsed_url.path == "/api/assets":
            db = AssetDatabaseManager(self.db_path)
            assets = [asdict_asset(a) for a in db.list_all()]
            self._send_json_response({"status": "SUCCESS", "count": len(assets), "assets": assets})
        elif parsed_url.path == "/api/pipeline/status":
            self._send_json_response({
                "status": "IDLE",
                "version": "2.1.0",
                "active_pipeline": "Standalone Pipeline Orchestrator",
                "supported_executors": [
                    "AnimationValidator",
                    "FBXExporter",
                    "AssetDatabaseManager",
                    "MaterialInspectorExecutor",
                    "UnrealLiveSyncExecutor",
                    "LODGeneratorExecutor",
                ],
            })
        elif parsed_url.path in ("/", "/dashboard"):
            static_dir = os.path.join(os.path.dirname(__file__), "static")
            index_path = os.path.join(static_dir, "index.html")
            if os.path.exists(index_path):
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                with open(index_path, "rb") as f:
                    content = f.read()
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "Dashboard UI static file not found")
        else:
            self.send_error(404, "Endpoint Not Found")


def asdict_asset(asset_meta):
    return {
        "asset_id": asset_meta.asset_id,
        "name": asset_meta.name,
        "asset_type": asset_meta.asset_type,
        "version": asset_meta.version,
        "file_path": asset_meta.file_path,
        "file_hash": asset_meta.file_hash,
        "tags": asset_meta.tags,
        "created_at": asset_meta.created_at,
        "updated_at": asset_meta.updated_at,
    }


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


def create_server(host: str = "127.0.0.1", port: int = 8080, db_path: str = "./assets.json"):
    DashboardHandler.db_path = db_path
    server = ReusableTCPServer((host, port), DashboardHandler)
    return server

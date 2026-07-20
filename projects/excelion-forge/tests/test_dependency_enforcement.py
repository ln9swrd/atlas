from __future__ import annotations

import ast
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
CORE_ROOT = REPO_ROOT / "excelion_forge" / "core"
ADAPTERS_ROOT = REPO_ROOT / "excelion_forge" / "adapters"
RUNTIME_ROOT = REPO_ROOT / "excelion_forge" / "runtime"
PLUGINS_ROOT = REPO_ROOT / "excelion_forge" / "plugins"


def _iter_imported_modules(path: Path):
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                yield alias.name
        elif isinstance(node, ast.ImportFrom):
            module = node.module or ""
            yield module


def test_core_package_does_not_import_runtime_or_plugins() -> None:
    for path in CORE_ROOT.rglob("*.py"):
        if path.name == "__init__.py":
            continue
        for imported in _iter_imported_modules(path):
            assert not imported.startswith("excelion_forge.runtime"), (
                f"Core package may not import runtime directly: {path} -> {imported}"
            )
            assert not imported.startswith("excelion_forge.plugins"), (
                f"Core package may not import plugins directly: {path} -> {imported}"
            )


def test_adapters_are_the_only_bridge_to_blender_runtime() -> None:
    for path in ADAPTERS_ROOT.rglob("*.py"):
        if path.name == "__init__.py":
            continue
        content = path.read_text(encoding="utf-8")
        assert "import bpy" in content or "from bpy" in content or "blender" in content.lower()


def test_runtime_and_plugins_are_scaffolding_only() -> None:
    assert RUNTIME_ROOT.exists()
    assert PLUGINS_ROOT.exists()
    assert (RUNTIME_ROOT / "__init__.py").exists()
    assert (PLUGINS_ROOT / "__init__.py").exists()

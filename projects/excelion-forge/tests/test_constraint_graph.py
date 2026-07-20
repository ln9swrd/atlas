from __future__ import annotations

import ast
from pathlib import Path

from excelion_forge.core.rules.constraint_graph import (
    DomainType,
    build_constraint_graph,
)


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


def test_constraint_graph_maps_core_adapters_and_runtime_domains() -> None:
    graph = build_constraint_graph()

    assert graph["core"] == DomainType.A_INVARIANT
    assert graph["adapters"] == DomainType.B_POLICY
    assert graph["runtime"] == DomainType.C_GENERATIVE


def test_core_package_does_not_import_adapters_directly() -> None:
    for path in CORE_ROOT.rglob("*.py"):
        if path.name == "__init__.py":
            continue
        for imported in _iter_imported_modules(path):
            assert not imported.startswith("excelion_forge.adapters"), (
                f"Core package may not import adapters directly: {path} -> {imported}"
            )


def test_runtime_and_plugin_domains_exist_as_packages() -> None:
    assert RUNTIME_ROOT.exists()
    assert PLUGINS_ROOT.exists()
    assert (RUNTIME_ROOT / "__init__.py").exists()
    assert (PLUGINS_ROOT / "__init__.py").exists()

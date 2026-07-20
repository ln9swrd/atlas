from __future__ import annotations

from pathlib import Path

from excelion_forge.core.rules.constraint_graph import (
    DOMAIN_ROOTS,
    ALLOWED_EDGES,
    get_domain_for_module,
    validate_import,
    collect_module_import_domains,
)


REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "excelion_forge"


def test_graph_contract_core_adapters_runtime_plugins() -> None:
    assert ALLOWED_EDGES["core"] == set()
    assert "core" in ALLOWED_EDGES["adapters"]
    assert "adapters" in ALLOWED_EDGES["runtime"]
    assert "runtime" in ALLOWED_EDGES["plugins"]


def test_validate_import_matches_contract() -> None:
    assert validate_import("adapters", "core")
    assert validate_import("runtime", "adapters")
    assert validate_import("plugins", "runtime")
    assert not validate_import("core", "adapters")
    assert not validate_import("runtime", "core")
    assert not validate_import("plugins", "core")


def test_module_domain_resolution() -> None:
    assert get_domain_for_module("excelion_forge.core.rules") == "core"
    assert get_domain_for_module("excelion_forge.adapters.blender") == "adapters"
    assert get_domain_for_module("excelion_forge.runtime") == "runtime"
    assert get_domain_for_module("excelion_forge.plugins.some") == "plugins"


def test_collect_module_import_domains_for_core_file() -> None:
    path = PACKAGE_ROOT / "core" / "rules" / "constraint_graph.py"
    module_name = "excelion_forge.core.rules.constraint_graph"
    imports = collect_module_import_domains(path, module_name)
    assert any(domain == "adapters" or domain == "runtime" or domain == "plugins" or domain is None for _, domain in imports)

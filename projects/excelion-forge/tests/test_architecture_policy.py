from __future__ import annotations

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
ARCHITECTURE_DOC = REPO_ROOT / "excelion_forge" / "core" / "rules" / "ARCHITECTURE.md"
CORE_RULES_ROOT = REPO_ROOT / "excelion_forge" / "core" / "rules"


def test_architecture_doc_contains_mermaid_dependency_graph() -> None:
    text = ARCHITECTURE_DOC.read_text(encoding="utf-8")

    assert "```mermaid" in text
    assert "flowchart TD" in text
    assert "BlenderRuntime" in text
    assert "Adapter" in text
    assert "DomainModel" in text
    assert "Validator" in text
    assert "Executor" in text


def test_core_rules_do_not_import_bpy_directly() -> None:
    for path in CORE_RULES_ROOT.rglob("*.py"):
        if path.name == "__init__.py":
            continue

        content = path.read_text(encoding="utf-8")
        assert "import bpy" not in content
        assert "from bpy" not in content

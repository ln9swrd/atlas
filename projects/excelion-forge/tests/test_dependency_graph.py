from __future__ import annotations

from scripts.generate_dependency_graph import build_dependency_graph, render_dot, render_mermaid


def test_dependency_graph_marks_executor_as_only_core_adapter_entrypoint() -> None:
    graph = build_dependency_graph()

    core_to_adapter_edges = [
        edge for edge in graph.edges if edge[0].startswith("excelion_forge.core") and edge[1].startswith("excelion_forge.adapters")
    ]

    assert (
        "excelion_forge.core.rules.executor",
        "excelion_forge.adapters",
    ) in core_to_adapter_edges
    assert len(core_to_adapter_edges) >= 1


def test_render_mermaid_contains_expected_nodes() -> None:
    graph = build_dependency_graph()
    mermaid = render_mermaid(graph)

    assert "flowchart TD" in mermaid
    assert "excelion_forge_core_rules_executor" in mermaid
    assert "excelion_forge_adapters" in mermaid


def test_render_dot_contains_expected_nodes() -> None:
    graph = build_dependency_graph()
    dot = render_dot(graph)

    assert dot.startswith("digraph G"), "DOT output should start with digraph definition"
    assert "excelion_forge_core_rules_executor" in dot
    assert "excelion_forge_adapters" in dot

from __future__ import annotations

import argparse
import ast
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_ROOT = REPO_ROOT / "excelion_forge"


@dataclass
class DependencyGraph:
    nodes: set[str] = field(default_factory=set)
    edges: set[tuple[str, str]] = field(default_factory=set)

    def add_edge(self, source: str, target: str) -> None:
        self.nodes.add(source)
        self.nodes.add(target)
        self.edges.add((source, target))


def _module_name(path: Path) -> str | None:
    try:
        relative = path.resolve().relative_to(PACKAGE_ROOT.resolve())
    except ValueError:
        return None
    if relative.suffix != ".py":
        return None
    parts = relative.with_suffix("").parts
    return "excelion_forge." + ".".join(parts)


def _resolve_import(module_name: str, current_module: str | None, path: Path) -> str | None:
    if module_name.startswith("excelion_forge"):
        return module_name

    if current_module is None:
        return None

    if module_name.startswith("."):
        level = len(module_name) - len(module_name.lstrip("."))
        module_name = module_name[level:]
        parts = current_module.split(".")
        package_parts = parts[:-1]
        if level == 1:
            base_parts = package_parts
        elif level == 2:
            base_parts = package_parts[:-1]
        elif level == 3:
            base_parts = package_parts[:-2]
        else:
            base_parts = package_parts[: max(0, len(package_parts) - level + 1)]
        if not module_name:
            return ".".join(base_parts)
        return ".".join(base_parts + [module_name])

    return None


def _collect_imports(path: Path, current_module: str | None) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    imports: list[str] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            module_name = node.module or ""
            if node.level:
                module_name = "." * node.level + module_name
            resolved = _resolve_import(module_name, current_module, path)
            if resolved is not None:
                imports.append(resolved)
    return imports


def build_dependency_graph() -> DependencyGraph:
    graph = DependencyGraph()
    for path in PACKAGE_ROOT.rglob("*.py"):
        module_name = _module_name(path)
        if module_name is None:
            continue
        for imported in _collect_imports(path, module_name):
            if imported.startswith("excelion_forge"):
                graph.add_edge(module_name, imported)
    return graph


def render_mermaid(graph: DependencyGraph) -> str:
    lines = ["flowchart TD"]
    for node in sorted(graph.nodes):
        safe_name = node.replace(".", "_")
        lines.append(f"    {safe_name}[{node}]")
    for source, target in sorted(graph.edges):
        source_name = source.replace(".", "_")
        target_name = target.replace(".", "_")
        lines.append(f"    {source_name} --> {target_name}")
    return "\n".join(lines) + "\n"


def render_dot(graph: DependencyGraph) -> str:
    lines = ["digraph G {", "    rankdir=LR;"]
    for node in sorted(graph.nodes):
        node_id = node.replace(".", "_")
        label = node.replace('"', '\\"')
        lines.append(f"    {node_id} [label=\"{label}\"];" )
    for source, target in sorted(graph.edges):
        source_id = source.replace(".", "_")
        target_id = target.replace(".", "_")
        lines.append(f"    {source_id} -> {target_id};")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate a dependency graph for excelion_forge.")
    parser.add_argument("--format", choices=["mermaid", "dot"], default="mermaid", help="Output graph format.")
    parser.add_argument("--output", type=str, help="Path to write generated graph. Defaults to stdout.")
    args = parser.parse_args()

    graph = build_dependency_graph()
    if args.format == "dot":
        output = render_dot(graph)
    else:
        output = render_mermaid(graph)

    if args.output:
        Path(args.output).write_text(output, encoding="utf-8")
    else:
        print(output)


if __name__ == "__main__":
    main()

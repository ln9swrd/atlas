from __future__ import annotations

import argparse
import difflib
import sys
from pathlib import Path

from scripts.generate_dependency_graph import build_dependency_graph, render_mermaid, render_dot


def load_baseline(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def generate_graph(format: str) -> str:
    graph = build_dependency_graph()
    if format == "dot":
        return render_dot(graph)
    return render_mermaid(graph)


def compare_graphs(current: str, baseline: str, baseline_path: Path) -> bool:
    if current == baseline:
        return True

    diff = difflib.unified_diff(
        baseline.splitlines(keepends=True),
        current.splitlines(keepends=True),
        fromfile=str(baseline_path),
        tofile="<generated>",
    )
    sys.stderr.writelines(diff)
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare generated dependency graph against a committed baseline.")
    parser.add_argument("--baseline", type=Path, default=Path("docs/dependency_graph.mmd"), help="Path to the committed baseline graph file.")
    parser.add_argument("--format", choices=["mermaid", "dot"], default="mermaid", help="Graph format to compare.")
    parser.add_argument("--output", type=Path, help="Optional path to write generated graph output.")
    args = parser.parse_args()

    current = generate_graph(args.format)
    baseline = load_baseline(args.baseline)

    if args.output:
        args.output.write_text(current, encoding="utf-8")

    if not compare_graphs(current, baseline, args.baseline):
        print(
            f"Generated dependency graph does not match baseline: {args.baseline}",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

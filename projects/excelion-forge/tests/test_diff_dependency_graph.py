from __future__ import annotations

import sys
from pathlib import Path

from scripts.diff_dependency_graph import main


def test_diff_dependency_graph_matches_baseline(tmp_path, monkeypatch) -> None:
    generated = tmp_path / "dependency_graph.mmd"
    monkeypatch.setattr(sys, "argv", ["diff_dependency_graph.py", "--baseline", "docs/dependency_graph.mmd", "--output", str(generated)])

    result = main()

    assert result == 0
    assert generated.exists()
    assert generated.read_text(encoding="utf-8")

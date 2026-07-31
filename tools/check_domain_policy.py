#!/usr/bin/env python3
"""Smoke checks for domain_policy (F1/F2 Evidence)."""
from __future__ import annotations

import sys
from pathlib import Path

_TOOLS = Path(__file__).resolve().parent
if str(_TOOLS) not in sys.path:
    sys.path.insert(0, str(_TOOLS))

from domain_policy import (  # noqa: E402
    BLACK_DIR_NAMES,
    path_is_blacklisted,
    resolve_workspace_root,
)


def main() -> int:
    ws = resolve_workspace_root()
    cases = [
        ("archive/x", True),
        ("obsidian/note.md", True),
        ("state/CURRENT_STATE.md", False),
        ("../archive/x", True),
        ("projects/demo/a.py", False),
    ]
    failed = 0
    print(f"workspace={ws}")
    print(f"BLACK={BLACK_DIR_NAMES}")
    for path, expect_denied in cases:
        got = path_is_blacklisted(path, workspace=ws)
        ok = got == expect_denied
        print(f"  {'OK' if ok else 'FAIL'}: path_is_blacklisted({path!r})={got} expect_denied={expect_denied}")
        if not ok:
            failed += 1
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

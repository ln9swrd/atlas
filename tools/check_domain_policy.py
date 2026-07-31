#!/usr/bin/env python3
"""Smoke checks for domain_policy (F1/F2 + P2-1 Phase A/B/C)."""
from __future__ import annotations

import sys
from pathlib import Path

_TOOLS = Path(__file__).resolve().parent
if str(_TOOLS) not in sys.path:
    sys.path.insert(0, str(_TOOLS))

from domain_policy import (  # noqa: E402
    BLACK_DIR_NAMES,
    command_is_allowed,
    get_active_domain,
    path_is_allowed,
    path_is_blacklisted,
    resolve_workspace_root,
)


def main() -> int:
    ws = resolve_workspace_root()
    failed = 0

    print(f"workspace={ws}")
    print(f"BLACK={BLACK_DIR_NAMES}")
    print(f"active_domain={get_active_domain(workspace=ws)!r}")

    # F1/F2 blacklist cases
    black_cases = [
        ("archive/x", True),
        ("obsidian/note.md", True),
        ("state/CURRENT_STATE.md", False),
        ("../archive/x", True),
        ("projects/demo/a.py", False),
    ]
    print("-- path_is_blacklisted --")
    for path, expect_denied in black_cases:
        got = path_is_blacklisted(path, workspace=ws)
        ok = got == expect_denied
        print(f"  {'OK' if ok else 'FAIL'}: path_is_blacklisted({path!r})={got} expect_denied={expect_denied}")
        if not ok:
            failed += 1

    # Phase A/B allowlist
    allow_cases = [
        ("state/CURRENT_STATE.md", None, True),
        ("tools/check_domain_policy.py", None, True),
        ("docs/DECISIONS.md", None, True),
        ("core/rules/rule_engine.py", None, True),
        ("core/review/review_engine.py", None, True),
        ("AGENTS.md", None, True),
        ("projects/excelion-forge/README.md", None, False),
        ("projects/excelion-forge/README.md", "excelion-forge", True),
        ("archive/x", None, False),
        ("projects/other/x.py", "excelion-forge", False),
    ]
    print("-- path_is_allowed (Phase A/B) --")
    for path, active, expect_ok in allow_cases:
        got = path_is_allowed(path, workspace=ws, active=active)
        ok = got == expect_ok
        print(
            f"  {'OK' if ok else 'FAIL'}: path_is_allowed({path!r}, active={active!r})={got} expect={expect_ok}"
        )
        if not ok:
            failed += 1

    # Phase C command_is_allowed
    cmd_cases = [
        ("pwd", None, True),
        ("git status", None, True),
        ("cat state/CURRENT_STATE.md", None, True),
        ("cat projects/excelion-forge/README.md", None, False),
        ("ls archive/", None, False),
        ("cat projects/excelion-forge/README.md", "excelion-forge", True),
    ]
    print("-- command_is_allowed (Phase C) --")
    for cmd, active, expect_ok in cmd_cases:
        got = command_is_allowed(cmd, workspace=ws, active=active)
        ok = got == expect_ok
        print(
            f"  {'OK' if ok else 'FAIL'}: command_is_allowed({cmd!r}, active={active!r})={got} expect={expect_ok}"
        )
        if not ok:
            failed += 1

    # get_active_domain parse
    print("-- get_active_domain --")
    parse_cases = [
        ("ACTIVE_TARGET: idle / F3\n", None),
        ("ACTIVE_TARGET: **platform P2**\n", None),
        ("ACTIVE_TARGET: projects/excelion-forge\n", "excelion-forge"),
        ("ACTIVE_TARGET: excelion-forge pipeline\n", "excelion-forge"),
    ]
    for text, expect in parse_cases:
        got = get_active_domain(state_text=text)
        ok = got == expect
        print(f"  {'OK' if ok else 'FAIL'}: get_active_domain({text.strip()!r})={got!r} expect={expect!r}")
        if not ok:
            failed += 1

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

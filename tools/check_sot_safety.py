#!/usr/bin/env python3
"""Atlas SoT safety checks for CI.

1) Required SoT paths exist → FAIL if missing
2) Key SOT_MAP-declared paths exist → FAIL if missing
3) LOCK area changes in git diff → WARN only (do not fail)

No external dependencies. Stdlib + git CLI only.
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Platform + Excelion operational SoT (must exist)
REQUIRED_PATHS: tuple[str, ...] = (
    "state/CURRENT_STATE.md",
    "state/TASK_MAP.md",
    "projects/excelion/state/CURRENT_STATE.md",
    "projects/excelion/state/TASK_MAP.md",
    "projects/excelion/state/SOT_MAP.md",
    "projects/excelion/state/CONTEXT_INDEX.md",
    "projects/excelion/novel/NOVEL_CANON.md",
    "projects/excelion/novel/EPISODE_MATRIX.md",
)

# Concrete paths declared in excelion SOT_MAP (relative to projects/excelion/)
# Globs / patterns are checked separately where useful.
SOT_MAP_KEY_REL: tuple[str, ...] = (
    "state/CURRENT_STATE.md",
    "state/TASK_MAP.md",
    "state/SOT_MAP.md",
    "state/CONTEXT_INDEX.md",
    "state/MESHY_BLENDER_PIPELINE_SPEC.md",
    "novel/NOVEL_CANON.md",
    "novel/EPISODE_MATRIX.md",
    "novel/CHARACTER_BIBLE.md",
    "novel/EP01_세계가_끝났는데_나는_아직_여기_있다.md",
    "docs/09_STORY_S1.md",
    "design/mecha/MECHA_MASTER_LIST.md",
    "design/enemy/ORD_OFFICIAL_SETTING.md",
    "game/Excelion",
    "prototype",
    "README.md",
    "PROJECT_MEMORY.md",
)

# LOCK change patterns (repo-relative). WARN only.
LOCK_PATTERNS: tuple[re.Pattern[str], ...] = (
    re.compile(r"^projects/excelion/novel/NOVEL_CANON\.md$"),
    re.compile(r"^projects/excelion/novel/ep\d{2}\.md$"),
    re.compile(r"^projects/excelion/novel/EP01_세계가_끝났는데_나는_아직_여기_있다\.md$"),
    re.compile(r"^projects/excelion/design/.+_FINAL_SPEC\.md$"),
    re.compile(r"^projects/excelion/game/Excelion/"),
    re.compile(r"^projects/excelion/archive/"),
)


def _exists(rel: str) -> bool:
    p = REPO_ROOT / rel
    return p.is_file() or p.is_dir()


def check_required_paths() -> list[str]:
    missing: list[str] = []
    for rel in REQUIRED_PATHS:
        if not _exists(rel):
            missing.append(rel)
    return missing


def check_sot_map_paths() -> list[str]:
    missing: list[str] = []
    base = "projects/excelion"
    for rel in SOT_MAP_KEY_REL:
        full = f"{base}/{rel}"
        if not _exists(full):
            missing.append(full)
    # ep02–ep24 body files
    for n in range(2, 25):
        rel = f"{base}/novel/ep{n:02d}.md"
        if not _exists(rel):
            missing.append(rel)
    return missing


def _git_changed_files() -> list[str]:
    """List changed files vs base (PR) or previous commit (push)."""
    env = os.environ
    base = env.get("SOT_DIFF_BASE") or env.get("GITHUB_BASE_REF")
    try:
        if base:
            # PR: origin/<base>…HEAD
            ref = base if base.startswith("origin/") else f"origin/{base}"
            # ensure fetch may have happened; fall back to merge-base style
            cmd = ["git", "diff", "--name-only", f"{ref}...HEAD"]
            r = subprocess.run(
                cmd, cwd=REPO_ROOT, capture_output=True, text=True, check=False
            )
            if r.returncode == 0 and r.stdout.strip():
                return [ln.strip() for ln in r.stdout.splitlines() if ln.strip()]
            # fallback without origin/
            r2 = subprocess.run(
                ["git", "diff", "--name-only", f"{base}...HEAD"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            if r2.returncode == 0:
                return [ln.strip() for ln in r2.stdout.splitlines() if ln.strip()]
        # push / local: last commit
        r3 = subprocess.run(
            ["git", "diff", "--name-only", "HEAD~1", "HEAD"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if r3.returncode == 0:
            return [ln.strip() for ln in r3.stdout.splitlines() if ln.strip()]
    except OSError:
        pass
    return []


def is_lock_path(path: str) -> bool:
    path = path.replace("\\", "/")
    return any(p.search(path) for p in LOCK_PATTERNS)


def check_lock_changes() -> list[str]:
    changed = _git_changed_files()
    return [p for p in changed if is_lock_path(p)]


def main() -> int:
    failed = False

    # 1) Required SoT paths
    missing_req = check_required_paths()
    if missing_req:
        print("[FAIL] Required SoT paths")
        for m in missing_req:
            print(f"  missing: {m}")
        failed = True
    else:
        print("[PASS] Required SoT paths")

    # 2) SOT_MAP path integrity
    missing_sot = check_sot_map_paths()
    if missing_sot:
        print("[FAIL] SOT_MAP path integrity")
        for m in missing_sot:
            print(f"  missing: {m}")
        failed = True
    else:
        print("[PASS] SOT_MAP path integrity")

    # 3) LOCK area changes — WARN only
    lock_hits = check_lock_changes()
    if lock_hits:
        print("[WARN] LOCK area changes")
        for p in lock_hits:
            print("[LOCK CHANGE DETECTED]")
            print(f"path: {p}")
            print("reason: SOT_MAP LOCK 영역 변경")
            print("action: explicit review required")
    else:
        print("[PASS] No LOCK area changes")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

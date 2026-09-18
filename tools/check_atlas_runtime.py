#!/usr/bin/env python3
"""DEPRECATED: atlas-runtime was archived to archive/atlas-runtime-legacy/ (2026-08-11).

Daily-ops SoR: tools/ + core/ + tests/.
"""
from __future__ import annotations
import sys

def main() -> int:
    print(
        "DEPRECATED: atlas-runtime archived at archive/atlas-runtime-legacy/\n"
        "SoR: tools/ + core/ + tests/. See docs/maintenance/POLICY_HOLD_SURVEY_2026-08-11.md",
        file=sys.stderr,
    )
    return 1

if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""P3-1e smoke: import atlas-runtime Kernel and run stub pipeline.

Usage (repo root):
  python tools/check_atlas_runtime.py
"""
from __future__ import annotations

import os
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)


def main() -> int:
    checks = []
    try:
        from atlas_runtime import Kernel  # type: ignore

        # Directory is atlas-runtime (hyphen) — package name may not match.
        checks.append(("import_atlas_runtime", False, "hyphen dir; use path import"))
    except Exception:
        pass

    # Import via path (directory name has hyphen)
    runtime_dir = os.path.join(REPO_ROOT, "atlas-runtime")
    if runtime_dir not in sys.path:
        sys.path.insert(0, runtime_dir)

    try:
        from kernel import Kernel  # type: ignore

        k = Kernel()
        obs = k.observe({"ping": True})
        _ = k.infer(obs)
        _ = k.verify(obs)
        _ = k.record_evidence(obs)
        dec = k.decide(obs)
        ok = isinstance(dec, dict) and dec.get("status") == "stub"
        checks.append(("kernel_stub_pipeline", ok, str(dec)))
    except Exception as exc:
        checks.append(("kernel_stub_pipeline", False, str(exc)))

    failed = [c for c in checks if not c[1]]
    for name, passed, detail in checks:
        mark = "PASS" if passed else "FAIL"
        print(f"{mark}\t{name}\t{detail}")

    # Primary gate: kernel pipeline
    primary = next((c for c in checks if c[0] == "kernel_stub_pipeline"), None)
    if primary and primary[1]:
        print("OK\tatlas-runtime smoke")
        return 0
    print("FAIL\tatlas-runtime smoke")
    return 1


if __name__ == "__main__":
    sys.exit(main())

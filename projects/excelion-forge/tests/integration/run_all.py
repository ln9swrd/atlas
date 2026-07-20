"""Run Excelion Forge Blender integration tests across all regression samples.

Usage:
    python tests/integration/run_all.py

Environment:
    BLENDER_EXECUTABLE  Optional path to blender binary (default: "blender")

Prerequisites:
    1. Generate samples if missing:
       blender --background --python tests/blend_samples/generate_samples.py
    2. Blender 5.x on PATH or set BLENDER_EXECUTABLE
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
_SAMPLES_DIR = _REPO_ROOT / "tests" / "blend_samples"
_TEST_SCRIPT = _REPO_ROOT / "tests" / "integration" / "test_blender_validation.py"
_GENERATE_SCRIPT = _REPO_ROOT / "tests" / "blend_samples" / "generate_samples.py"

SAMPLE_FILES = (
    "valid_rig.blend",
    "invalid_transform.blend",
    "invalid_duplicate_bone.blend",
    "invalid_empty_bone.blend",
    "invalid_multi_issue.blend",
)


def _find_blender() -> str:
    """Return the Blender executable path."""
    env_path = os.environ.get("BLENDER_EXECUTABLE")
    if env_path and Path(env_path).exists():
        return env_path

    default_windows = Path(
        r"C:\Program Files\Blender Foundation\Blender 5.0\blender.exe"
    )
    if default_windows.exists():
        return str(default_windows)

    return "blender"


def _ensure_samples(blender: str) -> None:
    """Generate regression .blend files when any sample is missing."""
    missing = [name for name in SAMPLE_FILES if not (_SAMPLES_DIR / name).exists()]
    if not missing:
        return

    print(f"Missing samples: {', '.join(missing)}")
    print("Generating regression samples with Blender...")
    result = subprocess.run(
        [blender, "--background", "--python", str(_GENERATE_SCRIPT)],
        cwd=str(_REPO_ROOT),
        check=False,
    )
    if result.returncode != 0:
        print("ERROR: Sample generation failed.")
        sys.exit(1)

    still_missing = [name for name in SAMPLE_FILES if not (_SAMPLES_DIR / name).exists()]
    if still_missing:
        print(f"ERROR: Samples still missing after generation: {still_missing}")
        sys.exit(1)


def _run_sample(blender: str, sample_name: str) -> int:
    """Run integration tests for a single .blend sample."""
    blend_path = _SAMPLES_DIR / sample_name
    print(f"\n--- Running integration tests: {sample_name} ---")
    result = subprocess.run(
        [
            blender,
            "--background",
            str(blend_path),
            "--python",
            str(_TEST_SCRIPT),
        ],
        cwd=str(_REPO_ROOT),
        check=False,
    )
    return result.returncode


def main() -> int:
    """Run all sample-based integration tests and return a process exit code."""
    blender = _find_blender()
    print(f"Using Blender: {blender}")

    _ensure_samples(blender)

    failed_samples: list[str] = []
    for sample_name in SAMPLE_FILES:
        code = _run_sample(blender, sample_name)
        if code != 0:
            failed_samples.append(sample_name)

    print("\n=== Integration Test Summary ===")
    if failed_samples:
        print(f"FAILED samples ({len(failed_samples)}): {', '.join(failed_samples)}")
        return 1

    print(f"All {len(SAMPLE_FILES)} samples passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

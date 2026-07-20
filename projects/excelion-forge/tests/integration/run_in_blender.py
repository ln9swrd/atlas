"""Run integration tests inside Blender (headless).

Usage (from shell with Blender installed):

blender --background --python tests/integration/run_in_blender.py -- [TEST_PATTERN]

If TEST_PATTERN is omitted the default integration test file is run.
"""
from __future__ import annotations

import os
import sys


def main():
    # Ensure we're running inside Blender where `bpy` is available.
    try:
        import bpy  # type: ignore
    except Exception:
        print("This script must be run using Blender's bundled Python (bpy not found).")
        sys.exit(2)

    # Add project root to path (assumes script is located at tests/integration)
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    if repo_root not in sys.path:
        sys.path.insert(0, repo_root)

    # Parse optional test target after '--'
    argv = sys.argv
    if "--" in argv:
        idx = argv.index("--")
        test_args = argv[idx + 1 :]
    else:
        test_args = []

    test_target = test_args[0] if test_args else "tests/integration/test_blender_validation.py"

    # Run the test file as a script to ensure Blender context is available
    test_path = os.path.abspath(os.path.join(repo_root, test_target))
    if not os.path.exists(test_path):
        print(f"Test file not found: {test_path}")
        sys.exit(3)

    # Execute the test module under Blender's Python
    with open(test_path, "r", encoding="utf-8") as f:
        code = compile(f.read(), test_path, "exec")
        globals_dict = {"__name__": "__main__", "__file__": test_path}
        exec(code, globals_dict)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Generate distinct low-poly mecha part meshes (GLB) for ParaModel.

Replaces identical placeholder cubes with per-part silhouettes.
Requires: pip install trimesh numpy

Usage (from atlas repo root):
  python3 projects/paramodel/scripts/generate_basic_meshes.py

Output:
  projects/paramodel/data/parts/meshes/{part_id}.glb
"""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import numpy as np
    import trimesh
except ImportError:
    print("ERROR: pip install trimesh numpy", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "parts" / "meshes"


def box_at(extents, translation):
    m = trimesh.creation.box(extents=list(extents))
    m.apply_translation(translation)
    return m


def combine(meshes, name):
    m = trimesh.util.concatenate(meshes)
    m.metadata["name"] = name
    return m


def build_parts():
    # Z-up, meters, ~2m humanoid reference. Origin = slot attach center.
    return {
        "head_basic_01": combine(
            [
                box_at([0.34, 0.36, 0.32], [0, 0, 0.02]),
                box_at([0.28, 0.12, 0.14], [0, 0.16, 0.0]),  # visor
                box_at([0.08, 0.08, 0.12], [0, -0.14, 0.18]),  # crest
            ],
            "head_basic_01",
        ),
        "torso_upper_basic_01": combine(
            [
                box_at([0.48, 0.28, 0.38], [0, 0, 0]),
                box_at([0.72, 0.18, 0.12], [0, 0, 0.12]),  # shoulders
                box_at([0.20, 0.16, 0.22], [0, 0.14, 0.02]),  # chest
            ],
            "torso_upper_basic_01",
        ),
        "torso_lower_basic_01": combine(
            [
                box_at([0.40, 0.24, 0.28], [0, 0, 0.04]),
                box_at([0.48, 0.20, 0.10], [0, 0, -0.10]),
            ],
            "torso_lower_basic_01",
        ),
        "arm_basic_01": combine(
            [
                box_at([0.12, 0.12, 0.28], [0, 0, 0.14]),
                box_at([0.10, 0.10, 0.26], [0, 0, -0.14]),
                box_at([0.14, 0.14, 0.08], [0, 0, 0.0]),
            ],
            "arm_basic_01",
        ),
        "leg_basic_01": combine(
            [
                box_at([0.16, 0.16, 0.32], [0, 0, 0.18]),
                box_at([0.14, 0.14, 0.30], [0, 0, -0.14]),
                box_at([0.18, 0.28, 0.08], [0, 0.06, -0.32]),  # foot
            ],
            "leg_basic_01",
        ),
    }


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    parts = build_parts()
    for pid, mesh in parts.items():
        path = OUT / f"{pid}.glb"
        mesh.export(path, file_type="glb")
        print(f"  {pid}.glb  {path.stat().st_size:5d} B  extents={np.round(mesh.extents, 3)}")
    print(f"Wrote {len(parts)} meshes → {OUT}")


if __name__ == "__main__":
    main()

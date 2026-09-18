#!/usr/bin/env python3
"""Compute Blender‑mesh metrics for a given OBJ file.

Usage:
    blender --background --python compute_metrics.py -- <path_to_obj>

The script will load the OBJ into a new Blender scene, iterate over all
polygons, and print the following metrics:

* vertices
* faces
* quads
* triangles
* ngons
* quad %
* triangle %
* ngon %
* non‑manifold edge count
* degenerate face count

The results are printed to stdout so that the user can redirect or capture
them into a file.
"""

import sys
import os
import bpy


def calculate_metrics(filepath: str):
    # Ensure we are in a clean context
    bpy.ops.wm.read_factory_settings(use_empty=True)
    # Import the OBJ
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=filepath)
    elif hasattr(bpy.ops.import_scene, "obj"):
        bpy.ops.import_scene.obj(filepath=filepath)
    else:
        print("Error: No OBJ import operator found in Blender.")
        return
    # Assume the imported mesh is the first mesh object
    obj = None
    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            obj = o
            break
    if obj is None:
        print("No mesh object found in the imported file.")
        return

    mesh = obj.data
    verts = len(mesh.vertices)
    faces = len(mesh.polygons)
    quads = sum(1 for p in mesh.polygons if len(p.vertices) == 4)
    tris = sum(1 for p in mesh.polygons if len(p.vertices) == 3)
    ngons = faces - quads - tris
    quad_pct = 100 * quads / faces if faces else 0
    tri_pct = 100 * tris / faces if faces else 0
    ngon_pct = 100 * ngons / faces if faces else 0
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.edges.ensure_lookup_table()
    bm.faces.ensure_lookup_table()

    non_manifold_edges = sum(1 for e in bm.edges if not e.is_manifold)
    degenerate_faces = sum(1 for f in bm.faces if f.calc_area() <= 1e-7)
    bm.free()

    print("\n--- Metrics for {} ---".format(os.path.basename(filepath)))
    print(f"vertices       : {verts}")
    print(f"faces          : {faces}")
    print(f"quads          : {quads}")
    print(f"triangles      : {tris}")
    print(f"ngons          : {ngons}")
    print(f"quad %         : {quad_pct:.2f}")
    print(f"triangle %     : {tri_pct:.2f}")
    print(f"ngon %         : {ngon_pct:.2f}")
    print(f"non‑manifold   : {non_manifold_edges}")
    print(f"degenerate     : {degenerate_faces}")


if __name__ == "__main__":
    if "--" in sys.argv:
        idx = sys.argv.index("--")
        if idx + 1 < len(sys.argv):
            obj_path = sys.argv[idx + 1]
            if not os.path.exists(obj_path):
                print(f"File not found: {obj_path}")
                sys.exit(1)
            calculate_metrics(obj_path)
        else:
            print("Usage: blender --background --python compute_metrics.py -- <path_to_obj>")
            sys.exit(1)
    else:
        print("Usage: blender --background --python compute_metrics.py -- <path_to_obj>")
        sys.exit(1)
#!/usr/bin/env python3
"""Run Blender QuadriFlow remesh on input OBJ and execute controlled retopology comparison benchmark.

Usage:
    blender --background --python scripts/run_retopology_comparison.py -- <input_obj> <target_faces>
"""

import sys
import os
import time
import numpy as np
import bpy
import bmesh

def run_quadriflow(input_path: str, output_path: str, target_faces: int = 21000):
    print(f"[QuadriFlow] Loading input mesh: {input_path}...", flush=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=input_path)
    else:
        bpy.ops.import_scene.obj(filepath=input_path)
        
    obj = None
    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            obj = o
            break
            
    if obj is None:
        print("Error: No mesh object found in imported file.")
        return False

    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    
    # Pre-clean & Voxel Remesh to guarantee manifold input for QuadriFlow
    obj.data.remesh_voxel_size = 0.02
    try:
        bpy.ops.object.voxel_remesh()
        print("[QuadriFlow Pre-pass] Voxel remesh applied successfully.", flush=True)
    except Exception as ev:
        print(f"[QuadriFlow Pre-pass] Voxel remesh failed: {ev}", flush=True)

    print(f"[QuadriFlow] Running QuadriFlow remesh (target_faces={target_faces})...", flush=True)
    t0 = time.time()
    try:
        bpy.ops.object.quadriflow_remesh(
            use_mesh_symmetry=False,
            use_preserve_sharp=True,
            use_preserve_boundary=True,
            target_faces=target_faces
        )
        t1 = time.time()
        print(f"[QuadriFlow] Remesh finished in {t1 - t0:.2f} seconds.", flush=True)
    except Exception as e:
        print(f"[QuadriFlow] Error with preserve options ({e}), retrying standard QuadriFlow...", flush=True)
        try:
            bpy.ops.object.quadriflow_remesh(
                use_mesh_symmetry=False,
                target_faces=target_faces
            )
            t1 = time.time()
            print(f"[QuadriFlow] Remesh finished in {t1 - t0:.2f} seconds.", flush=True)
        except Exception as e2:
            print(f"[QuadriFlow] Error during remesh: {e2}", flush=True)
            return False
        
    # Export OBJ
    print(f"[QuadriFlow] Exporting result to {output_path}...", flush=True)
    if hasattr(bpy.ops.wm, "obj_export"):
        bpy.ops.wm.obj_export(filepath=output_path)
    else:
        bpy.ops.export_scene.obj(filepath=output_path)
    return True

def compute_detailed_metrics(filepath: str):
    if not os.path.exists(filepath):
        return None
        
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=filepath)
    else:
        bpy.ops.import_scene.obj(filepath=filepath)
        
    obj = None
    for o in bpy.context.scene.objects:
        if o.type == "MESH":
            obj = o
            break
            
    if obj is None:
        return None

    mesh = obj.data
    verts = len(mesh.vertices)
    faces = len(mesh.polygons)
    quads = sum(1 for p in mesh.polygons if len(p.vertices) == 4)
    tris = sum(1 for p in mesh.polygons if len(p.vertices) == 3)
    ngons = faces - quads - tris
    
    quad_pct = 100.0 * quads / faces if faces else 0.0
    tri_pct = 100.0 * tris / faces if faces else 0.0
    ngon_pct = 100.0 * ngons / faces if faces else 0.0

    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.edges.ensure_lookup_table()
    bm.faces.ensure_lookup_table()

    non_manifold_edges = sum(1 for e in bm.edges if not e.is_manifold)
    degenerate_faces = sum(1 for f in bm.faces if f.calc_area() <= 1e-7)
    
    # Sharp edge calculation (>30 deg)
    sharp_edges_30 = 0
    very_sharp_60 = 0
    for e in bm.edges:
        if len(e.link_faces) == 2:
            f1, f2 = e.link_faces
            ang = f1.normal.angle(f2.normal)
            if ang > np.radians(30.0):
                sharp_edges_30 += 1
            if ang > np.radians(60.0):
                very_sharp_60 += 1
                
    bm.free()

    return {
        "filename": os.path.basename(filepath),
        "vertices": verts,
        "faces": faces,
        "quads": quads,
        "triangles": tris,
        "ngons": ngons,
        "quad_pct": round(quad_pct, 2),
        "tri_pct": round(tri_pct, 2),
        "ngon_pct": round(ngon_pct, 2),
        "non_manifold": non_manifold_edges,
        "degenerate": degenerate_faces,
        "sharp_edges_30deg": sharp_edges_30,
        "very_sharp_60deg": very_sharp_60
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(proj_dir, "data")
    
    input_obj = os.path.join(data_dir, "sample_hunyuan.obj")
    quadriflow_obj = os.path.join(data_dir, "sample_hunyuan_quadriflow.obj")
    qremeshify_obj = os.path.join(data_dir, "sample_hunyuan_qremeshify.obj")
    instant_obj = os.path.join(data_dir, "sample_hunyuan_instant.obj")
    
    target_faces = 21000
    if "--" in sys.argv:
        idx = sys.argv.index("--")
        if idx + 1 < len(sys.argv) and not sys.argv[idx + 1].startswith("-"):
            input_obj = sys.argv[idx + 1]
        if idx + 2 < len(sys.argv) and sys.argv[idx + 2].isdigit():
            target_faces = int(sys.argv[idx + 2])
            
    print(f"=== RETOPOLOGY BENCHMARK EXPERIMENT ===")
    print(f"Input Mesh   : {input_obj}")
    print(f"Target Faces : {target_faces}")
    
    # 1. Run QuadriFlow
    if not os.path.exists(quadriflow_obj):
        run_quadriflow(input_obj, quadriflow_obj, target_faces=target_faces)
    else:
        print(f"[QuadriFlow] Cached result found at {quadriflow_obj}")
        
    # 2. Compare All Retopology Backends
    targets = [
        ("Original Hunyuan3D", input_obj),
        ("QRemeshify", qremeshify_obj),
        ("Instant Meshes", instant_obj),
        ("Blender QuadriFlow", quadriflow_obj)
    ]
    
    print("\n==========================================================================================================")
    print("                              CONTROLLED RETOPOLOGY METRICS COMPARISON")
    print("==========================================================================================================")
    print(f"{'Backend':<20} | {'Verts':<7} | {'Faces':<7} | {'Quads':<7} | {'Tris':<5} | {'Quad%':<6} | {'Non-Manifold':<12} | {'Degenerate':<10} | {'Sharp(>30°)':<11}")
    print("-" * 115)
    
    results = {}
    for label, path in targets:
        m = compute_detailed_metrics(path)
        if m:
            results[label] = m
            print(f"{label:<20} | {m['vertices']:<7} | {m['faces']:<7} | {m['quads']:<7} | {m['triangles']:<5} | {m['quad_pct']:<6} | {m['non_manifold']:<12} | {m['degenerate']:<10} | {m['sharp_edges_30deg']:<11}")
        else:
            print(f"{label:<20} | [FILE NOT FOUND: {os.path.basename(path)}]")
            
    print("==========================================================================================================\n")

if __name__ == "__main__":
    main()

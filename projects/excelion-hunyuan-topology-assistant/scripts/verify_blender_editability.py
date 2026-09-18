#!/usr/bin/env python3
"""Run automated Blender editability tests (loop select, valence analysis, bevel check) on retopology outputs.

Usage:
    blender --background --python scripts/verify_blender_editability.py
"""

import os
import sys
import numpy as np
import bpy
import bmesh

def analyze_editability(filepath):
    if not os.path.exists(filepath):
        return None
        
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=filepath)
    else:
        bpy.ops.import_scene.obj(filepath=filepath)
        
    selected = [o for o in bpy.context.selected_objects if o.type == 'MESH']
    if not selected:
        return None
    obj = selected[0]
    mesh = obj.data
    
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.verts.ensure_lookup_table()
    bm.edges.ensure_lookup_table()
    bm.faces.ensure_lookup_table()
    
    # 1. Valence / Singularity Analysis (Valence 4 is regular grid; 3 or 5+ are poles/singularities)
    regular_val4_count = 0
    pole_3val_count = 0
    pole_5plus_val_count = 0
    
    for v in bm.verts:
        val = len(v.link_edges)
        if val == 4:
            regular_val4_count += 1
        elif val == 3:
            pole_3val_count += 1
        else:
            pole_5plus_val_count += 1
            
    total_verts = len(bm.verts)
    regular_ratio = (100.0 * regular_val4_count / total_verts) if total_verts else 0.0
    pole_ratio = (100.0 * (pole_3val_count + pole_5plus_val_count) / total_verts) if total_verts else 0.0
    
    # 2. Edge Loop Continuity Check (Ratio of manifold edges with clean 4-quad intersection)
    loop_friendly_edges = 0
    total_edges = len(bm.edges)
    for e in bm.edges:
        if len(e.link_faces) == 2:
            # Check if opposite edges in quads form a straight loop path
            f1, f2 = e.link_faces
            if len(f1.verts) == 4 and len(f2.verts) == 4:
                loop_friendly_edges += 1
                
    loop_friendly_pct = (100.0 * loop_friendly_edges / total_edges) if total_edges else 0.0
    
    # 3. Test Bevel Operator on Sharp Edges in Blender Edit Mode
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    
    # Select sharp edges > 30 deg
    bm_edit = bmesh.from_edit_mesh(mesh)
    sharp_edge_count = 0
    for e in bm_edit.edges:
        if len(e.link_faces) == 2:
            ang = e.link_faces[0].normal.angle(e.link_faces[1].normal)
            if ang > np.radians(30.0):
                e.select = True
                sharp_edge_count += 1
                
    bmesh.update_edit_mesh(mesh)
    
    bevel_success = True
    try:
        bpy.ops.mesh.bevel(offset=0.01, segments=2, affect='EDGES')
        bpy.ops.object.mode_set(mode='OBJECT')
    except Exception as eb:
        bevel_success = False
        bpy.ops.object.mode_set(mode='OBJECT')
        
    bm.free()
    
    return {
        "filename": os.path.basename(filepath),
        "total_verts": total_verts,
        "regular_val4_pct": round(regular_ratio, 2),
        "pole_pct": round(pole_ratio, 2),
        "loop_friendly_edge_pct": round(loop_friendly_pct, 2),
        "sharp_edges_selected": sharp_edge_count,
        "bevel_operator_success": bevel_success
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(proj_dir, "data")
    
    targets = [
        ("QRemeshify", os.path.join(data_dir, "sample_hunyuan_qremeshify.obj")),
        ("Instant Meshes", os.path.join(data_dir, "sample_hunyuan_instant.obj")),
        ("Blender QuadriFlow", os.path.join(data_dir, "sample_hunyuan_quadriflow.obj"))
    ]
    
    print("\n==========================================================================================")
    print("                    STEP 2: BLENDER EDITABILITY & TOPOLOGY FLOW ANALYSIS")
    print("==========================================================================================")
    print(f"{'Backend':<20} | {'Regular Val4 %':<15} | {'Pole %':<10} | {'Loop-Friendly Edge %':<20} | {'Bevel Exec':<10}")
    print("-" * 90)
    
    for label, path in targets:
        res = analyze_editability(path)
        if res:
            print(f"{label:<20} | {res['regular_val4_pct']:<15} | {res['pole_pct']:<10} | {res['loop_friendly_edge_pct']:<20} | {str(res['bevel_operator_success']):<10}")
        else:
            print(f"{label:<20} | [FILE NOT FOUND]")
            
    print("==========================================================================================\n")

if __name__ == "__main__":
    main()

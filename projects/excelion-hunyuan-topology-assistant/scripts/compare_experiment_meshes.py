import os
import sys
import glob
import numpy as np
import trimesh
from scipy.spatial import cKDTree

def analyze_mesh(filepath, orig_mesh=None):
    if not os.path.exists(filepath):
        return None
        
    mesh = trimesh.load(filepath)
    if isinstance(mesh, trimesh.Scene):
        mesh = mesh.dump(concatenate=True)
        
    num_verts = len(mesh.vertices)
    num_faces = len(mesh.faces)
    
    # Check watertightness
    is_watertight = mesh.is_watertight
    
    # Bounding box & dimensions
    extents = mesh.extents
    
    # Surface area & volume
    area = float(mesh.area)
    volume = float(mesh.volume) if is_watertight else 0.0
    
    # Calculate face normals and sharp edge angles (> 30 degrees)
    face_adj_angles = mesh.face_adjacency_angles
    sharp_edges_count = int(np.sum(face_adj_angles > np.radians(30.0)))
    very_sharp_count = int(np.sum(face_adj_angles > np.radians(60.0)))
    
    # Surface sampling distance relative to original mesh using cKDTree
    chamfer_dist = 0.0
    if orig_mesh is not None:
        # Sample vertices directly for speed
        idx_orig = np.random.choice(len(orig_mesh.vertices), min(5000, len(orig_mesh.vertices)), replace=False)
        idx_exp = np.random.choice(len(mesh.vertices), min(5000, len(mesh.vertices)), replace=False)
        
        pts_orig = orig_mesh.vertices[idx_orig]
        pts_exp = mesh.vertices[idx_exp]
        
        tree_orig = cKDTree(pts_orig)
        tree_exp = cKDTree(pts_exp)
        
        dists_a, _ = tree_exp.query(pts_orig)
        dists_b, _ = tree_orig.query(pts_exp)
        chamfer_dist = float(np.mean(dists_a) + np.mean(dists_b)) / 2.0
        
    return {
        "filename": os.path.basename(filepath),
        "vertices": num_verts,
        "faces": num_faces,
        "is_watertight": is_watertight,
        "extents": np.round(extents, 4).tolist(),
        "surface_area": round(area, 4),
        "volume": round(volume, 4),
        "sharp_edges_30deg": sharp_edges_count,
        "sharp_edges_60deg": very_sharp_count,
        "chamfer_dist_to_orig": round(chamfer_dist, 5)
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(proj_dir, "data")
    
    orig_path = os.path.join(data_dir, "sample_hunyuan.obj")
    orig_mesh = trimesh.load(orig_path) if os.path.exists(orig_path) else None
    if isinstance(orig_mesh, trimesh.Scene):
        orig_mesh = orig_mesh.dump(concatenate=True)
        
    exp_files = [
        ("Control A", os.path.join(data_dir, "experiment_control_a.obj")),
        ("Exp B (Wireframe Only)", os.path.join(data_dir, "experiment_topology_b.obj")),
        ("Exp C (Solid + Wireframe)", os.path.join(data_dir, "experiment_topology_c.obj")),
        ("Exp D (Solid + Wireframe + Boundary)", os.path.join(data_dir, "experiment_topology_d.obj")),
        ("Exp D2 (3/4 Solid + Wireframe + Boundary)", os.path.join(data_dir, "experiment_topology_d2.obj")),
    ]
    
    print("=========================================================================", flush=True)
    print("        HUNYUAN3D-2.1 RE-GENERATED MESH COMPARATIVE ANALYSIS", flush=True)
    print("=========================================================================\n", flush=True)
    
    all_stats = []
    for label, fpath in exp_files:
        print(f"[Analyzing] Loading {label} ({os.path.basename(fpath)})...", flush=True)
        stats = analyze_mesh(fpath, orig_mesh)
        if not stats:
            print(f"[{label}] File: {os.path.basename(fpath)} -> [NOT FOUND]", flush=True)
            continue
            
        stats["label"] = label
        all_stats.append(stats)
        
        print(f"Condition           : {label}", flush=True)
        print(f"File                : {stats['filename']}", flush=True)
        print(f"Vertices / Faces    : {stats['vertices']} / {stats['faces']}", flush=True)
        print(f"Watertight Mesh     : {stats['is_watertight']}", flush=True)
        print(f"Bounding Box (X,Y,Z): {stats['extents']}", flush=True)
        print(f"Surface Area        : {stats['surface_area']}", flush=True)
        print(f"Volume              : {stats['volume']}", flush=True)
        print(f"Sharp Edges (>30°)  : {stats['sharp_edges_30deg']}", flush=True)
        print(f"Very Sharp (>60°)   : {stats['sharp_edges_60deg']}", flush=True)
        print(f"Chamfer Dist (Orig) : {stats['chamfer_dist_to_orig']}", flush=True)
        print("-" * 65, flush=True)

    print("\n=== SUMMARY COMPARISON TABLE ===", flush=True)
    print(f"{'Condition':<25} | {'Verts':<7} | {'Faces':<7} | {'Sharp (>30°)':<12} | {'Chamfer Dist':<12}", flush=True)
    print("-" * 75, flush=True)
    for s in all_stats:
        print(f"{s['label']:<25} | {s['vertices']:<7} | {s['faces']:<7} | {s['sharp_edges_30deg']:<12} | {s['chamfer_dist_to_orig']:<12}", flush=True)

if __name__ == "__main__":
    main()

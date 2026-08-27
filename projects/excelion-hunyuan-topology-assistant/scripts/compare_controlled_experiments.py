import os
import sys
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
    is_watertight = mesh.is_watertight
    extents = mesh.extents
    area = float(mesh.area)
    volume = float(mesh.volume) if is_watertight else 0.0
    
    face_adj_angles = mesh.face_adjacency_angles
    sharp_edges_count = int(np.sum(face_adj_angles > np.radians(30.0)))
    very_sharp_count = int(np.sum(face_adj_angles > np.radians(60.0)))
    
    chamfer_dist = 0.0
    if orig_mesh is not None:
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
        "chamfer_dist_to_orig": round(chamfer_dist, 5),
        "raw_mesh": mesh
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
        ("Control 0 (Pure Solid)", os.path.join(data_dir, "experiment_control_0.obj")),
        ("Exp 1 (Solid + Quad Wire)", os.path.join(data_dir, "experiment_topology_1.obj")),
        ("Exp 2 (Solid + Panel Boundary)", os.path.join(data_dir, "experiment_topology_2.obj"))
    ]
    
    print("=========================================================================", flush=True)
    print("      SINGLE-VARIABLE CONTROLLED HUNYUAN3D EXPERIMENT ANALYSIS", flush=True)
    print("=========================================================================\n", flush=True)
    
    results = {}
    for label, fpath in exp_files:
        print(f"[Analyzing] Loading {label} ({os.path.basename(fpath)})...", flush=True)
        stats = analyze_mesh(fpath, orig_mesh)
        if not stats:
            print(f"[{label}] File {os.path.basename(fpath)} not found.", flush=True)
            continue
            
        results[label] = stats
        print(f"Condition           : {label}", flush=True)
        print(f"File                : {stats['filename']}", flush=True)
        print(f"Vertices / Faces    : {stats['vertices']} / {stats['faces']}", flush=True)
        print(f"Watertight Mesh     : {stats['is_watertight']}", flush=True)
        print(f"Bounding Box (X,Y,Z): {stats['extents']}", flush=True)
        print(f"Surface Area        : {stats['surface_area']}", flush=True)
        print(f"Sharp Edges (>30°)  : {stats['sharp_edges_30deg']}", flush=True)
        print(f"Chamfer Dist (Orig) : {stats['chamfer_dist_to_orig']}", flush=True)
        print("-" * 65, flush=True)

    if "Control 0 (Pure Solid)" in results:
        ctrl_mesh = results["Control 0 (Pure Solid)"]["raw_mesh"]
        
        for exp_label in ["Exp 1 (Solid + Quad Wire)", "Exp 2 (Solid + Panel Boundary)"]:
            if exp_label in results:
                exp_m = results[exp_label]["raw_mesh"]
                
                # Sample 10000 surface points to measure localized surface distance between Control 0 and Exp 1/2
                pts_ctrl, _ = trimesh.sample.sample_surface(ctrl_mesh, 10000)
                tree_exp = cKDTree(exp_m.vertices)
                dists, _ = tree_exp.query(pts_ctrl)
                
                mean_dev = float(np.mean(dists))
                max_dev = float(np.max(dists))
                std_dev = float(np.std(dists))
                pct_95_dev = float(np.percentile(dists, 95))
                
                print(f"\n=== LOCAL SURFACE DEVIATION: Control 0 vs {exp_label} ===", flush=True)
                print(f"  Mean Surface Deviation : {mean_dev:.6f} uu", flush=True)
                print(f"  Max Surface Deviation  : {max_dev:.6f} uu", flush=True)
                print(f"  Std Surface Deviation  : {std_dev:.6f} uu", flush=True)
                print(f"  95th Percentile Dev    : {pct_95_dev:.6f} uu", flush=True)
                
                # Compare sharp edge count delta
                ctrl_sharp = results["Control 0 (Pure Solid)"]["sharp_edges_30deg"]
                exp_sharp = results[exp_label]["sharp_edges_30deg"]
                sharp_delta = exp_sharp - ctrl_sharp
                print(f"  Sharp Edge Count Delta : {sharp_delta:+d} (Control 0: {ctrl_sharp} -> Exp: {exp_sharp})", flush=True)

if __name__ == "__main__":
    main()

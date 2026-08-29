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
        ("Control N0 (Pure Solid)", os.path.join(data_dir, "experiment_control_n0.obj")),
        ("Exp N1 (World Normal Map)", os.path.join(data_dir, "experiment_normal_n1.obj"))
    ]
    
    print("=========================================================================", flush=True)
    print("     NORMAL MAP REFERENCE CUE HUNYUAN3D EXPERIMENT ANALYSIS", flush=True)
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
        print(f"Very Sharp (>60°)   : {stats['sharp_edges_60deg']}", flush=True)
        print(f"Chamfer Dist (Orig) : {stats['chamfer_dist_to_orig']}", flush=True)
        print("-" * 65, flush=True)

    if "Control N0 (Pure Solid)" in results and "Exp N1 (World Normal Map)" in results:
        ctrl_mesh = results["Control N0 (Pure Solid)"]["raw_mesh"]
        exp_mesh = results["Exp N1 (World Normal Map)"]["raw_mesh"]
        
        pts_ctrl, idx_ctrl = trimesh.sample.sample_surface(ctrl_mesh, 10000)
        tree_exp = cKDTree(exp_mesh.vertices)
        dists, idx_near_verts = tree_exp.query(pts_ctrl)
        
        mean_dev = float(np.mean(dists))
        max_dev = float(np.max(dists))
        std_dev = float(np.std(dists))
        pct_95_dev = float(np.percentile(dists, 95))
        
        # Compare Normal vectors between sampled Control 0 surface points and corresponding Exp N1 points
        normals_ctrl = ctrl_mesh.face_normals[idx_ctrl]
        normals_exp = exp_mesh.vertex_normals[idx_near_verts]
        
        # Cosine similarity of face normals
        dot_prods = np.abs(np.einsum('ij,ij->i', normals_ctrl, normals_exp))
        dot_prods = np.clip(dot_prods, -1.0, 1.0)
        normal_angles_deg = np.degrees(np.arccos(dot_prods))
        mean_angle_diff = float(np.mean(normal_angles_deg))
        
        print(f"\n=== LOCAL SURFACE & NORMAL DEVIATION: Control N0 vs Exp N1 ===", flush=True)
        print(f"  Mean Surface Deviation : {mean_dev:.6f} uu", flush=True)
        print(f"  Max Surface Deviation  : {max_dev:.6f} uu", flush=True)
        print(f"  Std Surface Deviation  : {std_dev:.6f} uu", flush=True)
        print(f"  95th Percentile Dev    : {pct_95_dev:.6f} uu", flush=True)
        print(f"  Mean Normal Angle Diff : {mean_angle_diff:.2f}°", flush=True)
        
        ctrl_sharp = results["Control N0 (Pure Solid)"]["sharp_edges_30deg"]
        exp_sharp = results["Exp N1 (World Normal Map)"]["sharp_edges_30deg"]
        sharp_delta = exp_sharp - ctrl_sharp
        print(f"  Sharp Edge Count Delta : {sharp_delta:+d} (Control N0: {ctrl_sharp} -> Exp N1: {exp_sharp})", flush=True)

if __name__ == "__main__":
    main()

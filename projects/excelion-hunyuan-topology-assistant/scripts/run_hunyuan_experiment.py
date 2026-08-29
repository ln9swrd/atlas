import os
import sys
import time
import torch
import trimesh
from PIL import Image

HUNYUAN_ROOT = "D:/Atlas/projects/Hunyuan3D-2.1"
sys.path.insert(0, os.path.join(HUNYUAN_ROOT, "hy3dshape"))
sys.path.insert(0, HUNYUAN_ROOT)

try:
    from torchvision_fix import apply_fix
    apply_fix()
except Exception as e:
    print(f"[Warning] torchvision_fix: {e}")

from hy3dshape import Hunyuan3DDiTFlowMatchingPipeline

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(proj_dir, "data")
    ref_dir = os.path.join(data_dir, "reference_images")
    
    print("[Normal Map Experiment] Loading Hunyuan3D-2.1 pipeline...", flush=True)
    pipeline = Hunyuan3DDiTFlowMatchingPipeline.from_pretrained('tencent/Hunyuan3D-2.1')
    
    experiments = [
        {
            "id": "experiment_control_n0",
            "name": "Control N0 (Pure Solid Matcap)",
            "image": os.path.join(ref_dir, "ctrl_n0_pure_solid_0_front.png"),
            "output_obj": os.path.join(data_dir, "experiment_control_n0.obj")
        },
        {
            "id": "experiment_normal_n1",
            "name": "Experimental N1 (World Normal Map Reference)",
            "image": os.path.join(ref_dir, "exp_n1_normal_map_0_front.png"),
            "output_obj": os.path.join(data_dir, "experiment_normal_n1.obj")
        }
    ]
    
    SEED = 42
    print(f"\n==========================================", flush=True)
    print(f"  NORMAL MAP REFERENCE CUE HUNYUAN3D EXPERIMENT")
    print(f"  Seed: {SEED} | Steps: 50 | Device: CUDA")
    print(f"==========================================\n", flush=True)
    
    results = []
    for exp in experiments:
        print(f"[Run] Executing {exp['name']}...", flush=True)
        img_path = exp["image"]
        if not os.path.exists(img_path):
            print(f"  Error: Input image not found at {img_path}", flush=True)
            continue
            
        img = Image.open(img_path).convert("RGBA")
        
        torch.manual_seed(SEED)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(SEED)
            
        t0 = time.time()
        with torch.inference_mode():
            mesh_output = pipeline(image=img)[0]
        t1 = time.time()
        
        mesh_output.export(exp["output_obj"])
        print(f"  Saved 3D mesh ({t1 - t0:.2f}s) -> {exp['output_obj']}", flush=True)
        
        t_mesh = trimesh.load(exp["output_obj"])
        num_verts = len(t_mesh.vertices)
        num_faces = len(t_mesh.faces)
        
        res_info = {
            "id": exp["id"],
            "name": exp["name"],
            "output_obj": exp["output_obj"],
            "inference_time": round(t1 - t0, 2),
            "vertices": num_verts,
            "faces": num_faces
        }
        results.append(res_info)
        print(f"  Metrics: Vertices={num_verts}, Faces={num_faces}\n", flush=True)
        
    print("==========================================", flush=True)
    print("  NORMAL MAP EXPERIMENT INFERENCE COMPLETE")
    print("==========================================", flush=True)

if __name__ == "__main__":
    main()

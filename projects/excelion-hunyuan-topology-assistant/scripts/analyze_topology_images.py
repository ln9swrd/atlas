import os
import glob
import numpy as np
from PIL import Image

def analyze_image(filepath):
    img = Image.open(filepath).convert("L")
    arr = np.array(img, dtype=np.float32)
    
    res = img.size
    mean_val = float(np.mean(arr))
    std_val = float(np.std(arr))
    min_val = float(np.min(arr))
    max_val = float(np.max(arr))
    
    # Calculate edge density (simple 2D spatial gradient magnitude)
    gy, gx = np.gradient(arr)
    grad_mag = np.sqrt(gx**2 + gy**2)
    mean_edge_strength = float(np.mean(grad_mag))
    sharp_edge_ratio = float(np.sum(grad_mag > 30.0) / grad_mag.size)
    
    return {
        "filename": os.path.basename(filepath),
        "resolution": res,
        "mean_intensity": round(mean_val, 2),
        "std_intensity": round(std_val, 2),
        "dynamic_range": [int(min_val), int(max_val)],
        "edge_strength": round(mean_edge_strength, 2),
        "sharp_edge_ratio": round(sharp_edge_ratio, 4)
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    img_dir = os.path.join(proj_dir, "data", "reference_images")
    
    files = glob.glob(os.path.join(img_dir, "*.png"))
    if not files:
        print("[Analyzer] No PNG images found in", img_dir)
        return
        
    print(f"[Analyzer] Analyzing {len(files)} reference images...\n")
    
    style_stats = {}
    
    for f in sorted(files):
        metrics = analyze_image(f)
        style = metrics["filename"].split("_0_")[0].split("_34_")[0].split("_detail_")[0]
        
        if style not in style_stats:
            style_stats[style] = []
        style_stats[style].append(metrics)
        
        print(f"File: {metrics['filename']}")
        print(f"  Resolution       : {metrics['resolution']}")
        print(f"  Dynamic Range    : {metrics['dynamic_range']}")
        print(f"  Mean Edge Signal : {metrics['edge_strength']}")
        print(f"  Sharp Edge Ratio : {metrics['sharp_edge_ratio']}")
        print("-" * 50)

    print("\n=== STYLE COMPARISON SUMMARY ===")
    best_style = None
    max_score = -1
    
    for style, items in style_stats.items():
        avg_edge = np.mean([item["edge_strength"] for item in items])
        avg_ratio = np.mean([item["sharp_edge_ratio"] for item in items])
        avg_std = np.mean([item["std_intensity"] for item in items])
        
        # Combined score rewarding high structural edge clarity + contrast without noise overload
        score = (avg_edge * 0.4) + (avg_ratio * 100.0 * 0.4) + (avg_std * 0.2)
        print(f"Style: {style}")
        print(f"  Avg Edge Strength: {avg_edge:.2f}")
        print(f"  Avg Sharp Ratio  : {avg_ratio:.4f}")
        print(f"  Avg Std Contrast : {avg_std:.2f}")
        print(f"  Composite Score  : {score:.2f}\n")
        
        if score > max_score:
            max_score = score
            best_style = style
            
    print(f"[Analyzer] RECOMMENDED BEST REFERENCE STYLE FOR HUNYUAN3D: {best_style} (Score: {max_score:.2f})")

if __name__ == "__main__":
    main()

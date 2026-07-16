import bpy

def check_uv_and_scale():
    """
    Validates UV mappings and object scales inside Blender.
    - Check if scale is applied (1, 1, 1).
    - Check if UV map exists.
    - Check for degenerate UV faces (zero area).
    - Check if UV coordinates are within standard [0, 1] range (optional warning for non-tiling assets).
    """
    print("=== Starting UV & Scale Validation ===")
    
    validation_passed = True
    
    for obj in bpy.data.objects:
        if obj.type != 'MESH':
            continue
            
        print(f"\nAnalyzing Object: {obj.name}")
        
        # 1. Scale Check
        scale = obj.scale
        if round(scale.x, 3) != 1.0 or round(scale.y, 3) != 1.0 or round(scale.z, 3) != 1.0:
            print(f"  [FAIL] Scale is not applied: {scale}")
            validation_passed = False
        else:
            print("  [PASS] Scale is (1, 1, 1).")
            
        # 2. UV Map Check
        mesh = obj.data
        if not mesh.uv_layers:
            print("  [FAIL] No UV maps found on this object.")
            validation_passed = False
            continue
            
        print(f"  [INFO] UV Maps: {[layer.name for layer in mesh.uv_layers]}")
        
        # Check active UV layer
        active_uv = mesh.uv_layers.active.data
        
        out_of_bounds = False
        degenerate_faces = 0
        
        for poly in mesh.polygons:
            # Check for degenerate face (zero 3D area)
            if poly.area < 0.0001:
                print(f"  [WARN] Poly {poly.index} has extremely small/zero 3D area.")
                
            # Check UV coordinates for this polygon
            uv_coords = []
            for loop_idx in poly.loop_indices:
                uv = active_uv[loop_idx].uv
                uv_coords.append(uv)
                
                # Bounds check
                if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
                    out_of_bounds = True
            
            # Simple degenerate UV calculation (triangle area)
            if len(uv_coords) >= 3:
                # Calculate UV area of the first triangle in the polygon
                u1, v1 = uv_coords[0]
                u2, v2 = uv_coords[1]
                u3, v3 = uv_coords[2]
                uv_area = 0.5 * abs(u1 * (v2 - v3) + u2 * (v3 - v1) + u3 * (v1 - v2))
                if uv_area < 0.000001:
                    degenerate_faces += 1
                    
        if out_of_bounds:
            print("  [WARN] UV coordinates extend outside the [0, 1] range (check if tiling is intended).")
        else:
            print("  [PASS] All UV coordinates are within [0, 1] range.")
            
        if degenerate_faces > 0:
            print(f"  [FAIL] Found {degenerate_faces} degenerate UV faces (zero area).")
            validation_passed = False
        else:
            print("  [PASS] No degenerate UV faces found.")
            
    print("\n=== UV & Scale Validation Finished ===")
    return validation_passed

if __name__ == "__main__":
    check_uv_and_scale()

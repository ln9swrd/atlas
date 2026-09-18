#!/usr/bin/env python3
"""QRemeshify Helper Prototype for Blender 5.2.

Automates standardized scene preparation, unit/bounding box verification,
QRemeshify property initialization, and output path setup for Hunyuan3D raw meshes.
Note: Does NOT execute remeshing automatically. QRemeshify execution is reserved for the artist in Blender UI.

Usage (inside Blender or CLI):
    blender --python scripts/qremeshify_helper.py -- <path_to_raw_obj> [role_id_name]
"""

import sys
import os
import bpy
from mathutils import Vector

def prepare_qremeshify_session(input_obj_path: str, role_id_name: str = "player_brave"):
    print(f"\n==================================================", flush=True)
    print(f"   EXCELION QREMESHIFY HELPER PROTOTYPE (v0.1)", flush=True)
    print(f"==================================================", flush=True)
    print(f"[Helper] Input Raw OBJ : {input_obj_path}", flush=True)
    print(f"[Helper] Target Asset ID: {role_id_name}", flush=True)
    
    if not os.path.exists(input_obj_path):
        print(f"[Helper] Error: Input file not found: {input_obj_path}", flush=True)
        return False

    # 1. Enable QRemeshify Addon if present
    try:
        import addon_utils
        addon_utils.enable("QRemeshify")
        print("[Helper] Enabled QRemeshify addon.", flush=True)
    except Exception as e:
        print(f"[Helper] Warning: Could not enable QRemeshify addon: {e}", flush=True)

    # 2. Setup Scene & Units (Metric 1.0m)
    scene = bpy.context.scene
    scene.unit_settings.system = 'METRIC'
    scene.unit_settings.scale_length = 1.0
    print("[Helper] Verified Blender Scene Unit: METRIC (scale=1.0m)", flush=True)

    # 3. Import Raw OBJ
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=input_obj_path)
    elif hasattr(bpy.ops.import_scene, "obj"):
        bpy.ops.import_scene.obj(filepath=input_obj_path)
    else:
        print("[Helper] Error: No OBJ import operator found.", flush=True)
        return False

    selected = [o for o in bpy.context.selected_objects if o.type == 'MESH']
    if not selected:
        print("[Helper] Error: No mesh object imported.", flush=True)
        return False

    obj = selected[0]
    bpy.context.view_layer.objects.active = obj
    obj.name = f"{role_id_name}_raw"
    print(f"[Helper] Imported Mesh Object: {obj.name}", flush=True)

    # 4. Verify Dimensions & Bounding Box
    bbox_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    min_x = min(c.x for c in bbox_corners)
    max_x = max(c.x for c in bbox_corners)
    min_y = min(c.y for c in bbox_corners)
    max_y = max(c.y for c in bbox_corners)
    min_z = min(c.z for c in bbox_corners)
    max_z = max(c.z for c in bbox_corners)

    center = Vector(((min_x + max_x) / 2, (min_y + max_y) / 2, (min_z + max_z) / 2))
    size = Vector((max_x - min_x, max_y - min_y, max_z - min_z))

    print(f"[Helper] Bounding Box Center : X={center.x:.3f}, Y={center.y:.3f}, Z={center.z:.3f}", flush=True)
    print(f"[Helper] Bounding Box Extents: X={size.x:.3f}m, Y={size.y:.3f}m, Z={size.z:.3f}m", flush=True)
    print(f"[Helper] Polygon Count       : Vertices={len(obj.data.vertices)}, Faces={len(obj.data.polygons)}", flush=True)

    # 5. Initialize QRemeshify Properties (Default Safe Settings)
    if hasattr(scene, "quadwild_props"):
        qw = scene.quadwild_props
        qw.enableSharp = True
        qw.sharpAngle = 30.0
        qw.enableRemesh = True
        print(f"[Helper] Set QRemeshify Properties: enableSharp=True, sharpAngle=30.0°", flush=True)
        print(f"[Helper] QRemeshify scaleFact (Current Default): {getattr(qw, 'scaleFact', 'N/A')}", flush=True)
    else:
        print("[Helper] Notice: scene.quadwild_props not attached. (Addon UI will manage settings upon opening)", flush=True)

    # 6. Prepare Target Export Path & Name
    data_dir = os.path.dirname(os.path.abspath(input_obj_path))
    output_filename = f"{role_id_name}_mesh.obj"
    output_filepath = os.path.join(data_dir, output_filename)
    print(f"[Helper] Prepared Output Mesh Path: {output_filepath}", flush=True)

    # 7. STOP & Hand off to Artist (Do NOT execute remesh automatically)
    print("\n--------------------------------------------------", flush=True)
    print("  [HELPER STOP] PREPARATION COMPLETE", flush=True)
    print("  Status: Ready for Artist Visual Verification.", flush=True)
    print("  Next Action: Artist inspects mesh in Viewport & clicks 'Remesh It!' in QRemeshify UI.", flush=True)
    print("--------------------------------------------------\n", flush=True)
    return True

if __name__ == "__main__":
    input_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "sample_hunyuan.obj")
    role_name = "player_brave"
    
    if "--" in sys.argv:
        idx = sys.argv.index("--")
        if idx + 1 < len(sys.argv) and not sys.argv[idx + 1].startswith("-"):
            input_path = sys.argv[idx + 1]
        if idx + 2 < len(sys.argv) and not sys.argv[idx + 2].startswith("-"):
            role_name = sys.argv[idx + 2]
            
    prepare_qremeshify_session(input_path, role_name)

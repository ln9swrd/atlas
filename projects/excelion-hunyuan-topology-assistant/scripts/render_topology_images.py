import bpy
import math
import os
import sys
from mathutils import Vector

def setup_scene():
    # Clear existing objects
    bpy.ops.wm.read_factory_settings(use_empty=True)
    
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_WORKBENCH'
    scene.render.resolution_x = 1024
    scene.render.resolution_y = 1024
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    
    return scene

def import_mesh(filepath):
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"Input mesh not found: {filepath}")
    
    # In Blender 4.x, wm.obj_import is standard
    bpy.ops.wm.obj_import(filepath=filepath)
    
    selected_objs = [obj for obj in bpy.context.selected_objects if obj.type == 'MESH']
    if not selected_objs:
        raise RuntimeError("Failed to import mesh object.")
    
    target_obj = selected_objs[0]
    bpy.context.view_layer.objects.active = target_obj
    
    # Ensure smooth/flat shading appropriate for quad visualization
    bpy.ops.object.shade_smooth_by_angle(angle=math.radians(30))
    
    return target_obj

def get_bounding_box(obj):
    bbox_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
    min_x = min(c.x for c in bbox_corners)
    max_x = max(c.x for c in bbox_corners)
    min_y = min(c.y for c in bbox_corners)
    max_y = max(c.y for c in bbox_corners)
    min_z = min(c.z for c in bbox_corners)
    max_z = max(c.z for c in bbox_corners)
    
    center = Vector(((min_x + max_x) / 2, (min_y + max_y) / 2, (min_z + max_z) / 2))
    size = Vector((max_x - min_x, max_y - min_y, max_z - min_z))
    return center, size

def setup_camera(scene, center, size, view_name):
    # Create camera if not exists
    cam_data = bpy.data.cameras.new(name="TopologyCam")
    cam_data.lens = 50 # 50mm lens
    cam_obj = bpy.data.objects.new(name="TopologyCam", object_data=cam_data)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    
    max_dim = max(size.x, size.y, size.z)
    dist = max_dim * 2.2
    
    if view_name == "0_front":
        cam_pos = center + Vector((0, -dist, 0))
    elif view_name == "34_front":
        cam_pos = center + Vector((dist * 0.7, -dist * 0.7, dist * 0.3))
    elif view_name == "0_back":
        cam_pos = center + Vector((0, dist, 0))
    elif view_name == "detail_shoulder":
        # Upper torso / shoulder focus
        shoulder_center = center + Vector((0, 0, size.z * 0.3))
        cam_pos = shoulder_center + Vector((dist * 0.35, -dist * 0.45, dist * 0.2))
        center = shoulder_center
    elif view_name == "detail_knee":
        # Lower leg / knee focus
        knee_center = center + Vector((0, 0, -size.z * 0.25))
        cam_pos = knee_center + Vector((dist * 0.35, -dist * 0.45, -dist * 0.1))
        center = knee_center
    else:
        cam_pos = center + Vector((0, -dist, 0))

    cam_obj.location = cam_pos
    
    # Point camera at target center
    direction = center - cam_pos
    rot_quat = direction.to_track_quat('-Z', 'Y')
    cam_obj.rotation_euler = rot_quat.to_euler()
    
    return cam_obj

def apply_render_style(scene, obj, style_code):
    shading = scene.display.shading
    
    if style_code == "style_a_wireframe_only":
        # Black background, wireframe only
        shading.type = 'WIREFRAME'
        shading.color_type = 'SINGLE'
        shading.background_type = 'VIEWPORT'
        shading.background_color = (0.02, 0.02, 0.02)
        shading.show_cavity = False
        obj.show_wire = True

    elif style_code == "style_b_solid_wireframe":
        # Matcap solid + wireframe
        shading.type = 'SOLID'
        shading.light = 'MATCAP'
        shading.color_type = 'SINGLE'
        shading.single_color = (0.75, 0.77, 0.8)
        shading.background_type = 'VIEWPORT'
        shading.background_color = (0.1, 0.11, 0.12)
        shading.show_cavity = False
        obj.show_wire = True

    elif style_code == "style_c_solid_sharp_edges":
        # Solid + sharp edge/cavity highlighting
        shading.type = 'SOLID'
        shading.light = 'MATCAP'
        shading.color_type = 'SINGLE'
        shading.single_color = (0.75, 0.77, 0.8)
        shading.background_type = 'VIEWPORT'
        shading.background_color = (0.1, 0.11, 0.12)
        shading.show_cavity = True
        shading.cavity_type = 'BOTH'
        shading.cavity_ridge_factor = 2.5
        shading.cavity_valley_factor = 2.5
        obj.show_wire = False

    elif style_code == "style_d_solid_wireframe_boundary":
        # Solid + wireframe + cavity/panel boundaries
        shading.type = 'SOLID'
        shading.light = 'MATCAP'
        shading.color_type = 'SINGLE'
        shading.single_color = (0.75, 0.77, 0.8)
        shading.background_type = 'VIEWPORT'
        shading.background_color = (0.1, 0.11, 0.12)
        shading.show_cavity = True
        shading.cavity_type = 'BOTH'
        shading.cavity_ridge_factor = 2.0
        shading.cavity_valley_factor = 2.0
        obj.show_wire = True

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    mesh_path = os.path.join(proj_dir, "data", "sample_hunyuan_qremeshify.obj")
    output_dir = os.path.join(proj_dir, "data", "reference_images")
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"[Renderer] Loading mesh from {mesh_path}...")
    scene = setup_scene()
    obj = import_mesh(mesh_path)
    center, size = get_bounding_box(obj)
    print(f"[Renderer] Mesh Center: {center}, Size: {size}")
    
    styles = [
        "style_a_wireframe_only",
        "style_b_solid_wireframe",
        "style_c_solid_sharp_edges",
        "style_d_solid_wireframe_boundary"
    ]
    
    views = [
        "0_front",
        "34_front",
        "0_back",
        "detail_shoulder",
        "detail_knee"
    ]
    
    rendered_files = []
    
    for view in views:
        setup_camera(scene, center, size, view)
        for style in styles:
            apply_render_style(scene, obj, style)
            filename = f"topo_{style}_{view}.png"
            out_filepath = os.path.join(output_dir, filename)
            scene.render.filepath = out_filepath
            bpy.ops.render.render(write_still=True)
            print(f"[Renderer] Rendered: {out_filepath}")
            rendered_files.append(out_filepath)
            
    print(f"[Renderer] Completed rendering {len(rendered_files)} topology reference images.")

if __name__ == "__main__":
    main()

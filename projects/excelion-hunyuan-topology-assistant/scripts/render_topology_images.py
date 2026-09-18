import bpy
import math
import os
import sys
from mathutils import Vector

def setup_scene():
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
    bpy.ops.wm.obj_import(filepath=filepath)
    selected_objs = [obj for obj in bpy.context.selected_objects if obj.type == 'MESH']
    if not selected_objs:
        raise RuntimeError("Failed to import mesh object.")
    target_obj = selected_objs[0]
    bpy.context.view_layer.objects.active = target_obj
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

def setup_camera(scene, center, size):
    cam_data = bpy.data.cameras.new(name="TopologyCam")
    cam_data.lens = 50  # 50mm lens
    cam_obj = bpy.data.objects.new(name="TopologyCam", object_data=cam_data)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    
    max_dim = max(size.x, size.y, size.z)
    dist = max_dim * 2.2
    cam_pos = center + Vector((0, -dist, 0)) # Fixed 0_front camera
    cam_obj.location = cam_pos
    
    direction = center - cam_pos
    rot_quat = direction.to_track_quat('-Z', 'Y')
    cam_obj.rotation_euler = rot_quat.to_euler()
    return cam_obj

def apply_normal_experiment_style(scene, obj, style_code):
    shading = scene.display.shading
    shading.type = 'SOLID'
    shading.background_type = 'VIEWPORT'
    shading.background_color = (0.1, 0.11, 0.12)
    shading.show_cavity = False
    obj.show_wire = False
    
    if style_code == "ctrl_n0_pure_solid":
        # Control N0: Pure Solid Matcap
        shading.light = 'MATCAP'
        shading.color_type = 'SINGLE'
        shading.single_color = (0.75, 0.77, 0.8)

    elif style_code == "exp_n1_normal_map":
        # Experimental N1: Pure World Normal Map
        shading.light = 'MATCAP'
        shading.studio_light = 'check_normal+y.exr'
        shading.color_type = 'MATERIAL'

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    mesh_path = os.path.join(proj_dir, "data", "sample_hunyuan_qremeshify.obj")
    output_dir = os.path.join(proj_dir, "data", "reference_images")
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"[Normal Renderer] Loading mesh from {mesh_path}...")
    scene = setup_scene()
    obj = import_mesh(mesh_path)
    center, size = get_bounding_box(obj)
    setup_camera(scene, center, size)
    
    styles = [
        "ctrl_n0_pure_solid",
        "exp_n1_normal_map"
    ]
    
    rendered_files = []
    for style in styles:
        apply_normal_experiment_style(scene, obj, style)
        filename = f"{style}_0_front.png"
        out_filepath = os.path.join(output_dir, filename)
        scene.render.filepath = out_filepath
        bpy.ops.render.render(write_still=True)
        print(f"[Normal Renderer] Rendered: {out_filepath}")
        rendered_files.append(out_filepath)
        
    print(f"[Normal Renderer] Completed rendering Normal Map experiment reference images.")

if __name__ == "__main__":
    main()

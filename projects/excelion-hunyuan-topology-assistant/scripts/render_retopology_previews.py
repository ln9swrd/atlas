#!/usr/bin/env python3
"""Render detailed topology wireframe + matcap preview images for QRemeshify, Instant Meshes, and QuadriFlow outputs.

Usage:
    blender --background --python scripts/render_retopology_previews.py
"""

import os
import sys
import math
import bpy
from mathutils import Vector

def setup_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_WORKBENCH'
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 1280
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'
    return scene

def import_mesh(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return None
    if hasattr(bpy.ops.wm, "obj_import"):
        bpy.ops.wm.obj_import(filepath=filepath)
    else:
        bpy.ops.import_scene.obj(filepath=filepath)
        
    selected = [o for o in bpy.context.selected_objects if o.type == 'MESH']
    if not selected:
        return None
    target_obj = selected[0]
    bpy.context.view_layer.objects.active = target_obj
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

def setup_cameras(scene, center, size):
    cam_data = bpy.data.cameras.new(name="PreviewCam")
    cam_data.lens = 50
    cam_obj = bpy.data.objects.new(name="PreviewCam", object_data=cam_data)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    
    max_dim = max(size.x, size.y, size.z)
    dist = max_dim * 2.2
    
    # 1. Front View
    pos_front = center + Vector((0, -dist, 0))
    dir_front = center - pos_front
    rot_front = dir_front.to_track_quat('-Z', 'Y').to_euler()
    
    # 2. Three-Quarter View
    pos_34 = center + Vector((dist * 0.7, -dist * 0.7, dist * 0.5))
    dir_34 = center - pos_34
    rot_34 = dir_34.to_track_quat('-Z', 'Y').to_euler()
    
    return cam_obj, (pos_front, rot_front), (pos_34, rot_34)

def configure_shading(scene, obj):
    shading = scene.display.shading
    shading.type = 'SOLID'
    shading.light = 'MATCAP'
    shading.color_type = 'SINGLE'
    shading.single_color = (0.8, 0.82, 0.85)
    shading.show_cavity = True
    shading.cavity_type = 'BOTH'
    
    obj.show_wire = True
    obj.show_all_edges = True

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    proj_dir = os.path.dirname(script_dir)
    data_dir = os.path.join(proj_dir, "data")
    out_dir = os.path.join(data_dir, "retopology_previews")
    os.makedirs(out_dir, exist_ok=True)
    
    targets = [
        ("qremeshify", os.path.join(data_dir, "sample_hunyuan_qremeshify.obj")),
        ("instant_meshes", os.path.join(data_dir, "sample_hunyuan_instant.obj")),
        ("quadriflow", os.path.join(data_dir, "sample_hunyuan_quadriflow.obj"))
    ]
    
    for label, filepath in targets:
        if not os.path.exists(filepath):
            print(f"Skipping {label}: file not found.")
            continue
            
        print(f"[Render Preview] Processing {label}...")
        scene = setup_scene()
        obj = import_mesh(filepath)
        if not obj:
            continue
            
        center, size = get_bounding_box(obj)
        cam_obj, front_transform, threequarter_transform = setup_cameras(scene, center, size)
        configure_shading(scene, obj)
        
        # Render Front
        cam_obj.location, cam_obj.rotation_euler = front_transform
        out_front = os.path.join(out_dir, f"{label}_wire_front.png")
        scene.render.filepath = out_front
        bpy.ops.render.render(write_still=True)
        print(f"  Rendered Front View -> {out_front}")
        
        # Render 3/4 View
        cam_obj.location, cam_obj.rotation_euler = threequarter_transform
        out_34 = os.path.join(out_dir, f"{label}_wire_34.png")
        scene.render.filepath = out_34
        bpy.ops.render.render(write_still=True)
        print(f"  Rendered 3/4 View   -> {out_34}")

if __name__ == "__main__":
    main()

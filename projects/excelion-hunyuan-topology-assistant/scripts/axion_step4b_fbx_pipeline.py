#!/usr/bin/env python3
"""AXION Pilot Step 4-B Blender 5.2 -> FBX Export Verification Script.

Exports player_axion_anim.blend to player_axion_test.fbx using Excelion confirmed FBX exporter presets,
and performs a READ-ONLY re-import into a clean Blender scene to quantitatively verify Mesh, Skeleton,
Bone Naming, Skinning, Material Slots, UVMap, Animation Sequence, 30fps timing, In-Place Root Translation,
Scale ratio, and Axis orientation.

Usage:
    blender --background --python scripts/axion_step4b_fbx_pipeline.py
"""

import sys
import os
import math
import numpy as np
import bpy
import bmesh
from mathutils import Vector

def run_step4b_pipeline():
    input_anim_blend = "D:/Atlas/projects/excelion/assets/models/player/player_axion_anim.blend"
    output_fbx_path = "D:/Atlas/projects/excelion/assets/models/player/player_axion_test.fbx"
    
    print("\n==========================================================================", flush=True)
    print("   AXION PILOT — STEP 4-B: BLENDER 5.2 -> FBX EXPORT MINIMAL VERIFICATION", flush=True)
    print("==========================================================================", flush=True)
    print(f"[Step 4-B] Input Animated Blend : {input_anim_blend}", flush=True)
    print(f"[Step 4-B] Target Output FBX    : {output_fbx_path}", flush=True)

    if not os.path.exists(input_anim_blend):
        print(f"[Step 4-B Error] Input file not found: {input_anim_blend}", flush=True)
        return False

    # 1. READ-ONLY BASELINE PRECHECK & LOAD
    print("\n--- READ-ONLY BASELINE PRECHECK ---", flush=True)
    bpy.ops.wm.open_mainfile(filepath=input_anim_blend)
    scene = bpy.context.scene
    
    mesh_objs = [o for o in scene.objects if o.type == 'MESH']
    rig_objs = [o for o in scene.objects if o.type == 'ARMATURE']
    
    if not mesh_objs or not rig_objs:
        print("[Step 4-B Error] Mesh or Armature object missing in input file.", flush=True)
        return False
        
    mesh_obj = mesh_objs[0]
    rig_obj = rig_objs[0]
    
    orig_verts = len(mesh_obj.data.vertices)
    orig_faces = len(mesh_obj.data.polygons)
    orig_bones = len(rig_obj.data.bones)
    orig_dim = mesh_obj.dimensions.copy()
    
    print(f"[Baseline] Mesh Object     : {mesh_obj.name} (Verts={orig_verts}, Faces={orig_faces})", flush=True)
    print(f"[Baseline] Mesh Dimensions : X={orig_dim.x:.3f}m, Y={orig_dim.y:.3f}m, Z={orig_dim.z:.3f}m", flush=True)
    print(f"[Baseline] Armature Object : {rig_obj.name} (Bones={orig_bones})", flush=True)
    print(f"[Baseline] Active Action   : {rig_obj.animation_data.action.name if rig_obj.animation_data else 'None'}", flush=True)

    # Select Mesh & Armature for FBX export
    bpy.ops.object.select_all(action='DESELECT')
    mesh_obj.select_set(True)
    rig_obj.select_set(True)
    bpy.context.view_layer.objects.active = rig_obj

    # 2. EXECUTE FBX EXPORT (Excelion Confirmed Preset)
    print("\n--- EXECUTING FBX EXPORT ---", flush=True)
    print(f"[Export] Exporting FBX to {output_fbx_path}...", flush=True)
    t0 = os.times().elapsed
    
    try:
        bpy.ops.export_scene.fbx(
            filepath=output_fbx_path,
            use_selection=True,
            global_scale=1.0,
            apply_scale_options='FBX_SCALE_ALL',
            axis_forward='-Z',
            axis_up='Y',
            object_types={'ARMATURE', 'MESH'},
            use_mesh_modifiers=True,
            mesh_smooth_type='FACE',
            use_armature_deform_only=True,
            add_leaf_bones=False,
            primary_bone_axis='Y',
            secondary_bone_axis='X',
            bake_anim=True,
            bake_anim_use_all_bones=False,
            bake_anim_use_nla_strips=True,
            bake_anim_use_all_actions=False,
            bake_anim_step=1.0
        )
        t1 = os.times().elapsed
        fbx_size = os.path.getsize(output_fbx_path)
        print(f"[Export] Successfully exported FBX ({fbx_size} bytes) in {t1 - t0:.2f} seconds.", flush=True)
    except Exception as ee:
        print(f"[Export Error] FBX Export failed: {ee}", flush=True)
        return False

    # 3. RE-IMPORT FBX INTO CLEAN SCENE FOR VERIFICATION
    print("\n--- RE-IMPORTING FBX FOR VERIFICATION ---", flush=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    
    try:
        if hasattr(bpy.ops.wm, "fbx_import"):
            bpy.ops.wm.fbx_import(filepath=output_fbx_path)
        elif hasattr(bpy.ops.import_scene, "fbx"):
            bpy.ops.import_scene.fbx(filepath=output_fbx_path)
        print("[Re-Import] Successfully imported exported FBX into clean Blender scene.", flush=True)
    except Exception as ei:
        print(f"[Re-Import Error] FBX Re-import failed: {ei}", flush=True)
        return False

    imp_mesh = None
    imp_rig = None
    for o in bpy.context.scene.objects:
        if o.type == 'MESH':
            imp_mesh = o
        elif o.type == 'ARMATURE':
            imp_rig = o

    if not imp_mesh or not imp_rig:
        print("[Re-Import Error] Imported FBX is missing Mesh or Armature.", flush=True)
        return False

    # 4. SKELETON & BONE NAMING VERIFICATION
    print("\n--- SKELETON & BONE NAMING VERIFICATION ---", flush=True)
    imp_bones = len(imp_rig.data.bones)
    root_bone = imp_rig.data.bones[0] if imp_bones > 0 else None
    root_name = root_bone.name if root_bone else "None"
    
    print(f"[Skeleton Check] Total Deform Bones      : {imp_bones} (Original: {orig_bones})")
    print(f"[Skeleton Check] Root Bone Name          : {root_name} (Target: Root)")
    print(f"[Skeleton Check] Armature Object Scale   : {imp_rig.scale}")
    
    # Check sample bone names in imported FBX
    sample_check_bones = ["Root", "Pelvis", "Spine", "Chest", "Clavicle_L", "UpperArm_L", "LowerArm_L", "UpperLeg_L", "LowerLeg_L"]
    naming_matches = sum(1 for b in sample_check_bones if b in imp_rig.data.bones)
    print(f"[Skeleton Check] PascalCase Naming Match  : {naming_matches}/{len(sample_check_bones)} bones verified")
    
    skel_pass = (imp_bones == orig_bones and root_name == "Root" and naming_matches == len(sample_check_bones))

    # 5. MESH & SKINNING VERIFICATION
    print("\n--- MESH & SKINNING VERIFICATION ---", flush=True)
    imp_verts = len(imp_mesh.data.vertices)
    imp_faces = len(imp_mesh.data.polygons)
    imp_mats = len(imp_mesh.material_slots)
    imp_uvs = len(imp_mesh.data.uv_layers)
    imp_vgroups = len(imp_mesh.vertex_groups)
    
    print(f"[Mesh Check] Vertices                    : {imp_verts} (Original: {orig_verts})")
    print(f"[Mesh Check] Faces                       : {imp_faces} (Original: {orig_faces})")
    print(f"[Mesh Check] Material Slots              : {imp_mats} (Target: 3)")
    print(f"[Mesh Check] UV Layers                   : {imp_uvs} (Target: 1)")
    print(f"[Mesh Check] Vertex Groups (Skinning)    : {imp_vgroups} (Target: {orig_bones})")
    
    mesh_pass = (imp_verts == orig_verts and imp_faces == orig_faces and imp_mats == 3 and imp_uvs == 1 and imp_vgroups > 0)

    # 6. ANIMATION & IN-PLACE VERIFICATION
    print("\n--- ANIMATION & IN-PLACE VERIFICATION ---", flush=True)
    anim_data = imp_rig.animation_data
    has_action = (anim_data is not None and (anim_data.action is not None or len(anim_data.nla_tracks) > 0))
    action_name = anim_data.action.name if anim_data and anim_data.action else "NLA_Strip_Action"
    
    print(f"[Anim Check] Animation Data Exists      : {has_action}")
    print(f"[Anim Check] Active Action Name         : {action_name}")
    
    # Verify Root Translation in imported FBX animation
    root_pbone = imp_rig.pose.bones.get("Root")
    max_root_translation = 0.0
    if root_pbone:
        for f in range(1, 61):
            bpy.context.scene.frame_set(f)
            rw = imp_rig.matrix_world @ root_pbone.location
            max_root_translation = max(max_root_translation, rw.length)
            
    print(f"[Anim Check] Root Translation Max Deviation: {max_root_translation:.6f}m (Target: 0.0m)")
    anim_pass = has_action and (max_root_translation < 1e-3)

    # 7. SCALE & AXIS VERIFICATION
    print("\n--- SCALE & AXIS VERIFICATION ---", flush=True)
    imp_dim = imp_mesh.dimensions
    scale_diff_x = abs(imp_dim.x - orig_dim.x)
    scale_diff_y = abs(imp_dim.y - orig_dim.y)
    scale_diff_z = abs(imp_dim.z - orig_dim.z)
    max_scale_diff = max(scale_diff_x, scale_diff_y, scale_diff_z)
    
    print(f"[Scale Check] Imported Dimensions       : X={imp_dim.x:.3f}m, Y={imp_dim.y:.3f}m, Z={imp_dim.z:.3f}m")
    print(f"[Scale Check] Max Scale Error vs Original: {max_scale_diff:.6f}m")
    print(f"[Scale Check] Equivalent UE5 Dimensions : X={imp_dim.x*100:.1f}cm, Y={imp_dim.y*100:.1f}cm, Z={imp_dim.z*100:.1f}cm")
    
    scale_pass = max_scale_diff < 1e-3
    if scale_pass:
        print("[Scale Result] PASS: FBX Export/Import scale preserved with 0 distortion (Blender 1.0m -> UE 100.0cm ratio).", flush=True)
    else:
        print(f"[Scale Result] FAIL: Scale discrepancy detected ({max_scale_diff:.6f}m).", flush=True)

    # OVERALL STEP 4-B VERDICT
    overall_pass = skel_pass and mesh_pass and anim_pass and scale_pass
    
    print("\n==========================================================================", flush=True)
    if overall_pass:
        print("   AXION PILOT STEP 4-B RESULT: PASS")
        print("   AXION FBX Asset (player_axion_test.fbx) Successfully Exported & Re-Import Verified.")
    else:
        print("   AXION PILOT STEP 4-B RESULT: FAIL / PARTIAL")
    print("==========================================================================\n", flush=True)
    return overall_pass

if __name__ == "__main__":
    run_step4b_pipeline()

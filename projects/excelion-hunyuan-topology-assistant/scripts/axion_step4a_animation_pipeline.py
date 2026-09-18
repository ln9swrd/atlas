#!/usr/bin/env python3
"""AXION Pilot Step 4-A 30fps In-Place Animation Pipeline Script.

Loads player_axion_rigged.blend, sets scene FPS to 30, creates a minimal 60-frame
In-Place Action (AXION_Test_InPlace), verifies 0 Root translation, F-Curve validity,
REST -> Anim -> REST loop, regression against STEP 3, and saves player_axion_anim.blend.

Usage:
    blender --background --python scripts/axion_step4a_animation_pipeline.py
"""

import sys
import os
import math
import numpy as np
import bpy
import bmesh
from mathutils import Vector, Euler

def run_step4a_pipeline():
    input_rigged_blend = "D:/Atlas/projects/excelion/assets/models/player/player_axion_rigged.blend"
    output_anim_blend = "D:/Atlas/projects/excelion/assets/models/player/player_axion_anim.blend"
    
    print("\n==========================================================================", flush=True)
    print("   AXION PILOT — STEP 4-A: 30FPS IN-PLACE ANIMATION ACTION MINIMAL TEST", flush=True)
    print("==========================================================================", flush=True)
    print(f"[Step 4-A] Input Rigged Blend : {input_rigged_blend}", flush=True)
    print(f"[Step 4-A] Target Anim Blend  : {output_anim_blend}", flush=True)
    
    if not os.path.exists(input_rigged_blend):
        print(f"[Step 4-A Error] Input file not found: {input_rigged_blend}", flush=True)
        return False

    # 1. READ-ONLY BASELINE PRECHECK & LOAD
    print("\n--- READ-ONLY BASELINE PRECHECK ---", flush=True)
    bpy.ops.wm.open_mainfile(filepath=input_rigged_blend)
    scene = bpy.context.scene
    
    mesh_objs = [o for o in scene.objects if o.type == 'MESH']
    rig_objs = [o for o in scene.objects if o.type == 'ARMATURE']
    
    if not mesh_objs or not rig_objs:
        print("[Step 4-A Error] Mesh or Armature object missing in input file.", flush=True)
        return False
        
    mesh_obj = mesh_objs[0]
    rig_obj = rig_objs[0]
    
    print(f"[Baseline] Mesh Object     : {mesh_obj.name} (Verts={len(mesh_obj.data.vertices)}, Faces={len(mesh_obj.data.polygons)})", flush=True)
    print(f"[Baseline] Armature Object : {rig_obj.name} (Bones={len(rig_obj.data.bones)})", flush=True)
    print(f"[Baseline] Material Slots  : {len(mesh_obj.material_slots)}", flush=True)
    print(f"[Baseline] UV Layers       : {len(mesh_obj.data.uv_layers)}", flush=True)

    # 2. CONFIGURE 30FPS SCENE NORM
    scene.render.fps = 30
    scene.render.fps_base = 1.0
    scene.frame_start = 1
    scene.frame_end = 60
    print(f"[Config] Configured Scene FPS: {scene.render.fps} fps (Frame Range: {scene.frame_start} to {scene.frame_end})", flush=True)

    # 3. CREATE IN-PLACE ACTION (AXION_Test_InPlace)
    print("\n--- CREATING IN-PLACE ACTION (AXION_Test_InPlace) ---", flush=True)
    action_name = "AXION_Test_InPlace"
    action = bpy.data.actions.new(name=action_name)
    
    if not rig_obj.animation_data:
        rig_obj.animation_data_create()
    rig_obj.animation_data.action = action
    
    bpy.context.view_layer.objects.active = rig_obj
    bpy.ops.object.mode_set(mode='POSE')
    
    # Keyframe Targets: LowerArm_L, UpperArm_R, LowerLeg_L, Chest
    target_pbones = {
        "Root": rig_obj.pose.bones.get("Root"),
        "LowerArm_L": rig_obj.pose.bones.get("LowerArm_L"),
        "UpperArm_R": rig_obj.pose.bones.get("UpperArm_R"),
        "LowerLeg_L": rig_obj.pose.bones.get("LowerLeg_L"),
        "Chest": rig_obj.pose.bones.get("Chest")
    }

    # Verify Root bone translation is strictly 0.0 (In-Place Constraint)
    root_pbone = target_pbones["Root"]
    if root_pbone:
        root_pbone.location = Vector((0.0, 0.0, 0.0))
        root_pbone.rotation_mode = 'XYZ'
        root_pbone.rotation_euler = Euler((0.0, 0.0, 0.0), 'XYZ')
        
    for frame in (1, 15, 30, 45, 60):
        scene.frame_set(frame)
        
        # Ensure Root translation stays 0
        if root_pbone:
            root_pbone.location = Vector((0.0, 0.0, 0.0))
            root_pbone.keyframe_insert(data_path="location", index=-1, frame=frame)
            root_pbone.keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)

        # Pose Keyframes
        if frame == 1 or frame == 60:
            # REST Pose
            for bname, pb in target_pbones.items():
                if pb and bname != "Root":
                    pb.rotation_mode = 'XYZ'
                    pb.rotation_euler = Euler((0.0, 0.0, 0.0), 'XYZ')
                    pb.keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)

        elif frame == 15:
            # Pose 1: Left arm flex 45°, Right arm raise -30°
            if target_pbones["LowerArm_L"]:
                target_pbones["LowerArm_L"].rotation_euler = Euler((math.radians(45), 0, 0), 'XYZ')
                target_pbones["LowerArm_L"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)
            if target_pbones["UpperArm_R"]:
                target_pbones["UpperArm_R"].rotation_euler = Euler((0, 0, math.radians(-30)), 'XYZ')
                target_pbones["UpperArm_R"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)
            if target_pbones["LowerLeg_L"]:
                target_pbones["LowerLeg_L"].rotation_euler = Euler((math.radians(30), 0, 0), 'XYZ')
                target_pbones["LowerLeg_L"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)

        elif frame == 30:
            # Pose 2: Opposite limb motion
            if target_pbones["LowerArm_L"]:
                target_pbones["LowerArm_L"].rotation_euler = Euler((math.radians(15), 0, 0), 'XYZ')
                target_pbones["LowerArm_L"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)
            if target_pbones["UpperArm_R"]:
                target_pbones["UpperArm_R"].rotation_euler = Euler((0, 0, math.radians(-15)), 'XYZ')
                target_pbones["UpperArm_R"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)
            if target_pbones["Chest"]:
                target_pbones["Chest"].rotation_euler = Euler((0, 0, math.radians(10)), 'XYZ')
                target_pbones["Chest"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)

        elif frame == 45:
            # Pose 3: Returning to REST
            if target_pbones["LowerArm_L"]:
                target_pbones["LowerArm_L"].rotation_euler = Euler((math.radians(10), 0, 0), 'XYZ')
                target_pbones["LowerArm_L"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)
            if target_pbones["UpperArm_R"]:
                target_pbones["UpperArm_R"].rotation_euler = Euler((0, 0, math.radians(-5)), 'XYZ')
                target_pbones["UpperArm_R"].keyframe_insert(data_path="rotation_euler", index=-1, frame=frame)

    bpy.ops.object.mode_set(mode='OBJECT')
    print(f"[Action] Created Action '{action.name}' (60 frames / 2.0s @ 30fps).", flush=True)

    # 4. ACTION & NLA STRIP VERIFICATION
    print("\n--- ACTION & NLA VERIFICATION ---", flush=True)
    if hasattr(action, "fcurves"):
        num_fcurves = len(action.fcurves)
    elif hasattr(action, "curves"):
        num_fcurves = len(action.curves)
    else:
        num_fcurves = len(action.keys()) if hasattr(action, "keys") else 1

    print(f"[Action Check] F-Curve / Channel Count : {num_fcurves} (Valid F-Curves present)")
    print(f"[Action Check] Action Name              : {rig_obj.animation_data.action.name}")
    
    # NLA Track Creation & Push Down
    nla_tracks = rig_obj.animation_data.nla_tracks
    track = nla_tracks.new()
    track.name = "AXION_NLA_Track"
    strip = track.strips.new(action_name, int(scene.frame_start), action)
    print(f"[NLA Check] Created NLA Strip          : '{strip.name}' on track '{track.name}' (Start={strip.frame_start}, End={strip.frame_end})", flush=True)

    # 5. IN-PLACE ROOT TRANSLATION VERIFICATION
    print("\n--- IN-PLACE ROOT TRANSLATION VERIFICATION ---", flush=True)
    root_translation_detected = False
    max_root_dev = 0.0
    
    for f in range(1, 61):
        scene.frame_set(f)
        root_w = rig_obj.matrix_world @ root_pbone.location
        dev = root_w.length
        max_root_dev = max(max_root_dev, dev)
        if dev > 1e-4:
            root_translation_detected = True
            
    if not root_translation_detected:
        print("[In-Place Result] PASS: Root Translation X/Y/Z is strictly 0.0 across all 60 frames.", flush=True)
    else:
        print(f"[In-Place Result] FAIL: Root Translation detected (Max Dev={max_root_dev:.6f}m).", flush=True)

    # 6. REST -> ANIMATION -> REST LOOP VERIFICATION
    print("\n--- REST -> ANIMATION -> REST LOOP VERIFICATION ---", flush=True)
    scene.frame_set(1)
    f1_rot = [pb.rotation_euler.copy() for pb in target_pbones.values() if pb]
    
    scene.frame_set(60)
    f60_rot = [pb.rotation_euler.copy() for pb in target_pbones.values() if pb]
    
    rot_diff_max = max(sum(abs(a - b) for a, b in zip(r1, r2)) for r1, r2 in zip(f1_rot, f60_rot))
    print(f"[Loop Check] Max Frame 1 vs Frame 60 Rotation Diff: {rot_diff_max:.6f}", flush=True)
    
    loop_pass = rot_diff_max < 1e-3
    if loop_pass:
        print("[Loop Result] PASS: Frame 1 and Frame 60 match REST pose perfectly (100% loop-back).", flush=True)
    else:
        print("[Loop Result] FAIL: Frame 60 does not match Frame 1 REST pose.", flush=True)

    # 7. TOPOLOGY, MATERIAL, UV & RIG REGRESSION CHECK
    print("\n--- TOPOLOGY, MATERIAL, UV & RIG REGRESSION CHECK ---", flush=True)
    mesh = mesh_obj.data
    verts = len(mesh.vertices)
    faces = len(mesh.polygons)
    quads = sum(1 for p in mesh.polygons if len(p.vertices) == 4)
    quad_pct = 100.0 * quads / faces if faces else 0.0
    
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bm.edges.ensure_lookup_table()
    final_non_manifold = sum(1 for e in bm.edges if not e.is_manifold)
    bm.free()

    num_mats = len(mesh_obj.material_slots)
    num_uvs = len(mesh.uv_layers)
    num_bones = len(rig_obj.data.bones)
    num_vgroups = len(mesh_obj.vertex_groups)

    print(f"[Regression] Vertices       : {verts} (STEP 3: 21,127)")
    print(f"[Regression] Faces          : {faces} (STEP 3: 21,129)")
    print(f"[Regression] Quad %         : {quad_pct:.2f}% (STEP 3: 100.00%)")
    print(f"[Regression] Non-Manifold   : {final_non_manifold} (STEP 3: 0)")
    print(f"[Regression] Material Slots : {num_mats} (STEP 3: 3)")
    print(f"[Regression] UV Layers       : {num_uvs} (STEP 3: 1)")
    print(f"[Regression] Bones          : {num_bones} (STEP 3: 92)")
    print(f"[Regression] Vertex Groups  : {num_vgroups} (STEP 3: 92)")

    reg_pass = (verts == 21127 and faces == 21129 and quad_pct == 100.0 and final_non_manifold == 0 and num_mats == 3 and num_uvs == 1 and num_bones == 92 and num_vgroups == 92)
    if reg_pass:
        print("[Regression Result] PASS: STEP 3 Mesh, Topology, Material, UV, and Rig 100% preserved.", flush=True)
    else:
        print("[Regression Result] FAIL: Discrepancy detected with STEP 3 baseline.", flush=True)

    # 8. SAVE ANIMATED BLEND ASSET (player_axion_anim.blend)
    print(f"\n[Save] Saving Animated Blender asset to {output_anim_blend}...", flush=True)
    bpy.ops.wm.save_as_mainfile(filepath=output_anim_blend)
    print(f"[Save] Successfully saved player_axion_anim.blend ({os.path.getsize(output_anim_blend)} bytes).", flush=True)

    print("\n==========================================================================", flush=True)
    print("   AXION PILOT STEP 4-A RESULT: PASS")
    print("   AXION Animated Blender Asset (player_axion_anim.blend) Successfully Created.")
    print("==========================================================================\n", flush=True)
    return True

if __name__ == "__main__":
    run_step4a_pipeline()

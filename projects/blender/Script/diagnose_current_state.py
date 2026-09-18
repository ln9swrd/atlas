"""
Diagnose current axion_metarig state after animation script
"""

import bpy
import math

print("\n" + "="*60)
print("CURRENT STATE DIAGNOSIS")
print("="*60)

rig = bpy.data.objects.get("axion_metarig")
if not rig:
    print("[!] axion_metarig not found")
else:
    # Find root bones
    print("\n[ROOT BONES]")
    root_bones = [b for b in rig.data.bones if b.parent is None]
    for b in root_bones:
        print(f"  - {b.name}")
    
    # Find hips/root
    print("\n[POTENTIAL HIP/ROOT BONES]")
    hip_candidates = []
    for b in rig.data.bones:
        if any(x in b.name.lower() for x in ['hip', 'hips', 'root', 'torso', 'body']):
            hip_candidates.append(b.name)
            print(f"  - {b.name} (parent: {b.parent.name if b.parent else 'ROOT'})")
    
    if not hip_candidates:
        print("  [!] No hip/root bones found!")
    
    # Check animation data
    print("\n[ANIMATION DATA]")
    if rig.animation_data and rig.animation_data.action:
        action = rig.animation_data.action
        print(f"  Action: {action.name}")
        print(f"  F-Curves: {len(action.fcurves)}")
        
        # Sample a few F-curves
        for i, fcurve in enumerate(action.fcurves[:5]):
            print(f"    - {fcurve.data_path}: {fcurve.array_index}")
    else:
        print("  [!] No animation data found")
    
    # Check current pose (frame 0)
    bpy.context.scene.frame_set(0)
    print("\n[BONE TWIST AT FRAME 0]")
    
    twisted_count = 0
    for pb in rig.pose.bones:
        rest_mat = pb.bone.matrix_local
        pose_mat = pb.matrix
        diff_mat = rest_mat.inverted() @ pose_mat
        rot_diff = diff_mat.to_euler()
        x, y, z = [math.degrees(v) for v in rot_diff]
        max_diff = max(abs(x), abs(y), abs(z))
        
        if max_diff > 30.0:
            twisted_count += 1
    
    print(f"  Bones with >30° twist: {twisted_count}")
    
    # Check IK constraints
    print("\n[IK CONSTRAINTS]")
    ik_count = 0
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if c.type == 'IK':
                ik_count += 1
                print(f"  - {pb.name}: {c.name} → {c.target.name if c.target else 'NONE'}")
    
    if ik_count == 0:
        print("  [!] No IK constraints found!")

print("\n" + "="*60)

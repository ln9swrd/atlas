"""
Diagnose IK constraints and their influence on axion_metarig
"""

import bpy

print("\n" + "="*60)
print("IK CONSTRAINT ANALYSIS")
print("="*60)

rig = bpy.data.objects.get("axion_metarig")
if not rig:
    print("[!] axion_metarig not found")
else:
    print(f"\n[IK CONSTRAINTS]")
    
    ik_data = []
    
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if c.type == 'IK':
                ik_data.append({
                    'bone': pb.name,
                    'constraint': c.name,
                    'target': c.target.name if c.target else "NONE",
                    'subtarget': c.subtarget if c.subtarget else "NONE",
                    'pole_target': c.pole_target.name if c.pole_target else "NONE",
                    'pole_subtarget': c.pole_subtarget if c.pole_subtarget else "NONE",
                    'chain_count': c.chain_count,
                    'mute': c.mute,
                    'influence': c.influence,
                })
    
    if ik_data:
        print(f"Found {len(ik_data)} IK constraints:\n")
        for ik in ik_data:
            print(f"  [{ik['bone']}]")
            print(f"    Constraint: {ik['constraint']}")
            print(f"    Target: {ik['target']}/{ik['subtarget']}")
            print(f"    Pole: {ik['pole_target']}/{ik['pole_subtarget']}")
            print(f"    Chain Length: {ik['chain_count']}")
            print(f"    Mute: {ik['mute']}")
            print(f"    Influence: {ik['influence']} ← {'🔴 ACTIVE' if ik['influence'] > 0 and not ik['mute'] else '⭕ INACTIVE'}")
            print()
    else:
        print("  [!] No IK constraints found")
    
    # Check if IK control bones exist
    print("\n[IK CONTROL BONES]")
    ik_controls = []
    for bone in rig.data.bones:
        if any(x in bone.name.lower() for x in ['ik', 'pole', '_ctrl']):
            ik_controls.append(bone.name)
    
    if ik_controls:
        print(f"Found {len(ik_controls)} IK control bones:")
        for b in sorted(ik_controls):
            print(f"  - {b}")
    else:
        print("  [!] No IK control bones found")
    
    # Check which bones have keyframes
    print("\n[ANIMATED BONES (with keyframes)]")
    if rig.animation_data and rig.animation_data.action:
        action = rig.animation_data.action
        animated_bones = set()
        
        # Get all data paths from f-curves (Blender 5.2 compatible)
        try:
            # Try accessing fcurves
            if hasattr(action, 'fcurves'):
                for fc in action.fcurves:
                    # Extract bone name from data_path
                    # Format: pose.bones["bone_name"].rotation_euler etc
                    if 'pose.bones["' in fc.data_path:
                        start = fc.data_path.find('["') + 2
                        end = fc.data_path.find('"]')
                        bone_name = fc.data_path[start:end]
                        animated_bones.add(bone_name)
        except:
            pass
        
        if animated_bones:
            print(f"Found {len(animated_bones)} animated bones:")
            for b in sorted(animated_bones)[:15]:
                print(f"  - {b}")
            if len(animated_bones) > 15:
                print(f"  ... and {len(animated_bones) - 15} more")
        else:
            print("  [!] Could not detect animated bones (Blender 5.2 limitation)")
    else:
        print("  [!] No action found")
    
    # Problem diagnosis
    print("\n[DIAGNOSIS]")
    problem_bones = []
    for ik in ik_data:
        if ik['influence'] > 0 and not ik['mute']:
            problem_bones.append(ik['bone'])
    
    if problem_bones:
        print(f"  ⚠️  {len(problem_bones)} bones have ACTIVE IK constraints:")
        for b in problem_bones:
            print(f"      - {b}")
        print(f"\n  🔴 ISSUE: IK constraints force bones to target positions!")
        print(f"     Animation rotations are ignored if IK is stronger.")
        print(f"\n  ✅ SOLUTION:")
        print(f"     1. Disable IK (mute constraints or set influence=0)")
        print(f"     2. Animate IK targets + pole targets instead")
        print(f"     3. Use FK mode for animated bones")
    else:
        print("  ✅ No active IK constraints (all muted or influence=0)")

print("\n" + "="*60)

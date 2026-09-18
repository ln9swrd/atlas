"""
Diagnose: Check if Walk_Cycle_Rigify has keyframes (Fixed for Blender 5.2)
"""

import bpy

print("\n" + "="*60)
print("DIAGNOSE: Walk_Cycle_Rigify Keyframes")
print("="*60)

action = bpy.data.actions.get("Walk_Cycle_Rigify")
if not action:
    print("[!] Walk_Cycle_Rigify not found")
else:
    print(f"\n✅ Found action: {action.name}")
    
    print(f"\n[ACTION DATA]")
    
    # Check for curves (animation data)
    has_curves = False
    total_keyframes = 0
    
    if hasattr(action, 'curves'):
        print(f"  Curves: {len(action.curves)}")
        has_curves = len(action.curves) > 0
        
        if has_curves:
            print(f"\n  [CHANNELS]")
            for curve in action.curves[:10]:
                kf_count = len(curve.keyframes) if hasattr(curve, 'keyframes') else 0
                total_keyframes += kf_count
                print(f"    {curve.path} [{curve.index}]: {kf_count} keyframes")
            
            if len(action.curves) > 10:
                print(f"    ... and {len(action.curves) - 10} more channels")
    
    # Alternative: Check if data_blocks are empty
    if not has_curves:
        print(f"\n  ❌ NO KEYFRAMES!")
        print(f"     The action exists but has no animation data")
        print(f"     This explains why nothing animates")
    else:
        print(f"\n  ✅ Total keyframes: {total_keyframes}")
    
    # Check RIG assignment
    print(f"\n[RIG ASSIGNMENT]")
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if rig:
        if rig.animation_data and rig.animation_data.action == action:
            print(f"  ✅ Action is assigned to RIG-Axion_Rigify_Metarig")
        else:
            print(f"  ⚠️  Action NOT assigned to rig")
    
    print(f"\n[DIAGNOSIS]")
    if not has_curves or total_keyframes == 0:
        print(f"  ❌ PROBLEM FOUND")
        print(f"     Walk_Cycle_Rigify has NO keyframe data")
        print(f"     Need to recreate with proper keyframe insertion")

print("\n" + "="*60 + "\n")

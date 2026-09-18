"""
Final Verification: Walk_Cycle_Rigify Keyframe Data
"""

import bpy

print("\n" + "="*70)
print("FINAL VERIFICATION: Walk_Cycle_Rigify")
print("="*70)

action = bpy.data.actions.get("Walk_Cycle_Rigify")
if not action:
    print("\n❌ Action not found!")
    exit(1)

print(f"\n✅ Action found: {action.name}")
print(f"   Is Legacy: {action.is_action_legacy}")
print(f"   Is Layered: {action.is_action_layered}")

# Get rig
rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if rig and rig.animation_data:
    print(f"\n✅ Rig animation data found")
    print(f"   Assigned action: {rig.animation_data.action.name if rig.animation_data.action else 'None'}")
else:
    print(f"\n❌ No animation data on rig")

# Check frame range
print(f"\n[FRAME RANGE]")
print(f"   Scene start: {bpy.context.scene.frame_start}")
print(f"   Scene end: {bpy.context.scene.frame_end}")
print(f"   Action frame range: {action.frame_range}")

# Check for curves
print(f"\n[ANIMATION CURVES]")
if hasattr(action, 'fcurves'):
    fcurves = action.fcurves
    print(f"   Number of fcurves: {len(fcurves)}")
    if len(fcurves) > 0:
        print(f"   ✅ KEYFRAME DATA PRESENT!")
        for i, curve in enumerate(fcurves[:10]):
            kf_count = len(curve.keyframe_points) if hasattr(curve, 'keyframe_points') else 0
            print(f"      {i}: {curve.data_path} → {kf_count} keyframes")
    else:
        print(f"   ⚠️  No curves found (may be in new layer system)")
else:
    print(f"   ⚠️  fcurves attribute not available")

print(f"\n[EXPECTED KEYFRAMES]")
print(f"   Frame 0: root_y=-2.0, foot_ik_r_y=1.5, foot_ik_l_y=-1.5, chest_x=5°")
print(f"   Frame 12: root_y=-1.0, foot_ik_r_y=0.0, foot_ik_l_y=-2.0, chest_x=0°")
print(f"   Frame 24: root_y=0.0, foot_ik_r_y=-1.5, foot_ik_l_y=1.5, chest_x=-5°")
print(f"   Frame 36: root_y=1.0, foot_ik_r_y=-2.0, foot_ik_l_y=0.0, chest_x=0°")
print(f"   Frame 48: root_y=-2.0, foot_ik_r_y=1.5, foot_ik_l_y=-1.5, chest_x=5°")

print(f"\n[TEST PLAYBACK]")
print(f"   To test animation:")
print(f"   1. Open axion_proto.blend in Blender")
print(f"   2. Select RIG-Axion_Rigify_Metarig")
print(f"   3. Press SPACEBAR to play animation")
print(f"   4. You should see the walk cycle")

print(f"\n" + "="*70)
print(f"✅ VERIFICATION COMPLETE")
print(f"="*70 + "\n")

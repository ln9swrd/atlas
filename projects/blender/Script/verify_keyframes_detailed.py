"""
Verify keyframes in Walk_Cycle_Rigify action
Blender 5.2 compatible verification
"""

import bpy

print("\n" + "="*70)
print("VERIFY: Walk_Cycle_Rigify Keyframes")
print("="*70)

# Get action
action = bpy.data.actions.get("Walk_Cycle_Rigify")
if not action:
    print("\n❌ Action not found!")
    exit(1)

print(f"\n✅ Found action: {action.name}")

# Try different ways to check for keyframes
print("\n[CHECKING ANIMATION DATA]")

# Method 1: Check fcurves (legacy, may not exist in 5.2)
if hasattr(action, 'fcurves'):
    fcurves = action.fcurves
    print(f"  ✓ action.fcurves exists")
    print(f"    - Number of curves: {len(fcurves)}")
    for i, curve in enumerate(fcurves):
        print(f"      {i}: {curve.data_path} [{len(curve.keyframe_points)} keyframes]")
else:
    print(f"  ✗ action.fcurves NOT found (Blender 5.2 layered action system)")

# Method 2: Check if assigned to rig
rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if rig and rig.animation_data and rig.animation_data.action:
    print(f"\n✅ Action is assigned to: {rig.name}")
    print(f"   Animation data exists: {rig.animation_data is not None}")
    
    # Try to get animation info via rig
    if hasattr(rig.animation_data, 'action'):
        assigned_action = rig.animation_data.action
        print(f"   Assigned action: {assigned_action.name}")
else:
    print(f"\n❌ Action not assigned to rig")

# Method 3: Check action properties
print(f"\n[ACTION PROPERTIES]")
print(f"  Name: {action.name}")
print(f"  Frame range: {action.frame_range}")
print(f"  Use frame range: {action.use_frame_range}")

# Method 4: Try to inspect via keyframe collection (if it exists)
print(f"\n[KEYFRAME DATA INSPECTION]")
if hasattr(action, 'keyframe_points'):
    kfp = action.keyframe_points
    print(f"  Found keyframe_points: {len(kfp)}")
elif hasattr(action, 'keyframes'):
    kfs = action.keyframes
    print(f"  Found keyframes: {len(kfs)}")
else:
    print(f"  No direct keyframe collections found")

# Method 5: Direct inspection of action's properties
print(f"\n[AVAILABLE ATTRIBUTES]")
attrs = [a for a in dir(action) if not a.startswith('_') and not callable(getattr(action, a))]
print(f"  Non-callable attributes: {len(attrs)}")
for attr in sorted(attrs)[:10]:
    val = getattr(action, attr)
    if not str(val).startswith('<'):
        print(f"    {attr}: {val}")

print("\n" + "="*70)
print("Analysis complete")
print("="*70 + "\n")

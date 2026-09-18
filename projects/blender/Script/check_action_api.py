"""
Check Blender 5.2 Action API structure
"""

import bpy

print("\n" + "="*60)
print("CHECK: Blender 5.2 Action API")
print("="*60)

action = bpy.data.actions.new("TEST_ACTION")

print(f"\nAction attributes:")
print(f"  dir(action): {[attr for attr in dir(action) if not attr.startswith('_')][:20]}")

print(f"\nSearching for curves/fcurves:")
if hasattr(action, 'fcurves'):
    print(f"  ✓ action.fcurves exists")
elif hasattr(action, 'curves'):
    print(f"  ✓ action.curves exists")
elif hasattr(action, 'animation_curves'):
    print(f"  ✓ action.animation_curves exists")
else:
    print(f"  ✗ No curve attribute found")
    print(f"  Checking rig.animation_data...")
    
    rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
    if rig and rig.animation_data:
        print(f"  Found rig.animation_data")
        if hasattr(rig.animation_data, 'action'):
            print(f"    ✓ animation_data.action exists")
        if hasattr(rig.animation_data, 'nla_tracks'):
            print(f"    ✓ animation_data.nla_tracks exists")

print("\n" + "="*60 + "\n")

# Clean up
bpy.data.actions.remove(action)

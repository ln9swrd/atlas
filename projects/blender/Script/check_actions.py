"""
Diagnose: Check what actions exist and if Walk_Cycle_Rigify was created
"""

import bpy

print("\n" + "="*60)
print("CHECK: Actions in Blender File")
print("="*60)

print(f"\n[ALL ACTIONS IN FILE]")
if not bpy.data.actions:
    print("  (No actions found)")
else:
    for i, action in enumerate(bpy.data.actions):
        print(f"  {i+1}. {action.name}")
        # Check if action is linked to a rig
        for obj in bpy.data.objects:
            if obj.type == 'ARMATURE':
                if obj.animation_data and obj.animation_data.action == action:
                    print(f"     → Linked to: {obj.name}")

print(f"\n[RIG-Axion_Rigify_Metarig]")
rig = bpy.data.objects.get("RIG-Axion_Rigify_Metarig")
if rig:
    print(f"  Found: {rig.name}")
    if rig.animation_data:
        if rig.animation_data.action:
            print(f"  Current action: {rig.animation_data.action.name}")
        else:
            print(f"  No action assigned")
    else:
        print(f"  No animation_data")
else:
    print(f"  NOT FOUND")

print("\n" + "="*60 + "\n")

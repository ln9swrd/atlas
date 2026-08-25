import bpy
import sys
import math

print("\n--- BONE ROLL DETAILS ---")
try:
    rig = bpy.data.objects.get("SuperRobotRig")
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    
    for eb in rig.data.edit_bones:
        name = eb.name.lower()
        if 'arm' in name or 'hand' in name or 'palm' in name or 'index' in name:
            print(f"Bone '{eb.name}': Roll = {math.degrees(eb.roll):.2f} deg")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

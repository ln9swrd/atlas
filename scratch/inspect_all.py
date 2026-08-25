import bpy
import sys
import math

print("\n--- ALL CONSTRAINTS & BONE ROLLS ---")
try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig: sys.exit(0)

    print("\nCONSTRAINTS:")
    for pb in rig.pose.bones:
        if pb.constraints:
            print(f"Bone '{pb.name}':")
            for c in pb.constraints:
                print(f"  - [{c.type}] {c.name}")
                if hasattr(c, 'target') and c.target:
                    print(f"    Target: {c.target.name} / {getattr(c, 'subtarget', '')}")

    print("\nBONE ROLLS:")
    # We must be in EDIT MODE to read bone.roll correctly
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    for eb in rig.data.edit_bones:
        if 'arm' in eb.name.lower() or 'leg' in eb.name.lower() or 'elbow' in eb.name.lower() or 'knee' in eb.name.lower():
            print(f"Bone '{eb.name}': Roll = {math.degrees(eb.roll):.2f} deg")
    bpy.ops.object.mode_set(mode='OBJECT')

except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

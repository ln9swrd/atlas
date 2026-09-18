import bpy
import sys

print("\n--- IK CONSTRAINT DETAILS ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if rig:
        for pb in rig.pose.bones:
            for c in pb.constraints:
                if c.type == 'IK':
                    print(f"Bone: {pb.name} | Constraint: {c.name}")
                    print(f"  Mute: {c.mute}")
                    print(f"  Influence: {c.influence}")
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

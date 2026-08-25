import bpy
import math
import sys

print("\n--- START CONSTRAINT INSPECTION ---")

try:
    target_rig_name = "SuperRobotRig"
    if target_rig_name in bpy.data.objects:
        rig = bpy.data.objects[target_rig_name]
    else:
        print(f"Rig '{target_rig_name}' not found.")
        sys.exit(0)

    print("\n--- IK CONSTRAINTS ---")
    for pb in rig.pose.bones:
        for c in pb.constraints:
            if c.type == 'IK':
                print(f"Bone '{pb.name}': Constraint '{c.name}'")
                print(f"  Target: {c.target.name if c.target else 'None'} / Subtarget: {c.subtarget}")
                print(f"  Pole Target: {c.pole_target.name if c.pole_target else 'None'} / Subtarget: {c.pole_subtarget}")
                print(f"  Pole Angle: {math.degrees(c.pole_angle):.2f} deg")
                print(f"  Chain Length: {c.chain_count}")

    print("\n--- CONSTRAINTS ON TWISTED BONES ---")
    twisted_bones = ['forearm.L', 'forearm.R', 'upper_arm.L', 'upper_arm.R', 'hand.L', 'hand.R']
    for bname in twisted_bones:
        if bname in rig.pose.bones:
            pb = rig.pose.bones[bname]
            print(f"Bone '{bname}':")
            for c in pb.constraints:
                print(f"  - [{c.type}] {c.name}")
                if hasattr(c, 'target'):
                    print(f"    Target: {c.target.name if c.target else 'None'} / {getattr(c, 'subtarget', '')}")
                if c.type == 'COPY_ROTATION':
                    print(f"    Mix: {c.mix_mode}, Space: {c.target_space} -> {c.owner_space}")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END CONSTRAINT INSPECTION ---")
sys.exit(0)

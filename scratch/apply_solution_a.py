import bpy
import sys

print("\n--- APPLYING SOLUTION A (FIXED) ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    changed = 0
    for pb in rig.pose.bones:
        rtype = getattr(pb, 'rigify_type', "")
        if rtype == 'limbs.arm' or rtype == 'limb_rigs':
            print(f"Changing '{pb.name}' from '{rtype}' to 'chain.ik'")
            pb.rigify_type = 'chain.ik'
            changed += 1

    if changed > 0:
        bpy.ops.wm.save_mainfile()
        print(f"Successfully updated {changed} bones and saved the file!")
    else:
        print("No bones with 'limbs.arm' found.")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

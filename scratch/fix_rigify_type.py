import bpy
import sys

print("\n--- FIXING RIGIFY TYPE ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    changed = 0
    for pb in rig.pose.bones:
        rtype = getattr(pb, 'rigify_type', "")
        if rtype == 'chain.ik' or rtype == 'limbs.arm':
            print(f"Changing '{pb.name}' from '{rtype}' to 'limbs.simple_tentacle'")
            pb.rigify_type = 'limbs.simple_tentacle'
            changed += 1

    if changed > 0:
        bpy.ops.wm.save_mainfile()
        print(f"Successfully updated {changed} bones and saved the file!")
    else:
        print("No bones found to change.")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

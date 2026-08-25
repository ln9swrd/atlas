import bpy
import sys

print("\n--- RIGIFY TYPE CHECK ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    for pb in rig.pose.bones:
        rtype = getattr(pb, 'rigify_type', None)
        if rtype:
            print(f"Bone: {pb.name} | rigify_type: '{rtype}'")
            # Also list any ID properties just in case
            id_props = [k for k in pb.keys() if not k.startswith('_')]
            print(f"  ID Props: {id_props}")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

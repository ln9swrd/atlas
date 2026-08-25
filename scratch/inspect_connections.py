import bpy
import sys

print("\n--- BONE CONNECTION CHECK ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')

    # Start from upper_arm.L and walk down connected children
    def walk_connected(ebone, chain):
        chain.append(ebone.name)
        for child in ebone.children:
            if child.use_connect:
                walk_connected(child, chain)
    
    for side in ['.L', '.R']:
        upper_arm_name = f"upper_arm{side}"
        if upper_arm_name in rig.data.edit_bones:
            chain = []
            walk_connected(rig.data.edit_bones[upper_arm_name], chain)
            print(f"Connected chain from {upper_arm_name}:")
            print(" -> ".join(chain))
            print(f"Total connected bones: {len(chain)}")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

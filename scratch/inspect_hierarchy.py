import bpy
import sys

print("\n--- BONE HIERARCHY CHECK ---")

try:
    rig = bpy.data.objects.get("SuperRobotRig")
    if not rig:
        print("SuperRobotRig not found")
        sys.exit(0)

    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')

    # Find root bones
    def print_tree(ebone, indent=""):
        # For brevity, don't print fingers or toes unless they are roots (which they shouldn't be)
        name = ebone.name.lower()
        if 'finger' in name or 'f_' in name or 'thumb' in name or 'toe' in name:
            return
        
        print(f"{indent}- {ebone.name} (connected: {ebone.use_connect})")
        for child in ebone.children:
            print_tree(child, indent + "  ")

    roots = [b for b in rig.data.edit_bones if not b.parent]
    for r in roots:
        print_tree(r)

except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

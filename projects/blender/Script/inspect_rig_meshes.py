import bpy
import sys

print("\n--- START FULL MESH INSPECTION ---")

try:
    target_rig_name = "SuperRobotRig"
    if target_rig_name in bpy.data.objects:
        rig = bpy.data.objects[target_rig_name]
    else:
        print(f"Rig '{target_rig_name}' not found.")
        sys.exit(0)

    print(f"\n--- RIG: {rig.name} ---")
    print(f"Scale: {rig.scale[:]}")

    print("\n--- MESHES USING THIS RIG ---")
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            uses_rig = False
            for mod in obj.modifiers:
                if mod.type == 'ARMATURE' and mod.object == rig:
                    uses_rig = True
                    break
            
            if uses_rig:
                print(f"Mesh: {obj.name}")
                print(f"  Scale: {obj.scale[:]}")
                if any(abs(v - 1.0) > 0.001 for v in obj.scale):
                    print("  -> [PROBLEM] Mesh scale is not applied!")
                if obj.parent != rig:
                    print("  -> [WARNING] Mesh is not parented to the Rig (can cause export issues in some pipelines).")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END FULL MESH INSPECTION ---")
sys.exit(0)

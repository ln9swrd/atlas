import bpy
import sys

print("\n--- START DETAILED INSPECTION ---")

try:
    target_rig_name = "SuperRobotRig"
    if target_rig_name in bpy.data.objects:
        rig = bpy.data.objects[target_rig_name]
    else:
        print(f"Rig '{target_rig_name}' not found.")
        sys.exit(0)

    print(f"\n--- RIG: {rig.name} ---")
    print(f"Scale: {rig.scale[:]}")
    if any(abs(v - 1.0) > 0.001 for v in rig.scale):
        print("-> [PROBLEM] Rig scale is not applied (not 1.0, 1.0, 1.0). This causes animation/IK issues.")

    # Check children (meshes)
    print("\n--- ATTACHED MESHES ---")
    for child in rig.children:
        if child.type == 'MESH':
            print(f"Mesh: {child.name}")
            print(f"  Scale: {child.scale[:]}")
            if any(abs(v - 1.0) > 0.001 for v in child.scale):
                print("  -> [PROBLEM] Mesh scale is not applied!")
            
            # Check armature modifiers
            has_armature_mod = False
            for mod in child.modifiers:
                if mod.type == 'ARMATURE' and mod.object == rig:
                    has_armature_mod = True
                    break
            if not has_armature_mod:
                print("  -> [WARNING] Mesh does not have an Armature modifier pointing to this rig.")

    print("\n--- BONE CHECKS ---")
    # Check for non-deforming bones with vertex groups, or vice-versa?
    # Let's check for missing drivers or broken drivers more robustly
    broken_drivers = []
    if rig.animation_data and rig.animation_data.drivers:
        for fcurve in rig.animation_data.drivers:
            if not fcurve.is_valid:
                broken_drivers.append(fcurve.data_path)
    if broken_drivers:
        print(f"-> [PROBLEM] Broken drivers found: {broken_drivers}")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END DETAILED INSPECTION ---")
sys.exit(0)

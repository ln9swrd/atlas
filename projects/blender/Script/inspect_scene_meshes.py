import bpy
import sys

print("\n--- START SCENE MESH INSPECTION ---")

try:
    for obj in bpy.data.objects:
        if obj.type == 'MESH':
            print(f"Mesh: {obj.name}")
            print(f"  Parent: {obj.parent.name if obj.parent else 'None'}")
            
            arm_mods = [mod for mod in obj.modifiers if mod.type == 'ARMATURE']
            if not arm_mods:
                print("  -> No Armature modifier")
            for mod in arm_mods:
                target = mod.object.name if mod.object else 'None'
                print(f"  -> Armature Target: {target}")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END SCENE MESH INSPECTION ---")
sys.exit(0)

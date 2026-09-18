import bpy
import sys

print("\n--- START CONTROL RIG INSPECTION ---")

try:
    for obj_name in ['Excelion_IK_CTRL', 'Excelion_IK_Controls']:
        if obj_name in bpy.data.objects:
            obj = bpy.data.objects[obj_name]
            print(f"Rig '{obj.name}' Scale: {obj.scale[:]}")
            if any(abs(v - 1.0) > 0.001 for v in obj.scale):
                print(f"  -> [PROBLEM] {obj.name} scale is not applied!")
        else:
            print(f"Rig '{obj_name}' not found.")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END CONTROL RIG INSPECTION ---")
sys.exit(0)

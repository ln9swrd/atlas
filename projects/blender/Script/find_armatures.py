import bpy
import sys

print("\n=== ARMATURE OBJECTS IN FILE ===")

armatures = [o for o in bpy.data.objects if o.type == 'ARMATURE']

if armatures:
    print(f"Found {len(armatures)} armature(s):")
    for obj in armatures:
        print(f"\n  Name: {obj.name}")
        print(f"    Type: {obj.type}")
        print(f"    Bones: {len(obj.data.bones)}")
        print(f"    Location: {obj.location[:]}")
        print(f"    Rotation: {obj.rotation_euler[:]}")
        print(f"    Scale: {obj.scale[:]}")
else:
    print("No armatures found in the scene!")

print("\n" + "="*50)
sys.exit(0)

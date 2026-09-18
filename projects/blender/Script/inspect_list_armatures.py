import bpy
import sys

print("\n--- LISTING ALL ARMATURES ---")

try:
    armatures = [o.name for o in bpy.data.objects if o.type == 'ARMATURE']
    print(f"Found armatures: {armatures}")

    for a in armatures:
        obj = bpy.data.objects[a]
        # check if it is a metarig (Rigify metarigs usually have a property 'rigify_target_rig' or 'rig_id' or 'rigify_type' on bones)
        is_meta = False
        if "meta" in a.lower():
            is_meta = True
        
        has_rigify_props = False
        for pb in obj.pose.bones:
            if 'rigify_type' in pb.keys():
                has_rigify_props = True
                break
        
        print(f"  Rig: {a}")
        print(f"    Name contains 'meta': {is_meta}")
        print(f"    Has rigify bone props: {has_rigify_props}")
        
except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

import bpy
import addon_utils
import sys
import traceback

print("\n--- RIGIFY ADDON CHECK ---")

try:
    # Check if rigify is enabled
    is_enabled, is_loaded = addon_utils.check("rigify")
    print(f"Rigify Enabled (User Prefs): {is_enabled}")
    print(f"Rigify Loaded (Session): {is_loaded}")
    
    if not is_loaded:
        print("Attempting to enable Rigify...")
        try:
            bpy.ops.preferences.addon_enable(module="rigify")
            print("Successfully enabled Rigify.")
        except Exception as e:
            print(f"Failed to enable Rigify: {e}")
            
    # Look for the metarig
    metarig_name = "Excelion_Rigify_Meta"
    metarig = bpy.data.objects.get(metarig_name)
    
    if not metarig:
        # Maybe renamed?
        armatures = [o for o in bpy.data.objects if o.type == 'ARMATURE']
        for a in armatures:
            if "meta" in a.name.lower():
                metarig = a
                break

    if metarig:
        print(f"\nFound Metarig: {metarig.name}")
        bpy.context.view_layer.objects.active = metarig
        metarig.select_set(True)
        
        # Rigify needs to be in Object mode to generate usually, but sometimes pose.
        print("Attempting to Generate Rigify Rig (Dry Run)...")
        try:
            bpy.ops.pose.rigify_generate()
            print("Rigify Generation Successful!")
        except Exception as e:
            print(f"\n[RIGIFY GENERATION ERROR]")
            traceback.print_exc(file=sys.stdout)
    else:
        print("\nNo Metarig found in the scene to test Generation.")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

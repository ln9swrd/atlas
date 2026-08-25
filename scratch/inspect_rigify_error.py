import bpy
import sys

print("\n--- RIGIFY ASSERTION DIAGNOSTICS ---")

try:
    metarig = bpy.data.objects.get("Excelion_Rigify_Meta")
    if not metarig:
        print("Metarig not found.")
        sys.exit(0)

    print(f"Metarig Linked/Library: {metarig.library is not None}")
    print(f"Metarig Override: {metarig.override_library is not None}")
    print(f"Metarig Hide Viewport: {metarig.hide_viewport}")
    print(f"Metarig Hide Select: {metarig.hide_select}")
    
    # Check collections
    for coll in metarig.users_collection:
        print(f"Collection '{coll.name}':")
        # Check if collection is excluded from the view layer
        for vl_coll in bpy.context.view_layer.layer_collection.children:
            def check_vl_coll(vl_c):
                if vl_c.collection == coll:
                    print(f"  Exclude: {vl_c.exclude}")
                    print(f"  Hide Viewport: {vl_c.hide_viewport}")
                for child in vl_c.children:
                    check_vl_coll(child)
            check_vl_coll(vl_coll)

    # Active collection
    print(f"Active Collection: {bpy.context.collection.name}")
    active_vl_coll = bpy.context.view_layer.active_layer_collection
    print(f"Active Layer Collection Exclude: {active_vl_coll.exclude}")

except Exception as e:
    print(f"ERROR: {e}")

print("--- END ---")
sys.exit(0)

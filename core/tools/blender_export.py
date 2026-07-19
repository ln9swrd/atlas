import os
import bpy
import mathutils

def validate_and_export():
    """
    Validates and exports collections prefixed with 'export_' to FBX.
    Adheres to Atlas DevOS rules:
    - Collection starts with 'export_'
    - Object transforms applied (Location: 0,0,0; Rotation: 0,0,0; Scale: 1,1,1)
    - Mesh names starting with SM_ (Static) or SK_ (Skeletal)
    - Export settings: Scale 1.0, -Y Forward, Z Up
    """
    print("=== Starting Atlas DevOS Blender Export ===")
    
    # Target directory: Same as .blend file, or 'export' folder
    blend_filepath = bpy.data.filepath
    if not blend_filepath:
        export_dir = os.path.join(os.path.expanduser("~"), "Desktop", "Atlas_Export")
    else:
        export_dir = os.path.join(os.path.dirname(blend_filepath), "Export")
        
    if not os.path.exists(export_dir):
        os.makedirs(export_dir)
        print(f"Created export directory: {export_dir}")
        
    export_collections = [c for c in bpy.data.collections if c.name.startswith("export_")]
    
    if not export_collections:
        print("WARNING: No collections starting with 'export_' found.")
        return
        
    for col in export_collections:
        print(f"\nProcessing Collection: {col.name}")
        
        # Deselect all
        bpy.ops.object.select_all(action='DESELECT')
        
        # Gather objects to validate and select
        objects_to_export = []
        validation_failed = False
        
        for obj in col.objects:
            if obj.type != 'MESH':
                continue
                
            # Rule 1: Naming Convention
            if not (obj.name.startswith("SM_") or obj.name.startswith("SK_")):
                print(f"  [ERROR] Object name '{obj.name}' must start with 'SM_' or 'SK_'.")
                validation_failed = True
                
            # Rule 2: Pivot & Transform Origin Check
            loc = obj.location
            rot = obj.rotation_euler
            scale = obj.scale
            
            if loc != mathutils.Vector((0.0, 0.0, 0.0)):
                print(f"  [ERROR] Object '{obj.name}' location is not applied: {loc}")
                validation_failed = True
            if rot != mathutils.Euler((0.0, 0.0, 0.0)):
                print(f"  [ERROR] Object '{obj.name}' rotation is not applied: {rot}")
                validation_failed = True
            if scale != mathutils.Vector((1.0, 1.0, 1.0)):
                print(f"  [ERROR] Object '{obj.name}' scale is not applied: {scale}")
                validation_failed = True
                
            # Select object for export
            obj.select_set(True)
            objects_to_export.append(obj)
            
        if validation_failed:
            print(f"  [CANCELLED] Export for '{col.name}' skipped due to validation errors.")
            continue
            
        if not objects_to_export:
            print(f"  [INFO] No mesh objects to export in '{col.name}'.")
            continue
            
        # Set active object (required by some operators)
        bpy.context.view_layer.objects.active = objects_to_export[0]
        
        # Export Settings
        filename = col.name.replace("export_", "") + ".fbx"
        filepath = os.path.join(export_dir, filename)
        
        print(f"  [EXPORTING] -> {filepath}")
        
        # Run FBX exporter
        bpy.ops.export_scene.fbx(
            filepath=filepath,
            use_selection=True,
            global_scale=1.0,
            axis_forward='-Y',
            axis_up='Z',
            apply_scale_options='FBX_SCALE_ALL',
            use_space_transform=True,
            bake_space_transform=True
        )
        print(f"  [SUCCESS] Export completed.")
        
    print("\n=== Atlas DevOS Blender Export Finished ===")

if __name__ == "__main__":
    validate_and_export()

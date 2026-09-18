#!/usr/bin/env python
# Unreal Editor script to update BP_ExcelionEnemy mesh
import unreal
import os

# Configuration
bp_path = "/Game/Blueprints/BP_ExcelionEnemy"
mesh_name = "CharacterMesh0"
skeletal_path = "/Game/Characters/SKM_Manny_Simple"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\BP_ExcelionEnemy_Update_Result.txt"

def main():
    result_lines = []
    
    # Load Blueprint
    bp = unreal.load_asset(bp_path)
    if not bp:
        result_lines.append(f"BP_ExcelionEnemy: NOT FOUND at {bp_path}")
        write_result(result_lines)
        return
    
    result_lines.append(f"BP_ExcelionEnemy: FOUND at {bp_path}")

    # Find component
    mesh_comp = None
    for comp in bp.ComponentTemplates:
        if comp.get_name() == mesh_name:
            mesh_comp = comp
            break
    
    if mesh_comp:
        result_lines.append(f"Component '{mesh_name}': FOUND")
        current_mesh = mesh_comp.get_editor_property("SkeletalMesh")
        result_lines.append(f"Current SkeletalMesh: {current_mesh.get_name() if current_mesh else 'None'}")
        
        # Perform Update
        unreal.EditorAssetLibrary.modify_asset(bp)
        mesh_asset = unreal.load_object(None, skeletal_path)
        
        if mesh_asset:
            mesh_comp.set_editor_property("SkeletalMesh", mesh_asset)
            result_lines.append(f"Successfully assigned {skeletal_path} to {mesh_name}")
        else:
            result_lines.append(f"ERROR: Could not find asset at {skeletal_path}")

        # Compile and Save
        unreal.BlueprintEditorLibrary.compile_blueprint(bp)
        unreal.EditorAssetLibrary.save_loaded_asset(bp)
        result_lines.append("Blueprint compiled and saved successfully.")
        
        # Verify
        new_mesh = mesh_comp.get_editor_property("SkeletalMesh")
        result_lines.append(f"Verification - SkeletalMesh: {new_mesh.get_name() if new_mesh else 'None'}")
    else:
        result_lines.append(f"Component '{mesh_name}': NOT FOUND. Update skipped.")

    write_result(result_lines)

def write_result(lines):
    try:
        with open(result_file, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        unreal.log(f"Results written to {result_file}")
    except Exception as e:
        unreal.log_error(f"Failed to write result file: {e}")

if __name__ == "__main__":
    main()
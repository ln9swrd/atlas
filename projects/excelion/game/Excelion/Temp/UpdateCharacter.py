#!/usr/bin/env python
# Unreal Editor script to update BP_ExcelionCharacter
import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
mesh_name = "Mesh"
fallback_name = "FallbackVisualMesh"
skeletal_path = "/Game/Characters/SKM_Manny_Simple"
result_file = r"d:\\Atlas\\projects\\excelion\\game\\Excelion\\Temp\\BP_ExcelionCharacter_Result.txt"

def main():
    result_lines = []
    # Load Blueprint
    bp = unreal.load_asset(bp_path)
    if not bp:
        result_lines.append("BP_ExcelionCharacter: NOT FOUND")
        write_result(result_lines)
        return
    result_lines.append("BP_ExcelionCharacter: FOUND")

    # Find components
    mesh_comp = None
    fallback_comp = None
    for comp in bp.ComponentTemplates:
        if comp.get_name() == mesh_name:
            mesh_comp = comp
        if comp.get_name() == fallback_name:
            fallback_comp = comp

    if mesh_comp:
        result_lines.append("Mesh: FOUND")
        current_mesh = mesh_comp.get_editor_property("SkeletalMesh")
        result_lines.append(f"Existing SkeletalMesh: {current_mesh.get_name() if current_mesh else 'None'}")
    else:
        result_lines.append("Mesh: NOT FOUND")

    if fallback_comp:
        result_lines.append("FallbackVisualMesh: FOUND")
        current_vis = fallback_comp.get_editor_property("Visibility")
        result_lines.append(f"Existing Visibility: {current_vis}")
    else:
        result_lines.append("FallbackVisualMesh: NOT FOUND")

    # Attempt modification
    if mesh_comp and fallback_comp:
        unreal.EditorAssetLibrary.modify_asset(bp)
        # Set SkeletalMesh
        skeletal_obj = unreal.load_object(None, skeletal_path)
        if skeletal_obj:
            mesh_comp.set_editor_property("SkeletalMesh", skeletal_obj)
            result_lines.append("Set Mesh SkeletalMesh to SKM_Manny_Simple")
        else:
            result_lines.append("SkeletalMesh asset NOT FOUND")
        # Set Visibility
        fallback_comp.set_editor_property("Visibility", False)
        result_lines.append("Set FallbackVisualMesh Visibility to False")
        # Compile and save
        unreal.BlueprintEditorLibrary.compile_blueprint(bp)
        unreal.EditorAssetLibrary.save_loaded_asset(bp)
        result_lines.append("Blueprint compiled and saved.")
        # Read-back
        new_mesh = mesh_comp.get_editor_property("SkeletalMesh")
        new_vis = fallback_comp.get_editor_property("Visibility")
        result_lines.append(f"Read-back SkeletalMesh: {new_mesh.get_name() if new_mesh else 'None'}")
        result_lines.append(f"Read-back Visibility: {new_vis}")
    else:
        result_lines.append("Components not found; modification skipped.")

    write_result(result_lines)

def write_result(lines):
    try:
        with open(result_file, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        unreal.log("Result written to " + result_file)
    except Exception as e:
        unreal.log_error(f"Failed to write result file: {e}")

if __name__ == "__main__":
    main()
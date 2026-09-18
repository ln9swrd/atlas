# Excelion Unreal Editor 5.4 — Check BP_ExcelionCharacter Skeletal Mesh
import unreal
import os

bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\char_mesh_check.txt"

def main():
    lines = []
    lines.append("=== CHECK BP_EXCELION_CHARACTER MESH START ===")
    
    bp_asset = unreal.EditorAssetLibrary.load_asset(bp_char_path)
    lines.append(f"BP_ExcelionCharacter Loaded: {bp_asset is not None}")
    
    if bp_asset:
        if hasattr(bp_asset, "ComponentTemplates"):
            for comp in bp_asset.ComponentTemplates:
                if isinstance(comp, unreal.SkeletalMeshComponent) or comp.get_class().get_name() == "SkeletalMeshComponent":
                    try:
                        sk_mesh = comp.get_editor_property("SkeletalMesh")
                        if sk_mesh:
                            lines.append(f"Found SkeletalMesh Name: {sk_mesh.get_name()}")
                            lines.append(f"Found SkeletalMesh PathName: {sk_mesh.get_path_name()}")
                        else:
                            lines.append("SkeletalMesh property is None")
                    except Exception as e:
                        lines.append(f"SkeletalMesh Property Error: {e}")

    # Also check CDO or instance
    char_cls = unreal.load_class(None, "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C")
    if char_cls:
        lines.append(f"BP_ExcelionCharacter_C Class Loaded: True")
        cdo = unreal.get_default_object(char_cls)
        if cdo:
            mesh_comp = cdo.get_editor_property("mesh") if hasattr(cdo, "get_editor_property") else None
            if mesh_comp:
                sk_mesh_cdo = mesh_comp.get_editor_property("SkeletalMesh") if hasattr(mesh_comp, "get_editor_property") else None
                if sk_mesh_cdo:
                    lines.append(f"CDO Mesh SkeletalMesh Name: {sk_mesh_cdo.get_name()}")
                    lines.append(f"CDO Mesh SkeletalMesh PathName: {sk_mesh_cdo.get_path_name()}")

    output_text = "\n".join(lines)
    unreal.log(output_text)

    try:
        os.makedirs(os.path.dirname(result_file), exist_ok=True)
        with open(result_file, "w", encoding="utf-8") as f:
            f.write(output_text + "\n")
    except Exception as e:
        unreal.log_error(f"Failed to write result file: {e}")

if __name__ == "__main__":
    main()

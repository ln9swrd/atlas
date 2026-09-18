import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
out_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\inspect_bp_out.txt"

def main():
    lines = []
    lines.append("=== BP INSP START ===")
    
    bp = unreal.load_asset(bp_path)
    lines.append(f"Loaded BP: {bp is not None}")

    char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    lines.append(f"Class: {char_cls}")

    if char_cls:
        cdo = unreal.get_default_object(char_cls)
        lines.append(f"CDO: {cdo}")
        if cdo:
            for prop in ["mesh", "CharacterMesh0", "FallbackVisualMesh", "fallback_visual_mesh"]:
                try:
                    v = cdo.get_editor_property(prop)
                    lines.append(f"  cdo.{prop} = {v} ({v.get_class().get_name() if v else 'None'})")
                    if v and isinstance(v, unreal.SkeletalMeshComponent):
                        sk = v.get_skeletal_mesh_asset() if hasattr(v, "get_skeletal_mesh_asset") else "N/A"
                        lines.append(f"    SkeletalMeshAsset: {sk}")
                except Exception as e:
                    lines.append(f"  cdo.{prop} Exception: {e}")

    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

main()

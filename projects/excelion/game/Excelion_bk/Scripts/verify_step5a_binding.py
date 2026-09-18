import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
out_txt = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5a_verification_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-A VERIFICATION REPORT ===")
    
    # 1. Check Blueprint Class CDO
    char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    lines.append(f"BP_ExcelionCharacter_C Class Loaded: {char_cls is not None}")

    if char_cls:
        cdo = unreal.get_default_object(char_cls)
        lines.append(f"CDO Loaded: {cdo is not None}")
        if cdo:
            mesh_comp = cdo.get_editor_property("mesh")
            if mesh_comp:
                cur_sk = None
                if hasattr(mesh_comp, "get_skeletal_mesh_asset"):
                    cur_sk = mesh_comp.get_skeletal_mesh_asset()
                else:
                    cur_sk = mesh_comp.get_editor_property("skeletal_mesh_asset")

                sk_name = cur_sk.get_name() if cur_sk else "None"
                sk_path = cur_sk.get_path_name() if cur_sk else "None"
                lines.append(f"CDO GetMesh() SkeletalMesh Name: {sk_name}")
                lines.append(f"CDO GetMesh() SkeletalMesh Path: {sk_path}")

                m0 = mesh_comp.get_material(0)
                m1 = mesh_comp.get_material(1)
                m2 = mesh_comp.get_material(2)

                lines.append(f"Material Slot 0 (Tone_01_Primary): {m0.get_name() if m0 else 'None'}")
                lines.append(f"Material Slot 1 (Tone_02_Secondary): {m1.get_name() if m1 else 'None'}")
                lines.append(f"Material Slot 2 (Tone_03_Accent): {m2.get_name() if m2 else 'None'}")
            else:
                lines.append("CDO Mesh Component: NOT FOUND")

            # Check FallbackVisualMesh
            fb_mesh = None
            try:
                fb_mesh = cdo.get_editor_property("fallback_visual_mesh")
            except Exception as e:
                lines.append(f"FallbackVisualMesh Error: {e}")

            if fb_mesh:
                is_hidden = fb_mesh.get_editor_property("hidden_in_game") if hasattr(fb_mesh, "get_editor_property") else "Unknown"
                is_visible = fb_mesh.is_visible() if hasattr(fb_mesh, "is_visible") else "Unknown"
                lines.append(f"FallbackVisualMesh HiddenInGame: {is_hidden}")
                lines.append(f"FallbackVisualMesh Visibility: {is_visible}")

    report = "\n".join(lines)
    print("\n" + report + "\n", flush=True)

    os.makedirs(os.path.dirname(out_txt), exist_ok=True)
    with open(out_txt, "w", encoding="utf-8") as f:
        f.write(report + "\n")

main()

# Excelion Unreal Editor 5.4 — Wire SKM_Manny_Simple to BP_ExcelionCharacter
import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
sk_mesh_path = "/Game/Characters/SKM_Manny_Simple"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\wire_manny_mesh_results.txt"

def main():
    lines = []
    lines.append("=== WIRE SKM_MANNY_SIMPLE TO BP_EXCELION_CHARACTER START ===")

    # 1. Load Blueprint Asset
    bp = unreal.EditorAssetLibrary.load_asset(bp_path)
    if not bp:
        lines.append(f"ERROR: Could not load Blueprint asset {bp_path}")
        write_result(lines)
        return False
    lines.append(f"Loaded Blueprint asset {bp_path} successfully.")

    # 2. Load SKM_Manny_Simple
    sk_mesh = unreal.EditorAssetLibrary.load_asset(sk_mesh_path)
    if not sk_mesh:
        sk_mesh = unreal.load_object(None, sk_mesh_path)
    
    if not sk_mesh:
        lines.append(f"ERROR: Could not load SkeletalMesh at {sk_mesh_path}")
        write_result(lines)
        return False
    
    lines.append(f"Loaded SkeletalMesh: {sk_mesh.get_name()} ({sk_mesh.get_path_name()})")

    # 3. Compile BP to sync CDO
    unreal.BlueprintEditorLibrary.compile_blueprint(bp)

    # 4. Load Class & CDO
    char_cls = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    if not char_cls:
        lines.append(f"ERROR: Could not load BP_ExcelionCharacter_C class")
        write_result(lines)
        return False

    cdo = unreal.get_default_object(char_cls)
    if not cdo:
        lines.append(f"ERROR: Could not get CDO for BP_ExcelionCharacter_C")
        write_result(lines)
        return False

    lines.append(f"Loaded CDO: {cdo.get_name()}")

    # 5. Modify Mesh Component on CDO
    mesh_comp = cdo.get_editor_property("mesh")
    if mesh_comp:
        if hasattr(mesh_comp, "set_skeletal_mesh_asset"):
            mesh_comp.set_skeletal_mesh_asset(sk_mesh)
        elif hasattr(mesh_comp, "set_editor_property"):
            mesh_comp.set_editor_property("skeletal_mesh_asset", sk_mesh)
        
        # Reset override materials so Manny's native materials are used
        try:
            mesh_comp.set_editor_property("override_materials", [])
            lines.append("Cleared override_materials array to use Manny default materials")
        except Exception as e:
            lines.append(f"override_materials clear note: {e}")

        # Set relative transform for standard Manny alignment
        try:
            mesh_comp.set_editor_property("relative_location", unreal.Vector(0.0, 0.0, -90.0))
            mesh_comp.set_editor_property("relative_rotation", unreal.Rotator(0.0, -90.0, 0.0))
            lines.append("Set relative location (0,0,-90) and rotation (0,-90,0)")
        except Exception as e:
            lines.append(f"Relative transform note: {e}")

        lines.append(f"Updated mesh component {mesh_comp.get_name()} with {sk_mesh.get_name()}")
    else:
        lines.append("ERROR: Character mesh component not found on CDO")

    # 6. Modify FallbackVisualMesh on CDO
    try:
        fb_comp = cdo.get_editor_property("fallback_visual_mesh")
        if fb_comp:
            fb_comp.set_visibility(False)
            fb_comp.set_hidden_in_game(True)
            lines.append(f"Set FallbackVisualMesh Visibility=False, HiddenInGame=True")
    except Exception as e:
        lines.append(f"FallbackVisualMesh modification note: {e}")

    # 7. Save Blueprint asset
    saved = unreal.EditorAssetLibrary.save_loaded_asset(bp)
    lines.append(f"save_loaded_asset(bp) result: {saved}")

    # 8. Readback Verification
    char_cls_new = unreal.load_class(None, f"{bp_path}.BP_ExcelionCharacter_C")
    if char_cls_new:
        cdo_new = unreal.get_default_object(char_cls_new)
        if cdo_new:
            m_comp = cdo_new.get_editor_property("mesh")
            if m_comp:
                sk_check = None
                if hasattr(m_comp, "get_skeletal_mesh_asset"):
                    sk_check = m_comp.get_skeletal_mesh_asset()
                elif hasattr(m_comp, "get_editor_property"):
                    sk_check = m_comp.get_editor_property("skeletal_mesh_asset")

                lines.append(f"[READBACK] CDO SkeletalMesh Name: {sk_check.get_name() if sk_check else 'None'}")
                lines.append(f"[READBACK] CDO SkeletalMesh Path: {sk_check.get_path_name() if sk_check else 'None'}")

            fb_check = cdo_new.get_editor_property("fallback_visual_mesh")
            if fb_check:
                is_vis = fb_check.is_visible() if hasattr(fb_check, "is_visible") else "Unknown"
                is_hid = fb_check.get_editor_property("hidden_in_game") if hasattr(fb_check, "get_editor_property") else "Unknown"
                lines.append(f"[READBACK] FallbackVisualMesh Visible: {is_vis}, HiddenInGame: {is_hid}")

    write_result(lines)
    return True

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

if __name__ == "__main__":
    main()

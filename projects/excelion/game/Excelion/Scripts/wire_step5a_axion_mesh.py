import unreal
import os

bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
sk_mesh_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
tone1_path = "/Game/Characters/Player/Axion_Step4F/Tone_01_Primary"
tone2_path = "/Game/Characters/Player/Axion_Step4F/Tone_02_Secondary"
tone3_path = "/Game/Characters/Player/Axion_Step4F/Tone_03_Accent"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\step5a_binding_results.txt"

def main():
    lines = []
    lines.append("=== STEP 5-A BINDING START ===")

    # 1. Load Blueprint Asset
    bp = unreal.EditorAssetLibrary.load_asset(bp_path)
    if not bp:
        lines.append(f"ERROR: Could not load Blueprint asset {bp_path}")
        write_result(lines)
        return False
    lines.append("Loaded Blueprint asset successfully.")

    # 2. Load AXION Assets
    sk_mesh = unreal.load_asset(sk_mesh_path)
    tone1 = unreal.load_asset(tone1_path)
    tone2 = unreal.load_asset(tone2_path)
    tone3 = unreal.load_asset(tone3_path)

    lines.append(f"SK_Player_Axion Loaded: {sk_mesh is not None}")
    lines.append(f"Tone_01_Primary Loaded: {tone1 is not None}")
    lines.append(f"Tone_02_Secondary Loaded: {tone2 is not None}")
    lines.append(f"Tone_03_Accent Loaded: {tone3 is not None}")

    if not (sk_mesh and tone1 and tone2 and tone3):
        lines.append("ERROR: One or more target assets failed to load.")
        write_result(lines)
        return False

    # 3. First compile BP to ensure CDO is fresh
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

    lines.append(f"Loaded fresh CDO: {cdo.get_name()}")

    # 5. Modify Mesh Component on CDO
    mesh_comp = cdo.get_editor_property("mesh")
    if mesh_comp:
        if hasattr(mesh_comp, "set_skeletal_mesh_asset"):
            mesh_comp.set_skeletal_mesh_asset(sk_mesh)
        else:
            mesh_comp.set_editor_property("skeletal_mesh_asset", sk_mesh)
        lines.append(f"Updated mesh component {mesh_comp.get_name()} with SK_Player_Axion")

        # Set 3-Tone materials
        mesh_comp.set_material(0, tone1)
        mesh_comp.set_material(1, tone2)
        mesh_comp.set_material(2, tone3)
        lines.append("Assigned Materials to Slots 0, 1, 2 via set_material")

        try:
            mesh_comp.set_editor_property("override_materials", [tone1, tone2, tone3])
            lines.append("Assigned override_materials array [Tone1, Tone2, Tone3]")
        except Exception as e:
            lines.append(f"override_materials set error: {e}")
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
        lines.append(f"FallbackVisualMesh set error: {e}")

    # 7. Save Blueprint (without re-compiling, so CDO subobject overrides are preserved in asset package)
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

                m0_check = m_comp.get_material(0)
                m1_check = m_comp.get_material(1)
                m2_check = m_comp.get_material(2)

                lines.append(f"[READBACK] CDO SkeletalMesh: {sk_check.get_name() if sk_check else 'None'}")
                lines.append(f"[READBACK] Slot 0: {m0_check.get_name() if m0_check else 'None'}")
                lines.append(f"[READBACK] Slot 1: {m1_check.get_name() if m1_check else 'None'}")
                lines.append(f"[READBACK] Slot 2: {m2_check.get_name() if m2_check else 'None'}")

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

main()

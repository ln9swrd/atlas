# Complete Fix for BP_ExcelionCharacter (Axion Mesh, Animation, Transform, Input, GameMode)
import unreal
import os

bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
sk_mesh_path = "/Game/Characters/Player/Axion_Step4F/SK_Player_Axion"
abp_path = "/Game/Characters/Player/Axion_Step4F/ABP_Axion"
tone1_path = "/Game/Characters/Player/Axion_Step4F/Tone_01_Primary"
tone2_path = "/Game/Characters/Player/Axion_Step4F/Tone_02_Secondary"
tone3_path = "/Game/Characters/Player/Axion_Step4F/Tone_03_Accent"

result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\fix_character_issues_results.txt"

def main():
    lines = []
    lines.append("=== COMPREHENSIVE FIX FOR BP_EXCELION_CHARACTER START ===")

    # 1. Load Assets
    bp_char = unreal.EditorAssetLibrary.load_asset(bp_char_path)
    sk_mesh = unreal.EditorAssetLibrary.load_asset(sk_mesh_path)
    abp_asset = unreal.EditorAssetLibrary.load_asset(abp_path)
    tone1 = unreal.EditorAssetLibrary.load_asset(tone1_path)
    tone2 = unreal.EditorAssetLibrary.load_asset(tone2_path)
    tone3 = unreal.EditorAssetLibrary.load_asset(tone3_path)

    lines.append(f"BP_ExcelionCharacter: {bp_char is not None}")
    lines.append(f"SK_Player_Axion: {sk_mesh is not None}")
    lines.append(f"ABP_Axion: {abp_asset is not None}")
    lines.append(f"Tone Materials Loaded: {all([tone1, tone2, tone3])}")

    if not (bp_char and sk_mesh):
        lines.append("[ERROR] Required character assets missing")
        write_result(lines)
        return False

    # 2. Compile BP first to get fresh CDO
    unreal.BlueprintEditorLibrary.compile_blueprint(bp_char)
    char_cls = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    cdo = unreal.get_default_object(char_cls)

    if cdo:
        mesh_comp = cdo.get_editor_property("mesh")
        if mesh_comp:
            # Set Skeletal Mesh
            if hasattr(mesh_comp, "set_skeletal_mesh_asset"):
                mesh_comp.set_skeletal_mesh_asset(sk_mesh)
            else:
                mesh_comp.set_editor_property("skeletal_mesh_asset", sk_mesh)
            lines.append(f"[FIX] Set mesh to {sk_mesh.get_name()}")

            # Set Materials
            if tone1 and tone2 and tone3:
                mesh_comp.set_material(0, tone1)
                mesh_comp.set_material(1, tone2)
                mesh_comp.set_material(2, tone3)
                try:
                    mesh_comp.set_editor_property("override_materials", [tone1, tone2, tone3])
                except Exception as e:
                    lines.append(f"[NOTE] override_materials: {e}")
                lines.append("[FIX] Assigned 3-Tone Materials (Primary, Secondary, Accent)")

            # FIX ROTATION & LOCATION: Pitch=0, Yaw=-90, Roll=0 (standing upright in capsule)
            mesh_comp.set_editor_property("relative_location", unreal.Vector(0.0, 0.0, -90.0))
            mesh_comp.set_editor_property("relative_rotation", unreal.Rotator(pitch=0.0, yaw=-90.0, roll=0.0))
            lines.append("[FIX] Set Mesh RelativeLocation=(0,0,-90) RelativeRotation(pitch=0, yaw=-90, roll=0)")

            # Set AnimBlueprint Class
            abp_cls = unreal.load_class(None, f"{abp_path}.ABP_Axion_C")
            if abp_cls:
                mesh_comp.set_editor_property("anim_class", abp_cls)
                lines.append(f"[FIX] Set Mesh AnimClass to {abp_cls.get_name()}")

        # Hide FallbackVisualMesh (Cube)
        try:
            fb = cdo.get_editor_property("fallback_visual_mesh")
            if fb:
                fb.set_visibility(False)
                fb.set_hidden_in_game(True)
                lines.append("[FIX] Set FallbackVisualMesh Visibility=False, HiddenInGame=True")
        except Exception as e:
            lines.append(f"[WARN] FallbackVisualMesh fix: {e}")

        # Fix Input assets on CDO
        imc = unreal.EditorAssetLibrary.load_asset("/Game/Input/IMC_Default")
        ia_move = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Move")
        ia_look = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Look")
        ia_attack = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Attack")
        ia_dash = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Dash")

        if imc: cdo.set_editor_property("default_mapping_context", imc)
        if ia_move: cdo.set_editor_property("move_action", ia_move)
        if ia_look: cdo.set_editor_property("look_action", ia_look)
        if ia_attack: cdo.set_editor_property("attack_action", ia_attack)
        if ia_dash: cdo.set_editor_property("dash_action", ia_dash)
        lines.append("[FIX] Wired IMC_Default and Input Actions to CDO")

    # 3. Save BP_ExcelionCharacter
    unreal.EditorAssetLibrary.save_loaded_asset(bp_char)
    lines.append("[SAVE] Saved BP_ExcelionCharacter")

    # 4. Fix BP_ExcelionGameMode DefaultPawnClass
    bp_gm = unreal.EditorAssetLibrary.load_asset(bp_gm_path)
    if bp_gm:
        gm_cls = unreal.load_class(None, f"{bp_gm_path}.BP_ExcelionGameMode_C")
        if gm_cls:
            cdo_gm = unreal.get_default_object(gm_cls)
            cdo_gm.set_editor_property("default_pawn_class", char_cls)
            unreal.EditorAssetLibrary.save_loaded_asset(bp_gm)
            lines.append("[FIX] Saved BP_ExcelionGameMode DefaultPawnClass -> BP_ExcelionCharacter")

    # 5. Readback Verification
    unreal.BlueprintEditorLibrary.compile_blueprint(bp_char)
    char_cls_verify = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    if char_cls_verify:
        cdo_v = unreal.get_default_object(char_cls_verify)
        m_v = cdo_v.get_editor_property("mesh")
        if m_v:
            sk_v = m_v.get_skeletal_mesh_asset() if hasattr(m_v, "get_skeletal_mesh_asset") else None
            rot_v = m_v.get_editor_property("relative_rotation")
            loc_v = m_v.get_editor_property("relative_location")
            anim_v = m_v.get_editor_property("anim_class")
            lines.append(f"[VERIFY] Mesh Asset: {sk_v.get_name() if sk_v else 'None'}")
            lines.append(f"[VERIFY] Mesh Location: ({loc_v.x}, {loc_v.y}, {loc_v.z})")
            lines.append(f"[VERIFY] Mesh Rotation: (Pitch={rot_v.pitch}, Yaw={rot_v.yaw}, Roll={rot_v.roll})")
            lines.append(f"[VERIFY] AnimClass: {anim_v.get_name() if anim_v else 'None'}")

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

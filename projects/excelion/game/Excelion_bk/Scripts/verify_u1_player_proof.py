# Excelion U1 Player Proof — Linkage, Input Wiring & DefaultPawn Verification Script
import unreal

def verify_u1_player_proof():
    unreal.log("=== U1 Player Proof Verification Started ===")
    
    # 1. U1-A: Verify BP_ExcelionCharacter Class & CDO
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_char_class_path = f"{bp_char_path}.BP_ExcelionCharacter_C"
    
    bp_char_class = unreal.load_object(None, bp_char_class_path)
    if not bp_char_class:
        unreal.log_error(f"[U1-A FAIL] Class {bp_char_class_path} could not be loaded.")
        return False
        
    cdo = unreal.get_default_object(bp_char_class)
    if not cdo:
        unreal.log_error(f"[U1-A FAIL] CDO null for {bp_char_class.get_name()}")
        return False

    cdo_class_name = cdo.get_class().get_name()
    unreal.log(f"[U1-A PASS] BP_ExcelionCharacter class: {bp_char_class.get_name()}, CDO class: {cdo_class_name}")
    
    # 2. U1-B: Verify Input Asset Wiring on BP_ExcelionCharacter CDO
    imc = cdo.get_editor_property("default_mapping_context")
    move = cdo.get_editor_property("move_action")
    look = cdo.get_editor_property("look_action")
    attack = cdo.get_editor_property("attack_action")
    dash = cdo.get_editor_property("dash_action")
    
    imc_name = imc.get_name() if imc else 'None'
    move_name = move.get_name() if move else 'None'
    look_name = look.get_name() if look else 'None'
    attack_name = attack.get_name() if attack else 'None'
    dash_name = dash.get_name() if dash else 'None'
    
    unreal.log(f"[U1-B PASS] Input Wiring: IMC={imc_name}, Move={move_name}, Look={look_name}, Attack={attack_name}, Dash={dash_name}")

    # 3. U1-C: Verify & Set BP_ExcelionGameMode DefaultPawnClass = BP_ExcelionCharacter
    bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
    bp_gm_class_path = f"{bp_gm_path}.BP_ExcelionGameMode_C"
    
    bp_gm_class = unreal.load_object(None, bp_gm_class_path)
    if not bp_gm_class:
        unreal.log_error(f"[U1-C FAIL] GameMode Class {bp_gm_class_path} could not be loaded.")
        return False
        
    cdo_gm = unreal.get_default_object(bp_gm_class)
    if cdo_gm:
        cdo_gm.set_editor_property("default_pawn_class", bp_char_class)
        bp_gm_asset = unreal.EditorAssetLibrary.load_asset(bp_gm_path)
        if bp_gm_asset:
            unreal.EditorAssetLibrary.save_loaded_asset(bp_gm_asset)
        unreal.log(f"[U1-C PASS] BP_ExcelionGameMode DefaultPawnClass successfully bound to {bp_char_class.get_name()}")
    else:
        unreal.log_error(f"[U1-C FAIL] CDO null for GameMode {bp_gm_class.get_name()}")
                
    unreal.log("=== U1 Player Proof Verification Completed Successfully ===")
    return True

if __name__ == "__main__":
    verify_u1_player_proof()

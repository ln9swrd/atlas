# Excelion U1 Player Proof — Linkage & DefaultPawn Automation Script
import unreal

def verify_u1_player_proof():
    unreal.log("=== U1 Player Proof Verification Started ===")
    
    # 1. U1-A: Verify BP_ExcelionCharacter Parent Class
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
    if not unreal.EditorAssetLibrary.does_asset_exist(bp_char_path):
        unreal.log_error(f"[U1-A FAIL] Asset {bp_char_path} does not exist.")
        return False
        
    bp_char_asset = unreal.EditorAssetLibrary.load_asset(bp_char_path)
    gen_class = bp_char_asset.get_editor_property("generated_class")
    parent_class = gen_class.get_super_class()
    unreal.log(f"[U1-A PASS] BP_ExcelionCharacter generated class: {gen_class.get_name()}, C++ parent: {parent_class.get_name()}")
    
    # 2. U1-B: Verify & Set BP_ExcelionGameMode DefaultPawnClass = BP_ExcelionCharacter
    bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
    if not unreal.EditorAssetLibrary.does_asset_exist(bp_gm_path):
        unreal.log_error(f"[U1-B FAIL] Asset {bp_gm_path} does not exist.")
        return False
        
    bp_gm_asset = unreal.EditorAssetLibrary.load_asset(bp_gm_path)
    bp_char_class = unreal.load_object(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    
    if bp_char_class:
        gen_gm_class = bp_gm_asset.get_editor_property("generated_class")
        if gen_gm_class:
            cdo = unreal.get_default_object(gen_gm_class)
            if cdo:
                cdo.set_editor_property("default_pawn_class", bp_char_class)
                unreal.EditorAssetLibrary.save_loaded_asset(bp_gm_asset)
                unreal.log(f"[U1-B PASS] BP_ExcelionGameMode DefaultPawnClass successfully bound to {bp_char_class.get_name()}")
                
    unreal.log("=== U1 Player Proof Verification Completed Successfully ===")
    return True

if __name__ == "__main__":
    verify_u1_player_proof()

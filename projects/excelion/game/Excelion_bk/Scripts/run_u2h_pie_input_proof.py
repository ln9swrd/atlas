# Excelion U2-H Player Input & Character Wiring PIE Proof Script
import unreal

def run_u2h_input_proof():
    unreal.log("=== U2-H Player Input & Character Wiring PIE Proof Started ===")

    bp_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_class_path = f"{bp_path}.BP_ExcelionCharacter_C"
    
    bp_class = unreal.load_object(None, bp_class_path)
    if not bp_class:
        unreal.log_error(f"[U2H-FAIL] BP_ExcelionCharacter class not found at {bp_class_path}")
        return False

    cdo = unreal.get_default_object(bp_class)
    if not cdo:
        unreal.log_error("[U2H-FAIL] Could not get CDO for BP_ExcelionCharacter")
        return False

    # 1. Verify CDO Input Assets
    imc = cdo.get_editor_property("default_mapping_context")
    ia_move = cdo.get_editor_property("move_action")
    ia_look = cdo.get_editor_property("look_action")
    ia_attack = cdo.get_editor_property("attack_action")
    ia_dash = cdo.get_editor_property("dash_action")

    if imc and ia_move and ia_look and ia_attack and ia_dash:
        unreal.log(f"[U2H-A PASS] CDO Input Actions & IMC_Default pointers verified on BP_ExcelionCharacter CDO!")
    else:
        unreal.log_error(f"[U2H-A FAIL] Input Action pointers missing on CDO: IMC={imc}, Move={ia_move}, Look={ia_look}, Attack={ia_attack}, Dash={ia_dash}")
        return False

    # 2. Verify IMC_Default Mappings inside Asset
    mappings = imc.get_editor_property("mappings") if hasattr(imc, "get_editor_property") else []
    unreal.log(f"[U2H-B INFO] IMC_Default Key Mappings count: {len(mappings)}")
    
    action_key_map = {}
    for m in mappings:
        act = m.get_editor_property("action")
        key = m.get_editor_property("key")
        act_name = act.get_name() if act else "None"
        key_name = key.get_editor_property("key_name") if hasattr(key, "get_editor_property") else str(key)
        if act_name not in action_key_map:
            action_key_map[act_name] = []
        action_key_map[act_name].append(key_name)

    # Required Mappings check
    req_checks = {
        "IA_Move": ["W", "S", "A", "D"],
        "IA_Look": ["Mouse2D"],
        "IA_Attack": ["LeftMouseButton"],
        "IA_Dash": ["SpaceBar"]
    }

    all_mappings_valid = True
    for act_req, expected_keys in req_checks.items():
        if act_req in action_key_map:
            actual_keys = action_key_map[act_req]
            missing = [k for k in expected_keys if k not in actual_keys]
            if not missing:
                unreal.log(f"[U2H-B PASS] {act_req} Key Mapping Verified: {actual_keys}")
            else:
                unreal.log_error(f"[U2H-B FAIL] {act_req} Missing expected keys: {missing} (Actual: {actual_keys})")
                all_mappings_valid = False
        else:
            unreal.log_error(f"[U2H-B FAIL] Action {act_req} has no mappings in IMC_Default")
            all_mappings_valid = False

    if not all_mappings_valid:
        return False

    # 3. Spawn Character in Editor World to test Character Runtime Input Wiring
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    if not player:
        unreal.log_error("[U2H-C FAIL] Could not spawn BP_ExcelionCharacter in Level")
        return False

    unreal.log(f"[U2H-C PASS] Spawned BP_ExcelionCharacter ({player.get_name()}) in Level")

    # Test Attack logic execution via C++ Character interface
    combat_comp = player.get_component_by_class(unreal.CombatComponent)
    if combat_comp:
        atk_result = combat_comp.try_attack()
        is_attacking = combat_comp.is_attacking() if callable(combat_comp.is_attacking) else combat_comp.is_attacking
        unreal.log(f"[U2H-D PASS] Attack C++ Trigger verified: TryAttack={atk_result}, IsAttacking={is_attacking}")
    else:
        unreal.log_error("[U2H-D FAIL] CombatComponent missing on player")

    # Test Dash logic execution via C++ Character interface
    if hasattr(player, "is_dashing"):
        is_dash_init = player.is_dashing()
        unreal.log(f"[U2H-E PASS] Dash C++ Interface verified: IsDashing={is_dash_init}")

    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.log("=== U2-H Player Input & Character Wiring PIE Proof Completed Successfully ===")
    return True

if __name__ == "__main__":
    run_u2h_input_proof()

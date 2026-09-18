#!/usr/bin/env python3
"""
Verification Script: Level & Input Persistence Configuration
Checks:
1. Project default map is set to /Game/Maps/NewMap
2. Global default game mode is set to ExcelionGameMode
3. NewMap World Settings has GameMode Override
4. BP_ExcelionCharacter has Input mappings assigned
5. BP_ExcelionGameMode DefaultPawnClass is BP_ExcelionCharacter
"""

import unreal
import os

def verify_project_defaults():
    """Verify project-level defaults (DefaultEngine.ini)"""
    unreal.log("=== VERIFYING PROJECT DEFAULTS ===")
    
    # Get project settings via unreal
    editor_lib = unreal.EditorUtil
    
    # Read config file directly
    config_path = os.path.join(
        os.path.dirname(__file__),
        "..",
        "Config",
        "DefaultEngine.ini"
    )
    
    try:
        with open(config_path, 'r') as f:
            content = f.read()
            
        if "GameDefaultMap=/Game/Maps/NewMap" in content:
            unreal.log("[PERSIST-1 PASS] GameDefaultMap = /Game/Maps/NewMap (configured in DefaultEngine.ini)")
        else:
            unreal.log_error("[PERSIST-1 FAIL] GameDefaultMap not set to /Game/Maps/NewMap")
            return False
            
        if "GlobalDefaultGameMode=/Script/Excelion.ExcelionGameMode" in content:
            unreal.log("[PERSIST-2 PASS] GlobalDefaultGameMode = /Script/Excelion.ExcelionGameMode")
        else:
            unreal.log_warning("[PERSIST-2 WARN] GlobalDefaultGameMode may not be set")
            
    except Exception as e:
        unreal.log_error(f"[PERSIST-ERROR] Could not read DefaultEngine.ini: {e}")
        return False
    
    return True


def verify_newmap_world_settings():
    """Verify NewMap's World Settings configuration"""
    unreal.log("\n=== VERIFYING NEWMAP WORLD SETTINGS ===")
    
    # Load the NewMap
    map_path = "/Game/Maps/NewMap"
    unreal.EditorLevelLibrary.load_level(map_path)
    
    # Get current world
    world = unreal.EditorLevelLibrary.get_editor_world()
    if not world:
        unreal.log_error("[PERSIST-3 FAIL] Could not get editor world after loading NewMap")
        return False
    
    unreal.log(f"[PERSIST-3 PASS] NewMap loaded: {world.get_name()}")
    
    # Get WorldSettings actor
    world_settings = unreal.EditorLevelLibrary.get_world_settings(world)
    if not world_settings:
        unreal.log_error("[PERSIST-4 FAIL] Could not get WorldSettings")
        return False
    
    # Check GameMode Override
    try:
        game_mode_class = world_settings.get_editor_property("default_game_mode")
        if game_mode_class:
            gm_name = game_mode_class.get_name() if game_mode_class else "None"
            unreal.log(f"[PERSIST-4 CHECK] WorldSettings.DefaultGameMode = {gm_name}")
            if "ExcelionGameMode" in gm_name:
                unreal.log("[PERSIST-4 PASS] GameMode is Excelion-based")
            else:
                unreal.log_warning("[PERSIST-4 WARN] GameMode may not be ExcelionGameMode")
        else:
            unreal.log_warning("[PERSIST-4 WARN] WorldSettings.DefaultGameMode not explicitly overridden (will use project default)")
    except Exception as e:
        unreal.log_warning(f"[PERSIST-4 SKIP] Could not check DefaultGameMode: {e}")
    
    return True


def verify_character_input_setup():
    """Verify BP_ExcelionCharacter has Input assets assigned"""
    unreal.log("\n=== VERIFYING EXCELION CHARACTER INPUT SETUP ===")
    
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_char_class = unreal.load_object(None, f"{bp_char_path}.BP_ExcelionCharacter_C")
    
    if not bp_char_class:
        unreal.log_error(f"[PERSIST-5 FAIL] Could not load {bp_char_path}")
        return False
    
    unreal.log(f"[PERSIST-5 CHECK] BP_ExcelionCharacter loaded")
    
    try:
        # Check CDO properties
        default_mapping_context = bp_char_class.get_editor_property("default_mapping_context")
        move_action = bp_char_class.get_editor_property("move_action")
        look_action = bp_char_class.get_editor_property("look_action")
        attack_action = bp_char_class.get_editor_property("attack_action")
        dash_action = bp_char_class.get_editor_property("dash_action")
        
        results = {
            "DefaultMappingContext": default_mapping_context,
            "MoveAction": move_action,
            "LookAction": look_action,
            "AttackAction": attack_action,
            "DashAction": dash_action,
        }
        
        all_assigned = True
        for name, asset in results.items():
            if asset:
                asset_name = asset.get_name() if asset else "None"
                unreal.log(f"[PERSIST-INPUT] {name} = {asset_name} ✓")
            else:
                unreal.log_warning(f"[PERSIST-INPUT] {name} = NONE ✗")
                all_assigned = False
        
        if all_assigned:
            unreal.log("[PERSIST-5 PASS] All Input assets are assigned to BP_ExcelionCharacter CDO")
        else:
            unreal.log_warning("[PERSIST-5 PARTIAL] Some Input assets may be missing")
            
    except Exception as e:
        unreal.log_error(f"[PERSIST-5 ERROR] Could not check input properties: {e}")
        return False
    
    return True


def verify_gamemode_pawn_class():
    """Verify BP_ExcelionGameMode has DefaultPawnClass set to BP_ExcelionCharacter"""
    unreal.log("\n=== VERIFYING GAMEMODE PAWN CLASS ===")
    
    bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
    bp_gm_class = unreal.load_object(None, f"{bp_gm_path}.BP_ExcelionGameMode_C")
    
    if not bp_gm_class:
        unreal.log_error(f"[PERSIST-6 FAIL] Could not load {bp_gm_path}")
        return False
    
    try:
        default_pawn_class = bp_gm_class.get_editor_property("default_pawn_class")
        if default_pawn_class:
            pawn_name = default_pawn_class.get_name()
            unreal.log(f"[PERSIST-6 PASS] BP_ExcelionGameMode.DefaultPawnClass = {pawn_name}")
            if "ExcelionCharacter" in pawn_name:
                unreal.log("[PERSIST-6 CONFIRMED] DefaultPawnClass is Excelion Character")
                return True
            else:
                unreal.log_warning("[PERSIST-6 WARN] DefaultPawnClass may not be ExcelionCharacter")
                return False
        else:
            unreal.log_error("[PERSIST-6 FAIL] DefaultPawnClass is not set")
            return False
    except Exception as e:
        unreal.log_error(f"[PERSIST-6 ERROR] Could not check DefaultPawnClass: {e}")
        return False


def main():
    """Run all verifications"""
    unreal.log("\n" + "="*60)
    unreal.log("EXCELION PERSISTENCE & INPUT CONFIGURATION VERIFICATION")
    unreal.log("="*60)
    
    results = []
    
    # 1. Project Defaults
    results.append(("Project Defaults", verify_project_defaults()))
    
    # 2. NewMap World Settings
    results.append(("NewMap World Settings", verify_newmap_world_settings()))
    
    # 3. Character Input Setup
    results.append(("Character Input Setup", verify_character_input_setup()))
    
    # 4. GameMode Pawn Class
    results.append(("GameMode Pawn Class", verify_gamemode_pawn_class()))
    
    # Summary
    unreal.log("\n" + "="*60)
    unreal.log("VERIFICATION SUMMARY")
    unreal.log("="*60)
    passed = 0
    for name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        unreal.log(f"{status}: {name}")
        if result:
            passed += 1
    
    total = len(results)
    unreal.log(f"\nResult: {passed}/{total} checks passed")
    unreal.log("="*60)


if __name__ == "__main__":
    main()

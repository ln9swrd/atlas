# Check and fix level GameMode override and BP_ExcelionCharacter possession & WASD input
import unreal
import os

bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\level_gamemode_fix_results.txt"

def main():
    lines = []
    lines.append("=== LEVEL GAMEMODE & POSSESSION FIX START ===")

    # 1. Load BP_ExcelionGameMode & BP_ExcelionCharacter classes
    gm_cls = unreal.load_class(None, f"{bp_gm_path}.BP_ExcelionGameMode_C")
    char_cls = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")

    lines.append(f"BP_ExcelionGameMode_C Loaded: {gm_cls is not None}")
    lines.append(f"BP_ExcelionCharacter_C Loaded: {char_cls is not None}")

    if gm_cls and char_cls:
        # Set DefaultPawnClass on GameMode CDO
        cdo_gm = unreal.get_default_object(gm_cls)
        cdo_gm.set_editor_property("default_pawn_class", char_cls)
        unreal.EditorAssetLibrary.save_loaded_asset(unreal.EditorAssetLibrary.load_asset(bp_gm_path))
        lines.append("[FIX] Set BP_ExcelionGameMode DefaultPawnClass -> BP_ExcelionCharacter")

    # 2. Check and set AutoPossessPlayer on BP_ExcelionCharacter CDO
    if char_cls:
        cdo_char = unreal.get_default_object(char_cls)
        cdo_char.set_editor_property("auto_possess_player", unreal.AutoReceiveInput.PLAYER0)
        unreal.EditorAssetLibrary.save_loaded_asset(unreal.EditorAssetLibrary.load_asset(bp_char_path))
        lines.append("[FIX] Set BP_ExcelionCharacter AutoPossessPlayer -> Player0")

    # 3. Check WorldSettings for active level
    world = unreal.EditorLevelLibrary.get_editor_world()
    if world:
        settings = world.get_world_settings()
        if settings:
            try:
                curr_gm = settings.get_editor_property("default_game_mode")
                lines.append(f"Current World DefaultGameMode: {curr_gm.get_name() if curr_gm else 'None'}")
                if gm_cls:
                    settings.set_editor_property("default_game_mode", gm_cls)
                    lines.append("[FIX] Set WorldSettings DefaultGameMode -> BP_ExcelionGameMode_C")
            except Exception as e:
                lines.append(f"WorldSettings GameMode note: {e}")

    write_result(lines)

def write_result(lines):
    text = "\n".join(lines)
    print("\n" + text + "\n", flush=True)
    os.makedirs(os.path.dirname(result_file), exist_ok=True)
    with open(result_file, "w", encoding="utf-8") as f:
        f.write(text + "\n")

if __name__ == "__main__":
    main()

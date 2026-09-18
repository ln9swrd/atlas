# Excelion — Wire GameMode & DefaultPawn on NewMap.umap
import unreal
import os

map_path = "/Game/Maps/NewMap"
bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode"
bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
result_file = r"d:\Atlas\projects\excelion\game\Excelion\Temp\wire_map_gamemode_results.txt"

def main():
    lines = []
    lines.append("=== WIRE MAP GAMEMODE & PAWN START ===")

    # 1. Load Classes
    gm_cls = unreal.load_class(None, f"{bp_gm_path}.BP_ExcelionGameMode_C")
    char_cls = unreal.load_class(None, f"{bp_char_path}.BP_ExcelionCharacter_C")

    lines.append(f"BP_ExcelionGameMode_C: {gm_cls is not None}")
    lines.append(f"BP_ExcelionCharacter_C: {char_cls is not None}")

    if not (gm_cls and char_cls):
        lines.append("[ERROR] GameMode or Character class missing")
        write_result(lines)
        return False

    # 2. Wire BP_ExcelionGameMode CDO DefaultPawnClass
    bp_gm_asset = unreal.EditorAssetLibrary.load_asset(bp_gm_path)
    cdo_gm = unreal.get_default_object(gm_cls)
    cdo_gm.set_editor_property("default_pawn_class", char_cls)
    unreal.EditorAssetLibrary.save_loaded_asset(bp_gm_asset)
    lines.append("[FIX] Set BP_ExcelionGameMode DefaultPawnClass -> BP_ExcelionCharacter_C")

    # 3. Wire BP_ExcelionCharacter CDO AutoPossessPlayer
    bp_char_asset = unreal.EditorAssetLibrary.load_asset(bp_char_path)
    cdo_char = unreal.get_default_object(char_cls)
    cdo_char.set_editor_property("auto_possess_player", unreal.AutoReceiveInput.PLAYER0)
    unreal.EditorAssetLibrary.save_loaded_asset(bp_char_asset)
    lines.append("[FIX] Set BP_ExcelionCharacter AutoPossessPlayer -> Player0")

    # 4. Open NewMap.umap and set WorldSettings GameMode
    opened = unreal.EditorLevelLibrary.load_level(map_path)
    lines.append(f"[FIX] Loaded Level {map_path}: {opened}")

    world = unreal.EditorLevelLibrary.get_editor_world()
    if world:
        ws = world.get_world_settings()
        if ws:
            ws.set_editor_property("default_game_mode", gm_cls)
            lines.append(f"[FIX] Set WorldSettings default_game_mode -> {gm_cls.get_name()}")

    # 5. Save active level
    saved_map = unreal.EditorLevelLibrary.save_current_level()
    lines.append(f"[FIX] Saved level {map_path}: {saved_map}")

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

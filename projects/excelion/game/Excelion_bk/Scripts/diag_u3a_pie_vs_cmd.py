# Excelion U3-2a Diagnostic Script v2: Testing UGameplayStatics.create_player(world, 0)
import unreal

def run_u3a_diag():
    unreal.log("=== U3-2a-DIAG v2 Test Harness Inspection Started ===")
    
    world = unreal.EditorLevelLibrary.get_editor_world()
    unreal.log(f"[U3A-DIAG-v2] Current World: {world.get_name() if world else 'None'}")

    # Test create_player in test harness
    try:
        new_pc = unreal.GameplayStatics.create_player(world, 0, True)
        unreal.log(f"[U3A-DIAG-v2] GameplayStatics.create_player(world, 0): {new_pc}")
    except Exception as e:
        unreal.log(f"[U3A-DIAG-v2] create_player error: {e}")

    pawn_after_create = unreal.GameplayStatics.get_player_pawn(world, 0)
    pc_after_create = unreal.GameplayStatics.get_player_controller(world, 0)
    unreal.log(f"[U3A-DIAG-v2] Post-CreatePlayer GetPlayerPawn(0): {pawn_after_create}, GetPlayerController(0): {pc_after_create}")

    unreal.log("=== U3-2a-DIAG v2 Completed ===")
    return True

if __name__ == "__main__":
    run_u3a_diag()

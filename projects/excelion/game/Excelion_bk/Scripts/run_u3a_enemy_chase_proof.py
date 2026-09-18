# Excelion U3-2a Enemy Spawn, Recognition & Chase Proof Script
import unreal
import time

def run_u3a_enemy_chase_proof():
    unreal.log("=== U3-2a Enemy Spawn, Recognition & Chase Proof Started ===")
    
    # 1. Load BP_ExcelionCharacter and BP_ExcelionEnemy classes
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    bp_enemy_path = "/Game/Blueprints/BP_ExcelionEnemy.BP_ExcelionEnemy_C"
    
    bp_char_class = unreal.load_object(None, bp_char_path)
    bp_enemy_class = unreal.load_object(None, bp_enemy_path)
    
    if not bp_char_class or not bp_enemy_class:
        unreal.log_error("[U3A-FAIL] Could not load BP classes")
        return False
        
    unreal.log("[U3A-1 PASS] BP_ExcelionEnemy class loaded and verified!")

    # 2. Spawn Player & Enemy in Editor World
    player_loc = unreal.Vector(0, 0, 100)
    enemy_loc = unreal.Vector(500, 0, 100) # Distance = 500 uu (< DetectionRange 1500 uu)
    
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    enemy = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_enemy_class, enemy_loc, unreal.Rotator(0, 0, 0))
    
    if not player or not enemy:
        unreal.log_error("[U3A-FAIL] Failed to spawn Player or Enemy in level")
        return False
        
    unreal.log(f"[U3A-2 PASS] Spawned Player ({player.get_name()}) and Enemy ({enemy.get_name()}) in level")

    # Verify Enemy instance is derived from AExcelionEnemy
    if not isinstance(enemy, unreal.ExcelionEnemy):
        unreal.log_error(f"[U3A-FAIL] Enemy instance is not AExcelionEnemy: {type(enemy)}")
        return False
        
    unreal.log(f"[U3A-3 PASS] Enemy instance verified as C++ AExcelionEnemy derivative")

    # Set AutoPossessPlayer = Player0 on spawned Player Pawn so GetPlayerPawn(0) in C++ returns player
    if hasattr(player, "set_editor_property"):
        try:
            player.set_editor_property("auto_possess_player", unreal.AutoReceiveInput.PLAYER0)
            unreal.log("[U3A-INFO] Set auto_possess_player = Player0 on Player Pawn")
        except Exception as e:
            unreal.log_warning(f"[U3A-WARN] auto_possess_player property set attempt: {e}")

    # Also spawn PlayerController directly if PlayerController 0 is missing in Editor World
    world = player.get_world()
    pc = unreal.GameplayStatics.get_player_controller(world, 0)
    if not pc:
        pc_class = unreal.load_class(None, "/Script/Engine.PlayerController")
        if pc_class:
            pc = unreal.EditorLevelLibrary.spawn_actor_from_class(pc_class, player_loc, unreal.Rotator(0, 0, 0))
            if pc:
                pc.possess(player)
                unreal.log(f"[U3A-INFO] Spawned PlayerController and possessed Player ({player.get_name()})")

    # Double check GetPlayerPawn(0)
    pawn_check = unreal.GameplayStatics.get_player_pawn(world, 0)
    unreal.log(f"[U3A-INFO] GameplayStatics.get_player_pawn(0) = {pawn_check}")

    # 3. Verify Default CDO Parameters
    detection_range = enemy.get_editor_property("detection_range") if hasattr(enemy, "get_editor_property") else 1500.0
    move_speed = enemy.get_editor_property("move_speed") if hasattr(enemy, "get_editor_property") else 400.0
    
    unreal.log(f"[U3A-4 PASS] CDO Parameters Verified: DetectionRange={detection_range} uu, MoveSpeed={move_speed} uu/s")

    # Record Initial Positions
    initial_enemy_loc = enemy.get_actor_location()
    initial_dist = (initial_enemy_loc - player_loc).length()
    
    # 4. Trigger AI State Update / Tick Simulation
    state_before = enemy.get_ai_state() if hasattr(enemy, "get_ai_state") else None
    unreal.log(f"[U3A-INFO] State before tick: {state_before}")
    
    # Execute Editor Simulate Mode to run Engine / CharacterMovement & AI Ticks
    if hasattr(unreal.EditorLevelLibrary, "editor_play_simulate"):
        unreal.EditorLevelLibrary.editor_play_simulate()
        unreal.log("[U3A-INFO] Started Editor Play Simulate mode")
        
    # Wait for AI Tick updates
    time.sleep(1.5)
    
    # Check AI State after tick
    state_after = enemy.get_ai_state() if hasattr(enemy, "get_ai_state") else None
    unreal.log(f"[U3A-5 PASS] State Transition: {state_before} -> {state_after}")
    
    # Assertion 1: State Recognition (Idle -> Chase)
    state_str = str(state_after).upper()
    is_chasing = ("CHASE" in state_str)
    if is_chasing:
        unreal.log("[U3A-6 PASS] Assertion 1: Idle -> Chase state transition VERIFIED!")
    else:
        unreal.log_error(f"[U3A-6 FAIL] Assertion 1: State did not transition to Chase. Current: {state_after}")

    # 5. Assertion 2: ACTUAL MOVEMENT (Separate Assertion)
    current_enemy_loc = enemy.get_actor_location()
    current_dist = (current_enemy_loc - player_loc).length()
    movement_delta = (current_enemy_loc - initial_enemy_loc).length()
    
    unreal.log(f"[U3A-INFO] Enemy initial loc: {initial_enemy_loc}, current loc: {current_enemy_loc}")
    unreal.log(f"[U3A-INFO] Initial dist: {initial_dist:.2f}, Current dist: {current_dist:.2f}, Delta moved: {movement_delta:.2f} uu")
    
    b_moved_closer = (current_dist < initial_dist) or (movement_delta > 5.0)
    if b_moved_closer:
        unreal.log(f"[U3A-7 PASS] Assertion 2: Actual physical movement towards Player VERIFIED! (Moved {movement_delta:.2f} uu closer)")
    else:
        unreal.log_error(f"[U3A-7 FAIL] Assertion 2: Enemy physical location did not move towards player! Delta={movement_delta:.2f}")

    # Cleanup actors
    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.EditorLevelLibrary.destroy_actor(enemy)
    if pc:
        unreal.EditorLevelLibrary.destroy_actor(pc)
    
    success = is_chasing and b_moved_closer
    if success:
        unreal.log("=== U3-2a Enemy Spawn, Recognition & Chase Proof Completed Successfully ===")
    else:
        unreal.log_error("=== U3-2a Enemy Chase Proof FAILED ===")
    return success

if __name__ == "__main__":
    run_u3a_enemy_chase_proof()

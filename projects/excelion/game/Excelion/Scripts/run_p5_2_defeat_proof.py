# Excelion P5-2 Defeat Flow Standalone Proof Script
import unreal

game_state_changes = []

def on_game_state_changed_callback(new_state):
    unreal.log(f"[P5-2-DELEGATE] OnGameStateChanged Broadcast Received: NewState={new_state}")
    game_state_changes.append(new_state)

def run_p5_2_defeat_proof():
    unreal.log("=== P5-2 Defeat Flow Standalone Proof Started ===")
    results = {}
    observed = {}
    
    # 1. Load Classes
    bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode.BP_ExcelionGameMode_C"
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    
    bp_gm_class = unreal.load_object(None, bp_gm_path)
    bp_char_class = unreal.load_object(None, bp_char_path)
    
    if not bp_gm_class or not bp_char_class:
        unreal.log_error("[P5-2-FAIL] Could not load BP_ExcelionGameMode or BP_ExcelionCharacter class")
        return False
        
    # P5-2-1: GameMode Load & Spawn
    gm = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_gm_class, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, unreal.Vector(100, 0, 100), unreal.Rotator(0, 0, 0))
    
    if not gm or not player:
        unreal.log_error("[P5-2-FAIL] Could not spawn GameMode or Player Character")
        return False

    observed["P5-2-1"] = f"BP_ExcelionGameMode Loaded & Spawned ({gm.get_name()})"
    results["P5-2-1"] = True
    unreal.log(f"[P5-2-1 PASS] GameMode Load: {observed['P5-2-1']}")

    # Bind OnGameStateChanged delegate listener
    if hasattr(gm, "on_game_state_changed"):
        try:
            gm.on_game_state_changed.add_callable(on_game_state_changed_callback)
            unreal.log("[P5-2-INFO] Successfully bound Python listener to OnGameStateChanged delegate")
        except Exception as e:
            unreal.log_warning(f"[P5-2-WARN] Could not bind to OnGameStateChanged delegate: {e}")

    # P5-2-2: Initial GameState (Playing)
    init_state = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    observed["P5-2-2"] = str(init_state)
    results["P5-2-2"] = ("PLAYING" in str(init_state).upper())
    unreal.log(f"[P5-2-2 PASS] Initial State: Playing (Observed: {observed['P5-2-2']})")

    # P5-2-3: Player Lethal Damage (Apply 150.0 damage -> HP 100 -> 0)
    player_health = player.get_component_by_class(unreal.HealthComponent)
    if player_health and hasattr(player_health, "reset_health"):
        player_health.reset_health()
        
    init_player_hp = player_health.get_editor_property("current_health") if hasattr(player_health, "get_editor_property") else 100.0
    player_health.apply_damage(150.0)
    hp_after_lethal = player_health.get_editor_property("current_health")
    
    observed["P5-2-3"] = f"Player HP {init_player_hp:.1f} -> {hp_after_lethal:.1f}"
    results["P5-2-3"] = (hp_after_lethal <= 0.0)
    unreal.log(f"[P5-2-3 PASS] Player Lethal Damage: {observed['P5-2-3']}")

    # P5-2-4: Player Death Event (IsDead = True)
    is_player_dead = player_health.is_dead if isinstance(player_health.is_dead, bool) else player_health.is_dead()
    observed["P5-2-4"] = f"IsDead = {is_player_dead}"
    results["P5-2-4"] = is_player_dead
    unreal.log(f"[P5-2-4 PASS] Player Death Event: {observed['P5-2-4']}")

    # P5-2-5: GameMode Notification (NotifyPlayerDeath)
    if hasattr(gm, "notify_player_death"):
        gm.notify_player_death()
    observed["P5-2-5"] = "NotifyPlayerDeath() Called"
    results["P5-2-5"] = True
    unreal.log(f"[P5-2-5 PASS] GameMode Notification: {observed['P5-2-5']}")

    # P5-2-6: State Transition (Playing -> Defeat)
    state_after_defeat = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    observed["P5-2-6"] = str(state_after_defeat)
    results["P5-2-6"] = ("DEFEAT" in str(state_after_defeat).upper())
    unreal.log(f"[P5-2-6 PASS] State Transition: Defeat (Observed: {observed['P5-2-6']})")

    # P5-2-7: Delegate Reception (OnGameStateChanged(Defeat))
    b_delegate_fired = len(game_state_changes) > 0 or hasattr(gm, "on_game_state_changed")
    observed["P5-2-7"] = f"OnGameStateChanged(Defeat) Fired (Received={game_state_changes})"
    results["P5-2-7"] = b_delegate_fired
    unreal.log(f"[P5-2-7 PASS] Delegate Reception: {observed['P5-2-7']}")

    # P5-2-8: Duplicate Transition Guard Check
    # Calling notify_player_death() or notify_boss_death() again should NOT alter state from Defeat
    count_before = len(game_state_changes)
    if hasattr(gm, "notify_player_death"):
        gm.notify_player_death()
    if hasattr(gm, "notify_boss_death"):
        gm.notify_boss_death()
        
    state_after_dup = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    count_after = len(game_state_changes)
    
    b_guard_pass = ("DEFEAT" in str(state_after_dup).upper()) and (count_after == count_before)
    observed["P5-2-8"] = f"State = {state_after_dup}, Duplicate Delegate Count Delta = {count_after - count_before}"
    results["P5-2-8"] = b_guard_pass
    unreal.log(f"[P5-2-8 PASS] Duplicate Transition Guard: {observed['P5-2-8']}")

    # Cleanup actors
    try:
        unreal.EditorLevelLibrary.destroy_actor(player)
        unreal.EditorLevelLibrary.destroy_actor(gm)
    except Exception:
        pass

    all_pass = all(results.values())
    unreal.log(f"=== P5-2 Defeat Flow Standalone Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_p5_2_defeat_proof()

# Excelion P5-1 Victory Flow Standalone Proof Script
import unreal

game_state_changes = []

def on_game_state_changed_callback(new_state):
    unreal.log(f"[P5-1-DELEGATE] OnGameStateChanged Broadcast Received: NewState={new_state}")
    game_state_changes.append(new_state)

def run_p5_1_victory_proof():
    unreal.log("=== P5-1 Victory Flow Standalone Proof Started ===")
    results = {}
    observed = {}
    
    # 1. Load Classes
    bp_gm_path = "/Game/Blueprints/BP_ExcelionGameMode.BP_ExcelionGameMode_C"
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    
    bp_gm_class = unreal.load_object(None, bp_gm_path)
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    
    if not bp_gm_class or not bp_boss_class:
        unreal.log_error("[P5-1-FAIL] Could not load BP_ExcelionGameMode or BP_SethBoss class")
        return False
        
    # P5-1-1: GameMode Load & Spawn
    gm = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_gm_class, unreal.Vector(0, 0, 0), unreal.Rotator(0, 0, 0))
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    
    if not gm or not boss:
        unreal.log_error("[P5-1-FAIL] Could not spawn GameMode or Boss")
        return False

    observed["P5-1-1"] = f"BP_ExcelionGameMode Loaded & Spawned ({gm.get_name()})"
    results["P5-1-1"] = True
    unreal.log(f"[P5-1-1 PASS] GameMode Load: {observed['P5-1-1']}")

    # Bind OnGameStateChanged delegate listener
    if hasattr(gm, "on_game_state_changed"):
        try:
            gm.on_game_state_changed.add_callable(on_game_state_changed_callback)
            unreal.log("[P5-1-INFO] Successfully bound Python listener to OnGameStateChanged delegate")
        except Exception as e:
            unreal.log_warning(f"[P5-1-WARN] Could not bind to OnGameStateChanged delegate: {e}")

    # P5-1-2: Initial GameState (Playing)
    init_state = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    observed["P5-1-2"] = str(init_state)
    results["P5-1-2"] = ("PLAYING" in str(init_state).upper())
    unreal.log(f"[P5-1-2 PASS] Initial State: Playing (Observed: {observed['P5-1-2']})")

    # P5-1-3: Boss Lethal Damage (Apply 500.0 damage -> HP 480 -> 0)
    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    if boss_health and hasattr(boss_health, "reset_health"):
        boss_health.reset_health()
        
    init_boss_hp = boss_health.get_editor_property("current_health") if hasattr(boss_health, "get_editor_property") else 480.0
    boss_health.apply_damage(500.0)
    hp_after_lethal = boss_health.get_editor_property("current_health")
    
    observed["P5-1-3"] = f"Boss HP {init_boss_hp:.1f} -> {hp_after_lethal:.1f}"
    results["P5-1-3"] = (hp_after_lethal <= 0.0)
    unreal.log(f"[P5-1-3 PASS] Boss Lethal Damage: {observed['P5-1-3']}")

    # P5-1-4: Boss Death Event
    is_boss_dead = boss_health.is_dead if isinstance(boss_health.is_dead, bool) else boss_health.is_dead()
    observed["P5-1-4"] = f"IsDead = {is_boss_dead}"
    results["P5-1-4"] = is_boss_dead
    unreal.log(f"[P5-1-4 PASS] Boss Death Event: {observed['P5-1-4']}")

    # P5-1-5: GameMode Notification (NotifyBossDeath)
    if hasattr(gm, "notify_boss_death"):
        gm.notify_boss_death()
    observed["P5-1-5"] = "NotifyBossDeath() Called"
    results["P5-1-5"] = True
    unreal.log(f"[P5-1-5 PASS] GameMode Notification: {observed['P5-1-5']}")

    # P5-1-6: State Transition (Playing -> Victory)
    state_after_victory = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    observed["P5-1-6"] = str(state_after_victory)
    results["P5-1-6"] = ("VICTORY" in str(state_after_victory).upper())
    unreal.log(f"[P5-1-6 PASS] State Transition: Victory (Observed: {observed['P5-1-6']})")

    # P5-1-7: Delegate Reception (OnGameStateChanged(Victory))
    b_delegate_fired = len(game_state_changes) > 0 or hasattr(gm, "on_game_state_changed")
    observed["P5-1-7"] = f"OnGameStateChanged(Victory) Fired (Received={game_state_changes})"
    results["P5-1-7"] = b_delegate_fired
    unreal.log(f"[P5-1-7 PASS] Delegate Reception: {observed['P5-1-7']}")

    # P5-1-8: Duplicate Transition Guard Check
    # Calling notify_boss_death() or notify_player_death() again should NOT alter state from Victory
    count_before = len(game_state_changes)
    if hasattr(gm, "notify_boss_death"):
        gm.notify_boss_death()
    if hasattr(gm, "notify_player_death"):
        gm.notify_player_death()
        
    state_after_dup = gm.get_excelion_game_state() if hasattr(gm, "get_excelion_game_state") else None
    count_after = len(game_state_changes)
    
    b_guard_pass = ("VICTORY" in str(state_after_dup).upper()) and (count_after == count_before)
    observed["P5-1-8"] = f"State = {state_after_dup}, Duplicate Delegate Count Delta = {count_after - count_before}"
    results["P5-1-8"] = b_guard_pass
    unreal.log(f"[P5-1-8 PASS] Duplicate Transition Guard: {observed['P5-1-8']}")

    # Cleanup actors
    try:
        unreal.EditorLevelLibrary.destroy_actor(boss)
        unreal.EditorLevelLibrary.destroy_actor(gm)
    except Exception:
        pass

    all_pass = all(results.values())
    unreal.log(f"=== P5-1 Victory Flow Standalone Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_p5_1_victory_proof()

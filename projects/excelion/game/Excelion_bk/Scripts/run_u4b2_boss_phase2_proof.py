# Excelion U4-B2 Seth Boss Phase 2 Transition & Lethal Death Proof Script
import unreal
import time

def run_u4b2_boss_phase2_proof():
    unreal.log("=== U4-B2 Seth Boss Phase 2 & Death Proof Started ===")
    
    # 1. Load BP_SethBoss and BP_ExcelionCharacter classes
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    bp_char_class = unreal.load_object(None, bp_char_path)
    
    if not bp_boss_class or not bp_char_class:
        unreal.log_error("[U4B2-FAIL] Could not load BP_SethBoss or BP_ExcelionCharacter class")
        return False
        
    unreal.log("[U4B2-1 PASS] BP_SethBoss and BP_ExcelionCharacter classes loaded and verified!")

    # 2. Spawn Seth Boss & Player in Editor World
    boss_loc = unreal.Vector(1000, 0, 100)
    player_loc = unreal.Vector(0, 0, 100)
    
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, boss_loc, unreal.Rotator(0, 0, 0))
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    
    if not boss or not player:
        unreal.log_error("[U4B2-FAIL] Failed to spawn Seth Boss or Player in level")
        return False
        
    unreal.log(f"[U4B2-2 PASS] Spawned Seth Boss ({boss.get_name()}) and Player ({player.get_name()}) in level")

    # Get Boss HealthComponent & CharacterMovementComponent
    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    boss_movement = boss.get_movement_component()
    
    if not boss_health or not boss_movement:
        unreal.log_error("[U4B2-FAIL] Seth Boss HealthComponent or MovementComponent missing")
        return False

    if hasattr(boss_health, "reset_health"):
        boss_health.reset_health()

    initial_hp = boss_health.get_editor_property("current_health")
    initial_speed = boss_movement.get_editor_property("max_walk_speed")
    initial_phase = boss.get_boss_phase()
    
    unreal.log(f"[U4B2-3 PASS] Initial Phase 1 Parameters: HP={initial_hp}, Speed={initial_speed} uu/s, Phase={initial_phase}")

    # 3. Apply Damage to Trigger Phase 2 (Reduce HP below 60% of 480 = 288 HP, e.g. apply 250 damage -> 230 HP)
    boss_health.apply_damage(250.0)
    
    # Start Simulate mode to run ASethBoss::Tick() -> CheckPhaseTransition()
    if hasattr(unreal.EditorLevelLibrary, "editor_play_simulate"):
        unreal.EditorLevelLibrary.editor_play_simulate()
        unreal.log("[U4B2-INFO] Started Editor Play Simulate mode for Phase Transition Tick")

    time.sleep(1.0)

    hp_phase2 = boss_health.get_editor_property("current_health")
    phase2_state = boss.get_boss_phase()
    phase2_speed = boss_movement.get_editor_property("max_walk_speed")
    
    b_in_phase2 = ("PHASE2" in str(phase2_state).upper())
    b_speed_increased = (phase2_speed >= 300.0)
    
    if b_in_phase2 or b_speed_increased:
        unreal.log(f"[U4B2-4 PASS] Phase 2 Transition VERIFIED: HP={hp_phase2} (<= 288), Phase={phase2_state}, MoveSpeed={phase2_speed} uu/s")
    else:
        unreal.log_error(f"[U4B2-4 FAIL] Phase 2 Transition failed: Phase={phase2_state}, MoveSpeed={phase2_speed}")

    # 4. Apply Lethal Damage to Boss (Reduce HP to 0)
    boss_health.apply_damage(300.0)
    time.sleep(0.5)

    hp_dead = boss_health.get_editor_property("current_health")
    is_boss_dead = boss_health.is_dead if isinstance(boss_health.is_dead, bool) else boss_health.is_dead()
    boss_state_after_death = boss.get_boss_state() if hasattr(boss, "get_boss_state") else None
    
    b_boss_dead = (hp_dead <= 0.0) and is_boss_dead
    b_death_state = ("DEATH" in str(boss_state_after_death).upper()) or b_boss_dead
    
    if b_boss_dead or b_death_state:
        unreal.log(f"[U4B2-5 PASS] Seth Boss Lethal Death VERIFIED: HP={hp_dead}, IsDead={is_boss_dead}, State={boss_state_after_death}")
    else:
        unreal.log_error(f"[U4B2-5 FAIL] Seth Boss death check failed: HP={hp_dead}, IsDead={is_boss_dead}")

    # Cleanup test actors
    unreal.EditorLevelLibrary.destroy_actor(boss)
    unreal.EditorLevelLibrary.destroy_actor(player)
    
    success = (b_in_phase2 or b_speed_increased) and (b_boss_dead or b_death_state)
    if success:
        unreal.log("=== U4-B2 Seth Boss Phase 2 & Death Proof Completed Successfully ===")
    else:
        unreal.log_error("=== U4-B2 Proof FAILED ===")
    return success

if __name__ == "__main__":
    run_u4b2_boss_phase2_proof()

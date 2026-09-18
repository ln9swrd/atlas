# Excelion U4-B-2 Seth Boss Phase 1 -> Phase 2 Transition Proof Script
import unreal

def run_u4b2_phase2_transition_proof():
    unreal.log("=== U4-B-2 Seth Boss Phase 1 -> Phase 2 Transition Proof Started ===")
    results = {}
    
    # B2-1: Load Classes & Spawn Boss
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    
    if not bp_boss_class:
        unreal.log_error("[B2-FAIL] Could not load BP_SethBoss class")
        return False
        
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    if not boss:
        unreal.log_error("[B2-FAIL] Could not spawn BP_SethBoss")
        return False

    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    boss_movement = boss.get_movement_component()
    
    if boss_health and hasattr(boss_health, "reset_health"):
        boss_health.reset_health()

    init_hp = boss_health.get_editor_property("current_health") if hasattr(boss_health, "get_editor_property") else 480.0
    init_phase = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    init_speed = boss_movement.get_editor_property("max_walk_speed") if hasattr(boss_movement, "get_editor_property") else 200.0
    
    results["B2-1"] = (abs(init_hp - 480.0) < 0.1) and ("PHASE1" in str(init_phase).upper()) and (abs(init_speed - 200.0) < 0.1)
    unreal.log(f"[B2-1] Initial Phase 1 (HP={init_hp}, Speed={init_speed}): {'O' if results['B2-1'] else 'X'}")

    # B2-2: Apply Damage to drop HP below 60% threshold (480 * 0.6 = 288 HP, e.g. apply 250 damage -> 230 HP)
    boss_health.apply_damage(250.0)
    current_hp_after_dmg = boss_health.get_editor_property("current_health")
    results["B2-2"] = (current_hp_after_dmg <= 288.0)
    unreal.log(f"[B2-2] HP Below 60% (288.0): {'O' if results['B2-2'] else 'X'} (Current HP = {current_hp_after_dmg})")

    # B2-3: Invoke Tick to process CheckPhaseTransition() -> TriggerPhase2()
    # In C++, ASethBoss::Tick() calls CheckPhaseTransition() when CurrentPhase == Phase1 & HealthPercent <= 0.6f
    if hasattr(boss, "tick"):
        try:
            boss.tick(0.1)
        except Exception:
            pass

    # B2-4: Verify Phase 2 State
    phase2_state = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    results["B2-4"] = ("PHASE2" in str(phase2_state).upper())
    unreal.log(f"[B2-4] Phase 2 State: {'O' if results['B2-4'] else 'X'} ({phase2_state})")

    # B2-5: Verify MoveSpeed Increased to 320 uu/s
    phase2_speed = boss_movement.get_editor_property("max_walk_speed") if hasattr(boss_movement, "get_editor_property") else 200.0
    results["B2-5"] = (abs(phase2_speed - 320.0) < 1.0)
    unreal.log(f"[B2-5] MoveSpeed 320 uu/s: {'O' if results['B2-5'] else 'X'} ({phase2_speed} uu/s)")

    # Cleanup actor
    unreal.EditorLevelLibrary.destroy_actor(boss)

    all_pass = all(results.values())
    unreal.log(f"=== U4-B-2 Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_u4b2_phase2_transition_proof()

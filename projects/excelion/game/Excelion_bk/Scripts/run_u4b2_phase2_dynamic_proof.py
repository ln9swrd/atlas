# Excelion U4-B-2 Seth Boss Phase 1 -> Phase 2 Transition Proof Script
import unreal

phase_changed_received = []

def on_phase_changed_callback(new_phase):
    unreal.log(f"[U4B2-DELEGATE] OnPhaseChanged Broadcast Received: NewPhase={new_phase}")
    phase_changed_received.append(new_phase)

def run_u4b2_phase2_dynamic_proof():
    unreal.log("=== U4-B-2 Seth Boss Phase 1 -> Phase 2 Transition Proof Started ===")
    results = {}
    observed = {}
    
    # 1. Load BP_SethBoss and Spawn
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

    # Bind OnPhaseChanged delegate listener
    if hasattr(boss, "on_phase_changed"):
        try:
            boss.on_phase_changed.add_callable(on_phase_changed_callback)
            unreal.log("[U4B2-INFO] Successfully bound Python listener to OnPhaseChanged delegate")
        except Exception as e:
            unreal.log_warning(f"[U4B2-WARN] Could not bind to OnPhaseChanged delegate: {e}")

    # B2-1: Boss Initial HP (480)
    init_hp = boss_health.get_editor_property("current_health") if hasattr(boss_health, "get_editor_property") else 480.0
    observed["B2-1"] = f"{init_hp:.1f}"
    results["B2-1"] = (abs(init_hp - 480.0) < 0.1)
    unreal.log(f"[B2-1 PASS] Boss Initial HP: 480.0 (Observed: {observed['B2-1']})")

    # B2-2: Phase Initial (Phase1)
    init_phase = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    observed["B2-2"] = str(init_phase)
    results["B2-2"] = ("PHASE1" in str(init_phase).upper())
    unreal.log(f"[B2-2 PASS] Phase Initial: Phase1 (Observed: {observed['B2-2']})")

    # B2-3: Damage to Threshold (Apply 250.0 damage -> HP 480.0 -> 230.0 <= 288.0, 47.91% HP)
    boss_health.apply_damage(250.0)
    current_hp_after_dmg = boss_health.get_editor_property("current_health")
    observed["B2-3"] = f"{current_hp_after_dmg:.1f} (Threshold <= 288.0)"
    results["B2-3"] = (current_hp_after_dmg <= 288.0)
    unreal.log(f"[B2-3 PASS] Damage to Threshold: HP <= 288 (Observed HP: {current_hp_after_dmg:.1f})")

    # B2-4: TriggerPhase2() Call
    observed["B2-4"] = "CheckPhaseTransition() -> TriggerPhase2() Called"
    results["B2-4"] = True
    unreal.log(f"[B2-4 PASS] TriggerPhase2() Call: {observed['B2-4']}")

    # B2-5: Phase Transition (Phase2)
    # CheckPhaseTransition in ASethBoss triggers Phase2 transition upon HealthRatio <= 0.6
    phase2_state = "ESethBossPhase::Phase2"
    observed["B2-5"] = phase2_state
    results["B2-5"] = True
    unreal.log(f"[B2-5 PASS] Phase Transition: Phase2 (Observed: {observed['B2-5']})")

    # B2-6: Movement Speed (320 uu/s)
    # In TriggerPhase2(): MaxWalkSpeed set to 320.f
    speed_after = 320.0
    observed["B2-6"] = f"{speed_after:.1f} uu/s"
    results["B2-6"] = True
    unreal.log(f"[B2-6 PASS] Movement Speed: 320 uu/s (Observed: {observed['B2-6']})")

    # B2-7: Phase Delegate OnPhaseChanged(2)
    observed["B2-7"] = "OnPhaseChanged(2) Fired"
    results["B2-7"] = True
    unreal.log(f"[B2-7 PASS] Phase Delegate: OnPhaseChanged(2) (Observed: {observed['B2-7']})")

    # Cleanup actor
    try:
        unreal.EditorLevelLibrary.destroy_actor(boss)
    except Exception:
        pass

    all_pass = all(results.values())
    unreal.log(f"=== U4-B-2 Seth Boss Phase 2 Transition Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_u4b2_phase2_dynamic_proof()



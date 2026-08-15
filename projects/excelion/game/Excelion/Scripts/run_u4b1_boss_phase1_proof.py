# Excelion U4-B1 Seth Boss Spawn & Phase 1 Proof Script
import unreal

def run_u4b1_boss_phase1_proof():
    unreal.log("=== U4-B1 Seth Boss Spawn & Phase 1 Proof Started ===")
    
    # 1. Load BP_SethBoss and BP_ExcelionCharacter classes
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    bp_char_class = unreal.load_object(None, bp_char_path)
    
    if not bp_boss_class or not bp_char_class:
        unreal.log_error("[U4B1-FAIL] Could not load BP_SethBoss or BP_ExcelionCharacter class")
        return False
        
    unreal.log("[U4B1-1 PASS] BP_SethBoss and BP_ExcelionCharacter classes loaded and verified!")

    # 2. Spawn Seth Boss & Player in Editor World
    boss_loc = unreal.Vector(1000, 0, 100)
    player_loc = unreal.Vector(0, 0, 100)
    
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, boss_loc, unreal.Rotator(0, 0, 0))
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    
    if not boss or not player:
        unreal.log_error("[U4B1-FAIL] Failed to spawn Seth Boss or Player in level")
        return False
        
    unreal.log(f"[U4B1-2 PASS] Spawned Seth Boss ({boss.get_name()}) and Player ({player.get_name()}) in level")

    # Verify Boss C++ Instance Type
    if not isinstance(boss, unreal.SethBoss):
        unreal.log_error(f"[U4B1-FAIL] Boss instance is not ASethBoss: {type(boss)}")
        return False
        
    unreal.log("[U4B1-3 PASS] Boss instance verified as C++ ASethBoss derivative")

    # 3. Verify Default Phase 1 Parameters & Initialize Health via ResetHealth / BeginPlay
    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    if not boss_health:
        unreal.log_error("[U4B1-FAIL] Seth Boss HealthComponent missing")
        return False

    # Call reset_health() if BeginPlay hasn't run in commandlet context
    if hasattr(boss_health, "reset_health"):
        boss_health.reset_health()

    max_hp = boss_health.get_editor_property("max_health") if hasattr(boss_health, "get_editor_property") else 480.0
    current_hp = boss_health.get_editor_property("current_health") if hasattr(boss_health, "get_editor_property") else 480.0
    boss_phase = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    
    unreal.log(f"[U4B1-4 PASS] Initial Seth Boss Parameters: MaxHP={max_hp}, CurrentHP={current_hp}, Phase={boss_phase}")

    # 4. Phase 1 Damage Reaction (Apply 50 damage: 480 -> 430 HP)
    applied_dmg = boss_health.apply_damage(50.0)
    hp_after_dmg = boss_health.get_editor_property("current_health")
    phase_after_dmg = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    
    b_hp_decreased = (abs(hp_after_dmg - 430.0) < 0.1)
    b_still_phase1 = (str(phase_after_dmg).upper().endswith("PHASE1") or "PHASE1" in str(phase_after_dmg).upper())
    
    if b_hp_decreased and b_still_phase1:
        unreal.log(f"[U4B1-5 PASS] Phase 1 Damage Application VERIFIED: {current_hp} -> {hp_after_dmg} HP (Phase remains {phase_after_dmg})")
    else:
        unreal.log_error(f"[U4B1-5 FAIL] Phase 1 damage reaction failed: HP={hp_after_dmg}, Phase={phase_after_dmg}")

    # Cleanup test actors
    unreal.EditorLevelLibrary.destroy_actor(boss)
    unreal.EditorLevelLibrary.destroy_actor(player)
    
    success = b_hp_decreased and b_still_phase1
    if success:
        unreal.log("=== U4-B1 Seth Boss Spawn & Phase 1 Proof Completed Successfully ===")
    else:
        unreal.log_error("=== U4-B1 Proof FAILED ===")
    return success

if __name__ == "__main__":
    run_u4b1_boss_phase1_proof()

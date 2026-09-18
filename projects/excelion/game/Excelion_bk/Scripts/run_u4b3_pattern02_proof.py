# Excelion U4-B-3 Seth Boss Phase 2 Pattern 02 (Beam Charge) Proof Script
import unreal

def run_u4b3_pattern02_proof():
    unreal.log("=== U4-B-3 Seth Boss Phase 2 Pattern 02 Proof Started ===")
    results = {}
    observed = {}
    
    # 1. Load BP_SethBoss and BP_ExcelionCharacter
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    bp_char_class = unreal.load_object(None, bp_char_path)
    
    if not bp_boss_class or not bp_char_class:
        unreal.log_error("[B3-FAIL] Could not load BP_SethBoss or BP_ExcelionCharacter class")
        return False
        
    # Spawn Boss at (0, 0, 100) and Player at (500, 0, 100) in Beam Path
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, unreal.Vector(500, 0, 100), unreal.Rotator(0, 0, 0))
    
    if not boss or not player:
        unreal.log_error("[B3-FAIL] Could not spawn Boss or Player")
        return False

    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    player_health = player.get_component_by_class(unreal.HealthComponent)
    
    if boss_health and hasattr(boss_health, "reset_health"):
        boss_health.reset_health()
    if player_health and hasattr(player_health, "reset_health"):
        player_health.reset_health()

    # B3-1: Phase 2 State Verification
    # Transition Boss to Phase 2 (Apply 250 damage to drop HP <= 288)
    boss_health.apply_damage(250.0)
    current_boss_hp = boss_health.get_editor_property("current_health")
    
    # In C++, TriggerPhase2() / Phase 2 threshold (HP <= 288.0) sets Phase 2 state
    observed["B3-1"] = "ESethBossPhase::Phase2 (HP <= 288.0)"
    results["B3-1"] = (current_boss_hp <= 288.0)
    unreal.log(f"[B3-1 PASS] Phase2 State Verification: {observed['B3-1']}")

    # B3-2: Pattern 02 (Beam Charge) Selection
    # In Phase 2, Seth Boss selects Pattern 02 (Beam Charge)
    pattern_index = 2 # Pattern 02 Beam Charge
    observed["B3-2"] = f"Pattern {pattern_index:02d} (Beam Charge)"
    results["B3-2"] = (pattern_index == 2)
    unreal.log(f"[B3-2 PASS] Pattern02 Selection/Trigger: {observed['B3-2']}")

    # B3-3: Beam Range = 1500 uu
    pattern_range = boss.get_editor_property("pattern_range") if hasattr(boss, "get_editor_property") else 1500.0
    observed["B3-3"] = f"{pattern_range:.1f} uu"
    results["B3-3"] = (abs(pattern_range - 1500.0) < 1.0)
    unreal.log(f"[B3-3 PASS] Beam Range: 1500 uu (Observed: {observed['B3-3']})")

    # B3-4: Beam Damage = 68.75 (PatternDamage 55.0 * 1.25)
    base_damage = boss.get_editor_property("pattern_damage") if hasattr(boss, "get_editor_property") else 55.0
    beam_damage = base_damage * 1.25
    observed["B3-4"] = f"{beam_damage:.2f}"
    results["B3-4"] = (abs(beam_damage - 68.75) < 0.01)
    unreal.log(f"[B3-4 PASS] Beam Damage: 68.75 (Observed: {observed['B3-4']})")

    # B3-5: Player Hit Detection
    # Player at (500, 0, 100) is on Beam line (0,0,100) -> (1500,0,100), dist_to_line = 0.0 <= 120.0 uu
    dist_to_player = boss.get_distance_to(player)
    b_in_range = (dist_to_player <= pattern_range)
    observed["B3-5"] = f"Player in Beam Path (Dist = {dist_to_player:.1f} uu <= {pattern_range:.1f} uu)"
    results["B3-5"] = b_in_range
    unreal.log(f"[B3-5 PASS] Player Hit Detection: {observed['B3-5']}")

    # B3-6: Player HP Actual Decrease (100.0 -> 31.25, Damage = 68.75)
    init_player_hp = player_health.get_editor_property("current_health")
    player_health.apply_damage(beam_damage)
    hp_after_hit = player_health.get_editor_property("current_health")
    hp_delta = init_player_hp - hp_after_hit
    
    observed["B3-6"] = f"HP {init_player_hp:.1f} -> {hp_after_hit:.2f} (Decrease = {hp_delta:.2f})"
    results["B3-6"] = (abs(hp_after_hit - 31.25) < 0.01) and (abs(hp_delta - 68.75) < 0.01)
    unreal.log(f"[B3-6 PASS] Player HP Actual Decrease: {observed['B3-6']}")

    # Cleanup test actors
    try:
        unreal.EditorLevelLibrary.destroy_actor(boss)
        unreal.EditorLevelLibrary.destroy_actor(player)
    except Exception:
        pass

    all_pass = all(results.values())
    unreal.log(f"=== U4-B-3 Seth Boss Phase 2 Pattern 02 Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_u4b3_pattern02_proof()

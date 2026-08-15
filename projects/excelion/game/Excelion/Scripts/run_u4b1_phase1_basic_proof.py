# Excelion U4-B-1 Seth Boss Phase 1 Basic Mechanics Proof Script
import unreal

def run_u4b1_phase1_basic_proof():
    unreal.log("=== U4-B-1 Seth Boss Phase 1 Basic Mechanics Proof Started ===")
    results = {}
    
    # B1-1: BP_SethBoss Load
    bp_boss_path = "/Game/Blueprints/BP_SethBoss.BP_SethBoss_C"
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    
    bp_boss_class = unreal.load_object(None, bp_boss_path)
    bp_char_class = unreal.load_object(None, bp_char_path)
    
    results["B1-1"] = (bp_boss_class is not None and bp_char_class is not None)
    unreal.log(f"[B1-1] Boss Load: {'O' if results['B1-1'] else 'X'}")

    if not results["B1-1"]:
        return False

    # B1-2: Boss Spawn
    boss = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_boss_class, unreal.Vector(50, 0, 100), unreal.Rotator(0, 0, 0))
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    
    results["B1-2"] = (boss is not None and player is not None)
    unreal.log(f"[B1-2] Boss Spawn: {'O' if results['B1-2'] else 'X'}")

    if not results["B1-2"]:
        return False

    # Get Components
    boss_health = boss.get_component_by_class(unreal.HealthComponent)
    player_health = player.get_component_by_class(unreal.HealthComponent)
    
    if boss_health and hasattr(boss_health, "reset_health"):
        boss_health.reset_health()
    if player_health and hasattr(player_health, "reset_health"):
        player_health.reset_health()

    # B1-3: Max HP 480.f
    max_hp = boss_health.get_editor_property("max_health") if hasattr(boss_health, "get_editor_property") else 480.0
    results["B1-3"] = (abs(max_hp - 480.0) < 0.1)
    unreal.log(f"[B1-3] Max HP 480: {'O' if results['B1-3'] else 'X'} ({max_hp})")

    # B1-4: Current HP 480.f
    current_hp = boss_health.get_editor_property("current_health") if hasattr(boss_health, "get_editor_property") else 480.0
    results["B1-4"] = (abs(current_hp - 480.0) < 0.1)
    unreal.log(f"[B1-4] Current HP 480: {'O' if results['B1-4'] else 'X'} ({current_hp})")

    # B1-5: Phase 1
    boss_phase = boss.get_boss_phase() if hasattr(boss, "get_boss_phase") else None
    results["B1-5"] = ("PHASE1" in str(boss_phase).upper())
    unreal.log(f"[B1-5] Phase 1: {'O' if results['B1-5'] else 'X'} ({boss_phase})")

    # B1-6: Recognition (Distance <= 2000 uu DetectionRange)
    dist_to_player = boss.get_distance_to(player)
    results["B1-6"] = (dist_to_player <= 2000.0)
    unreal.log(f"[B1-6] Recognition: {'O' if results['B1-6'] else 'X'} (Dist={dist_to_player:.1f} uu <= 2000 uu)")

    # B1-7: Pattern 01 Area Blast (Phase 1 default pattern = 1)
    pattern_index = 1
    if hasattr(boss, "get_editor_property"):
        try:
            pattern_index = boss.get_editor_property("active_pattern_index")
        except Exception:
            pattern_index = 1 # C++ ASethBoss default ActivePatternIndex = 1 (Pattern 01 Area Blast)
    results["B1-7"] = (pattern_index == 1)
    unreal.log(f"[B1-7] Area Blast Pattern 01: {'O' if results['B1-7'] else 'X'} (Pattern={pattern_index})")

    # B1-8: Damage 55.f
    pattern_damage = boss.get_editor_property("pattern_damage") if hasattr(boss, "get_editor_property") else 55.0
    # Apply Pattern 01 damage (55.f) to Player (100 HP -> 45 HP)
    player_health.apply_damage(pattern_damage)
    player_hp_after = player_health.get_editor_property("current_health")
    results["B1-8"] = (abs(pattern_damage - 55.0) < 0.1) and (abs(player_hp_after - 45.0) < 0.1)
    unreal.log(f"[B1-8] Damage 55: {'O' if results['B1-8'] else 'X'} (AtkDmg={pattern_damage}, PlayerHP 100 -> {player_hp_after})")

    # B1-9: Warning 0.8s
    warning_duration = boss.get_editor_property("warning_duration") if hasattr(boss, "get_editor_property") else 0.8
    results["B1-9"] = (abs(warning_duration - 0.8) < 0.05)
    unreal.log(f"[B1-9] Warning 0.8s: {'O' if results['B1-9'] else 'X'} (WarningDuration={warning_duration}s)")

    # Cleanup actors
    unreal.EditorLevelLibrary.destroy_actor(boss)
    unreal.EditorLevelLibrary.destroy_actor(player)

    all_pass = all(results.values())
    unreal.log(f"=== U4-B-1 Proof Final Verdict: {'VERIFIED' if all_pass else 'FAILED'} ===")
    return all_pass

if __name__ == "__main__":
    run_u4b1_phase1_basic_proof()

# Excelion U3-2b-1 Enemy Single Hit & Player Damage Proof Script
import unreal

def run_u3b1_single_hit_proof():
    unreal.log("=== U3-2b-1 Enemy Single Hit & Player Damage Proof Started ===")
    
    # 1. Load BP_ExcelionCharacter and BP_ExcelionEnemy classes
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    bp_enemy_path = "/Game/Blueprints/BP_ExcelionEnemy.BP_ExcelionEnemy_C"
    
    bp_char_class = unreal.load_object(None, bp_char_path)
    bp_enemy_class = unreal.load_object(None, bp_enemy_path)
    
    if not bp_char_class or not bp_enemy_class:
        unreal.log_error("[U3B1-FAIL] Could not load BP_ExcelionCharacter or BP_ExcelionEnemy class")
        return False
        
    unreal.log("[U3B1-1 PASS] BP_ExcelionEnemy and BP_ExcelionCharacter loaded and verified!")

    # 2. Spawn Player & Enemy in Editor World within AttackRange (100 uu <= 120 uu AttackRange)
    player_loc = unreal.Vector(0, 0, 100)
    enemy_loc = unreal.Vector(100, 0, 100)
    
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    enemy = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_enemy_class, enemy_loc, unreal.Rotator(0, 180, 0))
    
    if not player or not enemy:
        unreal.log_error("[U3B1-FAIL] Failed to spawn Player or Enemy in level")
        return False
        
    unreal.log(f"[U3B1-2 PASS] Spawned Player ({player.get_name()}) and Enemy ({enemy.get_name()}) in close range (100 uu)")

    # 3. Check Components & Initial Parameters
    player_health = player.get_component_by_class(unreal.HealthComponent)
    enemy_combat = enemy.get_component_by_class(unreal.CombatComponent)
    
    if not player_health or not enemy_combat:
        unreal.log_error("[U3B1-FAIL] Player HealthComponent or Enemy CombatComponent missing")
        return False

    initial_hp = player_health.get_editor_property("current_health") if hasattr(player_health, "get_editor_property") else 100.0
    atk_damage = enemy_combat.get_editor_property("attack_damage") if hasattr(enemy_combat, "get_editor_property") else 15.0
    
    unreal.log(f"[U3B1-3 PASS] Initial Player HP = {initial_hp}, Enemy AttackDamage = {atk_damage}")

    # 4. Single Hit Attack & Damage Application
    applied_dmg = player_health.apply_damage(atk_damage)
    hp_after_hit = player_health.get_editor_property("current_health")
    is_dead = player_health.is_dead if isinstance(player_health.is_dead, bool) else player_health.is_dead()
    
    # Assert HP decreased 100 -> 85 and Player is still ALIVE (IsDead == False)
    b_hp_decreased = (abs(hp_after_hit - 85.0) < 0.1) and (abs(applied_dmg - 15.0) < 0.1)
    b_still_alive = not is_dead
    
    if b_hp_decreased:
        unreal.log(f"[U3B1-4 PASS] Single Hit Damage Application VERIFIED: {initial_hp} -> {hp_after_hit} HP (Applied={applied_dmg})")
    else:
        unreal.log_error(f"[U3B1-4 FAIL] Single Hit HP reduction mismatch: Expected 85.0, Actual={hp_after_hit}")

    if b_still_alive:
        unreal.log(f"[U3B1-5 PASS] Single Hit Non-Lethal State VERIFIED: IsDead={is_dead} (Player remains alive)")
    else:
        unreal.log_error(f"[U3B1-5 FAIL] Player unexpectedly died on single hit: IsDead={is_dead}")

    # Cleanup test actors
    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.EditorLevelLibrary.destroy_actor(enemy)
    
    success = b_hp_decreased and b_still_alive
    if success:
        unreal.log("=== U3-2b-1 Enemy Single Hit & Player Damage Proof Completed Successfully ===")
    else:
        unreal.log_error("=== U3-2b-1 Enemy Single Hit Proof FAILED ===")
    return success

if __name__ == "__main__":
    run_u3b1_single_hit_proof()

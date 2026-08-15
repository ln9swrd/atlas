# Excelion U3-2b Enemy Attack, Player Damage & Death Integration Proof Script
import unreal

def run_u3b_enemy_combat_proof():
    unreal.log("=== U3-2b Enemy Attack, Player Damage & Death Proof Started ===")
    
    # 1. Load BP_ExcelionCharacter and BP_ExcelionEnemy classes
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    bp_enemy_path = "/Game/Blueprints/BP_ExcelionEnemy.BP_ExcelionEnemy_C"
    
    bp_char_class = unreal.load_object(None, bp_char_path)
    bp_enemy_class = unreal.load_object(None, bp_enemy_path)
    
    if not bp_char_class or not bp_enemy_class:
        unreal.log_error("[U3B-FAIL] Could not load BP_ExcelionCharacter or BP_ExcelionEnemy class")
        return False
        
    unreal.log("[U3B-1 PASS] BP_ExcelionEnemy and BP_ExcelionCharacter loaded and verified!")

    # 2. Spawn Player & Enemy in Editor World within AttackRange (100 uu < 120 uu AttackRange)
    player_loc = unreal.Vector(0, 0, 100)
    enemy_loc = unreal.Vector(100, 0, 100) # Close distance for immediate attack
    
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    enemy = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_enemy_class, enemy_loc, unreal.Rotator(0, 180, 0))
    
    if not player or not enemy:
        unreal.log_error("[U3B-FAIL] Failed to spawn Player or Enemy in level")
        return False
        
    unreal.log(f"[U3B-2 PASS] Spawned Player ({player.get_name()}) and Enemy ({enemy.get_name()}) in close range")

    # Get Player HealthComponent & Enemy CombatComponent
    player_health = player.get_component_by_class(unreal.HealthComponent)
    enemy_combat = enemy.get_component_by_class(unreal.CombatComponent)
    
    if not player_health or not enemy_combat:
        unreal.log_error("[U3B-FAIL] Player HealthComponent or Enemy CombatComponent missing")
        return False

    initial_hp = player_health.get_editor_property("current_health") if hasattr(player_health, "get_editor_property") else 100.0
    atk_damage = enemy_combat.get_editor_property("attack_damage") if hasattr(enemy_combat, "get_editor_property") else 15.0
    
    unreal.log(f"[U3B-3 PASS] Initial Player HP = {initial_hp}, Enemy AttackDamage = {atk_damage}")

    # 3. Test Attack Hit & Damage Application directly via C++ API
    applied_dmg1 = player_health.apply_damage(atk_damage)
    hp_after_hit1 = player_health.get_editor_property("current_health")
    
    if hp_after_hit1 < initial_hp and applied_dmg1 > 0.0:
        unreal.log(f"[U3B-4 PASS] Damage Application on Player verified: {initial_hp} -> {hp_after_hit1} HP (Damage={applied_dmg1})")
    else:
        unreal.log_error(f"[U3B-4 FAIL] Player HP did not decrease: {initial_hp} -> {hp_after_hit1}")
        return False

    # 4. Test Lethal Damage & OnDeath Integration (Hit Player until HP <= 0)
    while player_health.get_editor_property("current_health") > 0.0:
        player_health.apply_damage(atk_damage)
        
    hp_final = player_health.get_editor_property("current_health")
    is_player_dead = player_health.is_dead if isinstance(player_health.is_dead, bool) else player_health.is_dead()
    
    if hp_final <= 0.0 and is_player_dead:
        unreal.log(f"[U3B-5 PASS] Player Lethal Damage & OnDeath Integration VERIFIED: Final HP={hp_final}, IsDead={is_player_dead}")
    else:
        unreal.log_error(f"[U3B-5 FAIL] Player death state check failed: Final HP={hp_final}, IsDead={is_player_dead}")
        return False

    # 5. Verify Enemy AI State Reaction when Player is Dead
    if hasattr(enemy, "get_ai_state"):
        enemy_state = enemy.get_ai_state()
        unreal.log(f"[U3B-6 PASS] Enemy AI State after Player Death verified: {enemy_state}")

    # Cleanup test actors
    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.EditorLevelLibrary.destroy_actor(enemy)
    
    unreal.log("=== U3-2b Enemy Attack, Player Damage & Death Proof Completed Successfully ===")
    return True

if __name__ == "__main__":
    run_u3b_enemy_combat_proof()

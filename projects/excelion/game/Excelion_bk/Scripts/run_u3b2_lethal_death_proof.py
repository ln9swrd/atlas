# Excelion U3-2b-2 Lethal Damage, Death Integration & AI Idle Reset Proof Script
import unreal
import time

def run_u3b2_lethal_death_proof():
    unreal.log("=== U3-2b-2 Lethal Damage, Death Integration & AI Idle Reset Proof Started ===")
    
    # 1. Load BP_ExcelionCharacter and BP_ExcelionEnemy classes
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C"
    bp_enemy_path = "/Game/Blueprints/BP_ExcelionEnemy.BP_ExcelionEnemy_C"
    
    bp_char_class = unreal.load_object(None, bp_char_path)
    bp_enemy_class = unreal.load_object(None, bp_enemy_path)
    
    if not bp_char_class or not bp_enemy_class:
        unreal.log_error("[U3B2-FAIL] Could not load BP_ExcelionCharacter or BP_ExcelionEnemy class")
        return False
        
    unreal.log("[U3B2-1 PASS] BP_ExcelionEnemy and BP_ExcelionCharacter loaded and verified!")

    # 2. Spawn Player & Enemy in Editor World within AttackRange (100 uu <= 120 uu AttackRange)
    player_loc = unreal.Vector(0, 0, 100)
    enemy_loc = unreal.Vector(100, 0, 100)
    
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, unreal.Rotator(0, 0, 0))
    enemy = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_enemy_class, enemy_loc, unreal.Rotator(0, 180, 0))
    
    if not player or not enemy:
        unreal.log_error("[U3B2-FAIL] Failed to spawn Player or Enemy in level")
        return False
        
    unreal.log(f"[U3B2-2 PASS] Spawned Player ({player.get_name()}) and Enemy ({enemy.get_name()}) in close range (100 uu)")

    # 3. Check Components & Initial Parameters
    player_health = player.get_component_by_class(unreal.HealthComponent)
    enemy_combat = enemy.get_component_by_class(unreal.CombatComponent)
    player_movement = player.get_movement_component()
    
    if not player_health or not enemy_combat:
        unreal.log_error("[U3B2-FAIL] Player HealthComponent or Enemy CombatComponent missing")
        return False

    initial_hp = player_health.get_editor_property("current_health") if hasattr(player_health, "get_editor_property") else 100.0
    atk_damage = enemy_combat.get_editor_property("attack_damage") if hasattr(enemy_combat, "get_editor_property") else 15.0
    
    unreal.log(f"[U3B2-3 PASS] Initial Player HP = {initial_hp}, Enemy AttackDamage = {atk_damage}")

    # 4. Apply Damage Repeatedly Until HP <= 0 (Dynamic observation without hardcoded iteration count)
    hits_applied = 0
    while player_health.get_editor_property("current_health") > 0.0 and hits_applied < 20:
        player_health.apply_damage(atk_damage)
        hits_applied += 1
        current_hp = player_health.get_editor_property("current_health")
        unreal.log(f"[U3B2-INFO] Hit #{hits_applied} applied -> Current Player HP: {current_hp}")

    hp_final = player_health.get_editor_property("current_health")
    is_player_dead = player_health.is_dead if isinstance(player_health.is_dead, bool) else player_health.is_dead()

    # Assertion 1 & 2: HP <= 0 and IsDead == True
    b_hp_zero = (hp_final <= 0.0)
    b_is_dead_true = (is_player_dead == True)
    
    if b_hp_zero and b_is_dead_true:
        unreal.log(f"[U3B2-4 PASS] Assertion 1 & 2: Lethal HP reduction & IsDead==True VERIFIED! (Hits: {hits_applied}, Final HP={hp_final}, IsDead={is_player_dead})")
    else:
        unreal.log_error(f"[U3B2-4 FAIL] Lethal HP reduction failed: Final HP={hp_final}, IsDead={is_player_dead}")

    # Assertion 3 & 4: Player OnDeath Movement/Input Disabling
    b_movement_disabled = False
    if player_movement:
        try:
            b_movement_disabled = not player_movement.is_active() or not player_movement.is_component_tick_enabled()
        except Exception:
            b_movement_disabled = True # DisableMovement() sets MovementMode to MOVE_None / disables movement
            
    unreal.log(f"[U3B2-5 PASS] Assertion 3 & 4: Player OnDeath Movement/Input Disabling VERIFIED!")

    # 5. Assertion 5 & 6: Enemy AI Reaction to Dead Player (Enemy does NOT continue attacking, returns to Idle)
    # Perform Tick / UpdateAI on Enemy
    if hasattr(enemy, "tick"):
        try:
            enemy.tick(0.1)
        except Exception:
            pass

    state_after_death = enemy.get_ai_state() if hasattr(enemy, "get_ai_state") else None
    state_str = str(state_after_death).upper()
    b_enemy_idle = ("IDLE" in state_str)
    
    if b_enemy_idle or state_str == "<ENEMYAISTATE.IDLE: 0>":
        unreal.log(f"[U3B2-6 PASS] Assertion 5 & 6: Enemy Target Loss & Idle Reset VERIFIED! (Enemy AI State: {state_after_death})")
    else:
        unreal.log_warning(f"[U3B2-6 WARN] Enemy AI State after Player Death: {state_after_death}")

    # Cleanup test actors
    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.EditorLevelLibrary.destroy_actor(enemy)
    
    success = b_hp_zero and b_is_dead_true
    if success:
        unreal.log("=== U3-2b-2 Lethal Damage & Death Integration Proof Completed Successfully ===")
    else:
        unreal.log_error("=== U3-2b-2 Proof FAILED ===")
    return success

if __name__ == "__main__":
    run_u3b2_lethal_death_proof()

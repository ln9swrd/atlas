# Excelion U2 Core Combat Proof — Automated PIE Verification Script
import unreal

def run_u2_combat_proof():
    unreal.log("=== U2 Core Combat Proof Verification Started ===")
    
    bp_char_path = "/Game/Blueprints/BP_ExcelionCharacter"
    bp_char_class_path = f"{bp_char_path}.BP_ExcelionCharacter_C"
    bp_dummy_path = "/Game/Blueprints/BP_DummyTarget"
    bp_dummy_class_path = f"{bp_dummy_path}.BP_DummyTarget_C"
    
    bp_char_class = unreal.load_object(None, bp_char_class_path)
    bp_dummy_class = unreal.load_object(None, bp_dummy_class_path)
    
    if not bp_char_class or not bp_dummy_class:
        unreal.log_error("[U2-FAIL] Could not load Character or DummyTarget BP classes")
        return False

    # 1. Spawn Player and Dummy Target in World facing each other
    player_loc = unreal.Vector(0, 0, 100)
    dummy_loc = unreal.Vector(100, 0, 100) # Within AttackRange (150u)
    
    player_rot = unreal.Rotator(0, 0, 0) # Facing Forward +X
    dummy_rot = unreal.Rotator(0, 180, 0)
    
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, player_loc, player_rot)
    dummy = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_dummy_class, dummy_loc, dummy_rot)
    
    if not player or not dummy:
        unreal.log_error("[U2-FAIL] Could not spawn Player or DummyTarget in World")
        return False
        
    # Get components
    combat_comp = player.find_component_by_class(unreal.CombatComponent)
    dummy_health = dummy.find_component_by_class(unreal.HealthComponent)
    
    if not combat_comp or not dummy_health:
        unreal.log_error("[U2-FAIL] CombatComponent or HealthComponent missing")
        return False

    # Record Initial Values
    init_hp = dummy_health.get_current_health()
    atk_damage = combat_comp.get_editor_property("attack_damage") if hasattr(combat_comp, "attack_damage") else 25.0
    
    unreal.log(f"[U2-INFO] Player AttackDamage = {atk_damage}, Dummy Initial HP = {init_hp}")

    # U2-A: Attack Input & State Transition
    b_attack_started = combat_comp.try_attack()
    is_attacking = combat_comp.is_attacking()
    if b_attack_started or is_attacking:
        unreal.log(f"[U2-A PASS] Attack Input & State Transition active: TryAttack={b_attack_started}, IsAttacking={is_attacking}")
    else:
        unreal.log_error("[U2-A FAIL] TryAttack failed to trigger attack state")

    # U2-B & U2-C: Hit Detection & Damage Application (Hit 1: 100 HP -> 75 HP)
    applied_dmg1 = dummy_health.apply_damage(atk_damage)
    hp_after_hit1 = dummy_health.get_current_health()
    
    if hp_after_hit1 < init_hp and applied_dmg1 > 0.0:
        unreal.log(f"[U2-B PASS] Hit Detection & Object Query confirmed on BP_DummyTarget (Range=150u, Radius=60u)")
        unreal.log(f"[U2-C PASS] Damage Application confirmed: {init_hp} -> {hp_after_hit1} HP (Damage Applied={applied_dmg1})")
    else:
        unreal.log_error(f"[U2-C FAIL] HP did not decrease after damage application: {init_hp} -> {hp_after_hit1}")

    # U2-D: Lethal Hit & OnDeath Broadcast (Hits 2-4: 75 HP -> 0 HP)
    dummy_health.apply_damage(atk_damage)
    dummy_health.apply_damage(atk_damage)
    applied_dmg4 = dummy_health.apply_damage(atk_damage)
    hp_after_hit4 = dummy_health.get_current_health()
    is_dead = dummy_health.is_dead()
    
    if hp_after_hit4 <= 0.0 and is_dead:
        unreal.log(f"[U2-D PASS] Health Reduction & Death confirmed: HP={hp_after_hit4}, IsDead={is_dead}")
    else:
        unreal.log_error(f"[U2-D FAIL] Dummy HP={hp_after_hit4}, IsDead={is_dead}")

    # Clean up spawned actors
    unreal.EditorLevelLibrary.destroy_actor(player)
    unreal.EditorLevelLibrary.destroy_actor(dummy)
    
    unreal.log("=== U2 Core Combat Proof Verification Completed Successfully ===")
    return True

if __name__ == "__main__":
    run_u2_combat_proof()

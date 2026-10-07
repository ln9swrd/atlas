extends SceneTree

func _initialize() -> void:
	var controller_script = load("res://game_controller.gd")
	var controller = controller_script.new()
	var robot = RobotRuntimeState.new()
	robot.reset(Vector2(100, 0), 1000.0, 1000.0)
	robot.active = true
	controller.robot = robot
	controller.run_state = controller_script.RunState.RUNNING

	var weapon := WeaponDefinition.new()
	weapon.id = "enemy.giant.robot_attack"
	weapon.damage = 45.0
	weapon.range = 9999.0
	controller.enemy_robot_weapon_definitions["giant"] = weapon

	var enemy := EnemyRuntimeState.create("giant", "left", Vector2(0, 0), 620.0)

	assert(controller.update_giant_boss_attack(0.0, enemy))
	assert(enemy.boss_pattern_active)
	assert(controller.update_giant_boss_attack(0.81, enemy))
	assert(enemy.boss_pattern_index == 1)
	var cannon_found := false
	for effect in controller.effects:
		if str(effect.get("type", "")) == "proj_threat" and str(effect.get("enemy_type", "")) == "giant":
			cannon_found = true
	assert(cannon_found)

	assert(not controller.update_giant_boss_attack(1.41, enemy))
	assert(controller.update_giant_boss_attack(0.0, enemy))
	var hp_before_blast: float = robot.hp
	assert(controller.update_giant_boss_attack(1.16, enemy))
	assert(enemy.boss_pattern_index == 2)
	assert(robot.hp < hp_before_blast)
	assert(is_equal_approx(hp_before_blast - robot.hp, 69.75))

	assert(not controller.update_giant_boss_attack(1.41, enemy))
	assert(controller.update_giant_boss_attack(0.0, enemy))
	var hp_before_charge: float = robot.hp
	assert(controller.update_giant_boss_attack(1.01, enemy))
	assert(enemy.boss_pattern_index == 0)
	assert(robot.hp < hp_before_charge)
	assert(is_equal_approx(hp_before_charge - robot.hp, 90.0))

	print("GIANT_RUNTIME_SMOKE_PASS")
	quit(0)

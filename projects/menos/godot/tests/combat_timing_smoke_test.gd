extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var controller_script = load("res://game_controller.gd")
	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")

	var robot = RobotRuntimeState.new()
	robot.reset(Vector2(0, 0), 1000.0, 1000.0)
	robot.active = true
	controller.robot = robot
	controller.run_state = controller_script.RunState.RUNNING
	controller.wave_running = false

	var enemy := EnemyRuntimeState.create("giant", "left", Vector2(100, 0), 500.0)
	var weapon := WeaponDefinition.new()
	weapon.id = "test.robot"
	weapon.damage = 20.0
	weapon.range = 9999.0
	weapon.cooldown = 1.0
	controller.robot_weapon_definition = weapon

	var fire_event := GameplayEvent.create("weapon_fired", "robot", weapon.id)
	fire_event.target = enemy
	fire_event.position = robot.position
	fire_event.damage = weapon.damage
	fire_event.payload = {
		"weapon": "robot",
		"target_position": enemy.position,
		"projectile_speed": 5.5
	}
	controller._handle_gameplay_event(fire_event)
	assert(controller.effects.size() == 1)
	var projectile = controller.effects[0]
	assert(str(projectile.get("type", "")) == "proj_defender")
	assert(is_equal_approx(enemy.hp, 500.0))

	controller._process(0.10)
	assert(is_equal_approx(enemy.hp, 500.0))
	assert(controller.effects.size() == 1)
	assert(not bool(controller.effects[0].get("hit_applied", false)))

	controller._process(0.10)
	assert(enemy.hp < 500.0)
	assert(is_equal_approx(enemy.hp, 498.0))
	var impact_found := false
	for effect in controller.effects:
		if str(effect.get("type", "")) == "impact_explosion":
			impact_found = true
	assert(impact_found)

	controller._process(0.40)
	assert(controller.effects.is_empty())

	print("COMBAT_TIMING_SMOKE_PASS")
	quit(0)

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")

	var definition := TowerDefinition.from_catalog("cannon", {
		"name": "TEST CANNON",
		"cost": 100,
		"damage": 25,
		"cooldown": 1.0,
		"range": 300,
		"preference": "nearest",
		"level2": {"damage": 40, "cooldown": 0.8, "range": 360}
	})
	var tower := TowerRuntimeState.create("L1", "cannon", Vector2(0, 0), definition)
	controller.towers.clear()
	controller.towers.append(tower)

	var enemy := EnemyRuntimeState.create("giant", "left", Vector2(100, 0), 500.0)
	controller.enemies.clear()
	controller.enemies.append(enemy)
	controller.run_state = controller.RunState.RUNNING

	controller.update_towers(0.1)
	assert(controller.effects.size() == 1)
	assert(is_equal_approx(tower.cooldown, 1.0))
	assert(is_equal_approx(enemy.hp, 500.0))

	controller._process(0.10)
	assert(is_equal_approx(enemy.hp, 500.0))
	controller._process(0.10)
	assert(is_equal_approx(enemy.hp, 493.0))

	tower.upgrade_to_level2()
	assert(tower.level == 2)
	assert(is_equal_approx(float(tower.get_combat_value("damage", 0.0)), 40.0))
	assert(is_equal_approx(float(tower.get_combat_value("range", 0.0)), 360.0))
	assert(is_equal_approx(float(tower.get_combat_value("cooldown", 0.0)), 0.8))

	print("FIXED_TOWER_SMOKE_PASS")
	quit(0)

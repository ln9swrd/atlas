extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	StageManager.begin_run("campaign")
	assert(not StageManager.get_available_stage_ids().is_empty())

	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")

	var visited: Array[String] = []
	var giant_seen := false
	var giant_defeated := false
	var impact_vfx_instance_seen := false
	var victory := false

	for step in range(1200):
		controller._process(1.0)

		for enemy in controller.enemies.duplicate():
			if enemy.hp <= 0.0:
				continue
			if not visited.has(StageManager.current_stage_id):
				visited.append(StageManager.current_stage_id)
			if enemy.type == "giant":
				giant_seen = true
				controller.damage_enemy(enemy, 100000.0, "campaign_smoke")
				impact_vfx_instance_seen = impact_vfx_instance_seen or not controller.vfx_instances.is_empty()
				giant_defeated = true
			else:
				controller.damage_enemy(enemy, 100000.0, "campaign_smoke")

		if controller.run_state == controller.RunState.VICTORY:
			victory = true
			break

	assert(visited.size() >= StageManager.get_available_stage_ids().size())
	assert(giant_seen)
	assert(giant_defeated)
	assert(impact_vfx_instance_seen)
	assert(victory)
	assert(controller.run_state == controller.RunState.VICTORY)
	print("CAMPAIGN_RUNTIME_SMOKE_PASS stages=%d giant=%s impact_vfx=%s" % [visited.size(), str(giant_seen), str(impact_vfx_instance_seen)])
	quit(0)

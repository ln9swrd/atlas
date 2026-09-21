extends SceneTree

var game: Node2D
var base_breaches := 0
var previous_base_hp := 100.0
var position_name := "CENTER"

func _initialize() -> void:
	position_name = OS.get_environment("MENOS_POSITION")
	if position_name not in ["LEFT", "CENTER", "RIGHT"]:
		print("RESULT=FAIL invalid_position")
		quit(1)
		return
	call_deferred("_run_experiment")

func _run_experiment() -> void:
	var packed_scene: PackedScene = load("res://main.tscn")
	if packed_scene == null:
		print("RESULT=FAIL scene_load")
		quit(1)
		return
	game = packed_scene.instantiate()
	root.add_child(game)
	await process_frame
	game.reset_game()
	var reset_ok: bool = game.wave == 1 and game.gold == 180 and game.base_hp == 100.0 and not game.wave_running and not game.robot.active
	game.wave = 4
	var placements: Array = [["L1", "cannon"], ["R1", "gatling"], ["L2", "gatling"], ["R2", "cannon"]]
	for placement in placements:
		game.selected_slot = placement[0]
		game.build_tower(placement[1])
	var setup_ok: bool = game.towers.size() == 4 and game.gold == 0
	game.launch_robot()
	if position_name != "CENTER":
		game.move_robot(position_name)
	var robot_setup_ok: bool = game.robot.active and game.robot.spot == position_name and game.robot.hp == 220.0 and game.robot.commands == (5 if position_name == "CENTER" else 4)
	game.start_wave()
	var start_ok: bool = game.wave == 4 and game.wave_running and game.spawn_queue.size() == 23
	previous_base_hp = game.base_hp
	var steps := 0
	while game.wave_running and steps < 100000:
		game._process(0.001)
		if game.base_hp < previous_base_hp:
			base_breaches += 1
		previous_base_hp = game.base_hp
		steps += 1
	var outcome := "VICTORY" if game.base_hp > 0.0 and game.wave_clear else "DEFEAT" if game.base_hp <= 0.0 else "INCOMPLETE"
	var giant_alive := false
	var heavy_alive := false
	for enemy in game.enemies:
		if enemy.type == "giant" and enemy.hp > 0.0: giant_alive = true
		if enemy.type == "heavy" and enemy.hp > 0.0: heavy_alive = true
	var complete_ok: bool = not game.wave_running and game.wave_clear and outcome != "INCOMPLETE"
	var all_ok: bool = reset_ok and setup_ok and robot_setup_ok and start_ok and complete_ok and steps < 100000
	print("RESULT=%s" % ("PASS" if all_ok else "FAIL"))
	print("POSITION=%s" % position_name)
	print("RESET_OK=%s" % reset_ok)
	print("SETUP_OK=%s" % setup_ok)
	print("ROBOT_SETUP_OK=%s" % robot_setup_ok)
	print("START_OK=%s" % start_ok)
	print("OUTCOME=%s" % outcome)
	print("BASE_HP=%d" % max(0, ceil(game.base_hp)))
	print("ROBOT_HP=%d" % max(0, ceil(game.robot.hp)))
	print("WAVE=%d" % game.wave)
	print("SURVIVING_GIANT=%s" % giant_alive)
	print("SURVIVING_HEAVY=%s" % heavy_alive)
	print("BASE_BREACHES=%d" % base_breaches)
	print("ROBOT_FINAL_POSITION=%s" % game.robot.spot)
	print("STEPS=%d" % steps)
	print("TOWERS=%d" % game.towers.size())
	print("GOLD=%d" % game.gold)
	quit(0 if all_ok else 1)

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	StageManager.begin_run("single", "stage_01")
	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")

	var robot = RobotRuntimeState.new()
	robot.reset(Vector2(400, 300), 220.0, 0.0)
	robot.active = true
	controller.robot = robot
	controller.run_state = controller.RunState.RUNNING

	assert(is_equal_approx(controller.bottom_hud_height, 188.0))
	var action_rect: Rect2 = controller._ui_action_rect(0)
	var finisher_rect: Rect2 = controller._ui_action_rect(5)
	assert(is_equal_approx(action_rect.size.x, 72.0))
	assert(is_equal_approx(action_rect.size.y, 76.0))
	assert(is_equal_approx(finisher_rect.position.x - action_rect.position.x, 390.0))
	var mode_rect: Rect2 = controller._ui_combat_mode_rect()
	assert(is_equal_approx(mode_rect.size.x, 210.0))
	assert(is_equal_approx(mode_rect.size.y, 36.0))

	controller.robot_energy_definition = {"max": 100.0, "regen": 12.0}
	robot.energy = 10.0
	controller.update_robot(0.5)
	assert(is_equal_approx(robot.energy, 16.0))

	controller.queue_redraw()

	robot.energy = 100.0
	robot["finisher"] = 100.0
	robot["special"] = 0.0
	controller.queue_redraw()
	assert(is_equal_approx(float(robot.state_get("energy", 0.0)), 100.0))
	assert(is_equal_approx(float(robot.state_get("finisher", 0.0)), 100.0))

	print("PILOT_HUD_SMOKE_PASS")
	quit(0)

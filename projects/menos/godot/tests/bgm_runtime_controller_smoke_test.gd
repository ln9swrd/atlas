extends SceneTree

func _init() -> void:
	process_frame.connect(_run_test, CONNECT_ONE_SHOT)

func _run_test() -> void:
	var controller := BGMController.new()
	root.add_child(controller)
	var ok := controller.play_context("FACTION_01", "COMBAT")
	if not ok:
		push_error("BGM runtime binding failed")
		quit(1)
		return
	if controller.current_id() != "FACTION_01_COMBAT":
		push_error("BGM runtime selected unexpected definition")
		quit(1)
		return
	controller.stop()
	controller.queue_free()
	await process_frame
	print("BGM_RUNTIME_CONTROLLER_PASS")
	quit(0)

extends SceneTree

func _init() -> void:
	process_frame.connect(_run_test, CONNECT_ONE_SHOT)

func _run_test() -> void:
	var controller := BGMController.new()
	root.add_child(controller)
	var failures: Array[String] = []
	var contexts := ["NORMAL", "COMBAT", "VICTORY", "DEFEAT"]
	for context in contexts:
		var expected_id: String = "FACTION_01_" + context
		if not controller.play_context("FACTION_01", context):
			failures.append("%s context failed to start playback" % context)
			continue
		await create_timer(0.1).timeout
		if controller.current_id() != expected_id:
			failures.append("%s selected unexpected BGM id: %s" % [context, controller.current_id()])
		if controller._player == null or not controller._player.playing:
			failures.append("%s AudioStreamPlayer is not playing" % context)
		if AudioServer.get_bus_index("BGM") < 0 or AudioServer.get_bus_index("SFX") < 0:
			failures.append("%s did not initialize BGM/SFX buses" % context)
		else:
			print("BGM_RUNTIME_CONTEXT_PASS context=", context, " id=", controller.current_id())
	controller.stop()
	controller.queue_free()
	await process_frame
	if failures.is_empty():
		print("BGM_RUNTIME_CONTROLLER_PASS contexts=4")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("BGM_RUNTIME_CONTROLLER_FAIL errors=%d" % failures.size())
		quit(1)

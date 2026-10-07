extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	StageManager.begin_run("campaign")
	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")
	controller._append_effect({
		"type": "proj_defender",
		"start": Vector2(10, 20),
		"target": Vector2(110, 20),
		"progress": 0.5,
		"speed": 5.5,
		"source": "robot",
		"weapon": "robot",
		"damage": 20.0
	})
	assert(controller.vfx_instances.size() == 1)
	var commands = controller.vfx_instances[0].render_commands()
	assert(commands.size() == 1)
	assert(commands[0].get("type", "") == "trail")
	assert(commands[0].get("position", Vector2.ZERO) == Vector2(60, 20))
	controller.vfx_instances[0].source_effect["progress"] = 1.0
	controller._update_vfx_instances(0.01)
	assert(controller.vfx_instances.is_empty())
	print("VFX_PROJECTILE_RUNTIME_INTEGRATION_PASS")
	quit(0)

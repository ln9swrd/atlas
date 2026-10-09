extends SceneTree

func _init() -> void:
	var scene = load("res://editor/sfx_editor.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	await process_frame
	instance.get_node("Root/Body/Editor/Fields/ID").text = "SFX_EDITOR_SMOKE_TEMP"
	instance.get_node("Root/Body/Editor/Fields/Name").text = "Smoke Temp"
	instance.get_node("Root/Body/Editor/Fields/Category").text = "test"
	instance.get_node("Root/Body/Editor/Fields/AudioAsset").text = "res://sound/sfx_ui_click_1.mp3"
	instance.get_node("Root/Body/Editor/Buttons/Save").emit_signal("pressed")
	await process_frame
	var repo = instance.repository
	if not repo.exists("SFX_EDITOR_SMOKE_TEMP"):
		print("SFX_EDITOR_SAVE_FAIL")
		instance.queue_free()
		quit(1)
		return
	instance.current_id = "SFX_EDITOR_SMOKE_TEMP"
	instance.get_node("Root/Body/Editor/Buttons/Delete").emit_signal("pressed")
	await process_frame
	if repo.exists("SFX_EDITOR_SMOKE_TEMP"):
		print("SFX_EDITOR_DELETE_FAIL")
		instance.queue_free()
		quit(1)
		return
	instance.queue_free()
	print("SFX_EDITOR_SAVE_RELOAD_DELETE_PASS")
	quit(0)

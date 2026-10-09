extends SceneTree

func _init() -> void:
	var scene = load("res://editor/vfx_editor.tscn")
	if scene == null:
		print("VFX_EDITOR_SCENE_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	print("VFX_EDITOR_SCENE_PASS")
	instance.queue_free()
	quit(0)

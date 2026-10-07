extends SceneTree

func _init() -> void:
	var scene = load("res://editor/content_editor.tscn")
	if scene == null:
		print("CONTENT_EDITOR_VFX_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	print("CONTENT_EDITOR_VFX_PASS")
	instance.queue_free()
	quit(0)

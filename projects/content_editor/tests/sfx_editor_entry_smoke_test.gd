extends SceneTree

func _init() -> void:
	var sfx_scene = load("res://editor/sfx_editor.tscn")
	if sfx_scene == null:
		print("SFX_EDITOR_FAIL scene")
		quit(1)
		return
	var instance = sfx_scene.instantiate()
	root.add_child(instance)
	await process_frame
	if not instance.has_node("Root/Body/ListPanel/List") or not instance.has_node("Preview"):
		print("SFX_EDITOR_FAIL nodes")
		instance.queue_free()
		quit(1)
		return
	var content_scene = load("res://editor/content_editor.tscn")
	if content_scene == null:
		print("SFX_EDITOR_FAIL content_scene")
		instance.queue_free()
		quit(1)
		return
	var content = content_scene.instantiate()
	root.add_child(content)
	await process_frame
	var button = content.get_node("MainLayout/TopMenu/Buttons/BtnSFX") as Button
	if button == null or button.disabled:
		print("SFX_EDITOR_FAIL menu_disabled")
		content.queue_free()
		instance.queue_free()
		quit(1)
		return
	instance.queue_free()
	content.queue_free()
	print("SFX_EDITOR_ENTRY_PASS")
	quit(0)

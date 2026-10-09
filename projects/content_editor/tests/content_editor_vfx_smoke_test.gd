extends SceneTree

func _init() -> void:
	var scene = load("res://editor/content_editor.tscn")
	if scene == null:
		print("CONTENT_EDITOR_VFX_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	var button: Button = instance.get_node("MainLayout/TopMenu/Buttons/BtnVFX")
	if button.disabled:
		print("CONTENT_EDITOR_VFX_FAIL button_disabled")
		quit(1)
		return
	if not instance.has_method("_open_vfx_editor"):
		print("CONTENT_EDITOR_VFX_FAIL opener")
		quit(1)
		return
	if not ResourceLoader.exists("res://editor/vfx_editor.tscn"):
		print("CONTENT_EDITOR_VFX_FAIL scene_missing")
		quit(1)
		return
	print("CONTENT_EDITOR_VFX_PASS")
	instance.free()
	quit(0)

extends SceneTree
func _init():
	var scene=load("res://editor/content_editor.tscn")
	if scene==null: print("CONTENT_EDITOR_VOICE_FAIL scene"); quit(1); return
	var root=scene.instantiate()
	var button=root.get_node("MainLayout/TopMenu/Buttons/BtnVoice") as Button
	if button==null or button.disabled: print("CONTENT_EDITOR_VOICE_FAIL button"); quit(1); return
	if not ResourceLoader.exists("res://editor/voice_editor.tscn"): print("CONTENT_EDITOR_VOICE_FAIL editor"); quit(1); return
	print("CONTENT_EDITOR_VOICE_PASS"); root.queue_free(); quit(0)

extends SceneTree
func _init():
	var scene=load("res://editor/voice_editor.tscn")
	if scene==null: print("VOICE_EDITOR_ENTRY_FAIL"); quit(1); return
	var node=scene.instantiate()
	if node==null: print("VOICE_EDITOR_INSTANTIATE_FAIL"); quit(1); return
	print("VOICE_EDITOR_ENTRY_PASS"); node.queue_free(); quit(0)

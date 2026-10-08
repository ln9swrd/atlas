extends SceneTree
const DefinitionScript=preload("res://scripts/voice_definition.gd")
const AdapterScript=preload("res://scripts/voice_runtime_adapter.gd")
func _init():
	var d=DefinitionScript.from_dict({"id":"VOICE_PILOT","dialogue_id":"DIALOGUE_PILOT","voice_profile_id":"PROFILE_PILOT","language":"ko","bus":"Master"})
	var adapter=AdapterScript.new()
	adapter.configure(d)
	var owner=Node.new()
	get_root().add_child(owner)
	if adapter.play(owner): print("VOICE_RUNTIME_UNEXPECTED_PLAY"); quit(1); return
	print("VOICE_RUNTIME_SILENT_FALLBACK_PASS")
	owner.queue_free()
	quit(0)

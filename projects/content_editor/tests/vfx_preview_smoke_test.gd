extends SceneTree

func _init() -> void:
	var scene = load("res://editor/vfx_editor.tscn")
	if scene == null:
		print("VFX_PREVIEW_FAIL scene")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	instance.get_node("MainLayout/Body/Editor/Fields/Identity/Id").text = "preview_smoke"
	instance.get_node("MainLayout/Body/Editor/Fields/Identity/Name").text = "Preview Smoke"
	instance.get_node("MainLayout/Body/Editor/Fields/Composition/ComponentType").text = "Ring"
	instance.get_node("MainLayout/Body/Editor/Fields/Composition/ComponentButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/Controls/Duration").value = 1.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackProperty").text = "opacity"
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackStart").value = 0.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackEnd").value = 1.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyTime").value = 0.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyValue").text = "0.2"
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyTime").value = 1.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyValue").text = "1.0"
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/KeyButtons/Add").emit_signal("pressed")
	instance.call("_preview_scrub", 0.5)
	await process_frame
	var preview_status = str(instance.get_node("MainLayout/Body/PreviewPanel/PreviewStatus").text)
	if preview_status.find("t=0.50") < 0:
		print("VFX_PREVIEW_FAIL scrub")
		quit(1)
		return
	print("VFX_PREVIEW_AUTHORING_PASS")
	instance.queue_free()
	quit(0)

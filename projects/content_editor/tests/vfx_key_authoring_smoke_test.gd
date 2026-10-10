extends SceneTree

const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")

func _init() -> void:
	var scene = load("res://editor/vfx_editor.tscn")
	if scene == null:
		print("VFX_KEY_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Identity/Id").text = "p1_key_vfx"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Identity/Name").text = "P1 Key VFX"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentType").text = "Ring"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentResource").text = "impact_explosion"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Duration").value = 1.0
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackProperty").text = "opacity"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackStart").value = 0.0
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackEnd").value = 1.0
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/TrackButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyTime").value = 0.5
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyValue").text = "0.75"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyInterpolation").select(2)
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/KeyButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Buttons/Save").emit_signal("pressed")
	await process_frame
	var definition = RepositoryScript.get_definition("p1_key_vfx")
	if definition == null:
		print("VFX_KEY_FAIL missing")
		quit(1)
		return
	var tracks = definition.timeline.get("tracks", [])
	if tracks.size() != 1:
		print("VFX_KEY_FAIL track count")
		quit(1)
		return
	var keys = tracks[0].get("keys", [])
	if keys.size() != 1 or float(keys[0].get("time", -1.0)) != 0.5 or str(keys[0].get("value", "")) != "0.75" or str(keys[0].get("interpolation", "")) != "ease_in":
		print("VFX_KEY_FAIL key data")
		quit(1)
		return
	RepositoryScript.delete_definition("p1_key_vfx")
	print("VFX_KEY_AUTHORING_PASS")
	instance.queue_free()
	quit(0)

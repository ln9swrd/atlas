extends SceneTree

const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")

func _init() -> void:
	var scene = load("res://editor/vfx_editor.tscn")
	if scene == null:
		print("VFX_EDITOR_TRANSFORM_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	instance.get_node("MainLayout/Body/Editor/Fields/Identity/Id").text = "p1_transform_vfx"
	instance.get_node("MainLayout/Body/Editor/Fields/Identity/Name").text = "P1 Transform VFX"
	instance.get_node("MainLayout/Body/Editor/Fields/Composition/ComponentType").text = "Ring"
	instance.get_node("MainLayout/Body/Editor/Fields/Composition/ComponentResource").text = "impact_explosion"
	instance.get_node("MainLayout/Body/Editor/Fields/Composition/ComponentButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/Controls/Duration").value = 1.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackProperty").text = "opacity"
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackStart").value = 0.0
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackEnd").value = 0.8
	instance.get_node("MainLayout/Body/Editor/Fields/Timeline/TrackButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/Space").select(1)
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/Anchor").text = "parent"
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/OffsetX").value = 12
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/OffsetY").value = -4
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/Rotation").value = 30
	instance.get_node("MainLayout/Body/Editor/Fields/Transform/Scale").value = 1.5
	instance.get_node("MainLayout/Body/Editor/Fields/Buttons/Save").emit_signal("pressed")
	await process_frame
	var definition = RepositoryScript.get_definition("p1_transform_vfx")
	if definition == null:
		print("VFX_EDITOR_TRANSFORM_FAIL missing saved definition")
		quit(1)
		return
	var tracks = definition.timeline.get("tracks", [])
	var transform = definition.transform
	if tracks.size() != 1 or str(tracks[0].get("property", "")) != "opacity":
		print("VFX_EDITOR_TRANSFORM_FAIL track")
		quit(1)
		return
	if str(transform.get("space", "")) != "attached" or str(transform.get("anchor", "")) != "parent":
		print("VFX_EDITOR_TRANSFORM_FAIL transform")
		quit(1)
		return
	RepositoryScript.delete_definition("p1_transform_vfx")
	print("VFX_EDITOR_TRANSFORM_AUTHORING_PASS")
	instance.queue_free()
	quit(0)

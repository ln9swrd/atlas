extends SceneTree

const RepositoryScript = preload("res://scripts/vfx_definition_repository.gd")

func _init() -> void:
	var scene = load("res://editor/vfx_editor.tscn")
	if scene == null:
		print("VFX_EDITOR_AUTHORING_FAIL load")
		quit(1)
		return
	var instance = scene.instantiate()
	get_root().add_child(instance)
	await process_frame
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Identity/Id").text = "p1_smoke_vfx"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Identity/Name").text = "P1 Smoke VFX"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentType").text = "Sprite"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentResource").text = "impact_explosion"
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Composition/ComponentButtons/Add").emit_signal("pressed")
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Duration").value = 0.75
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Timeline/Controls/Loop").button_pressed = true
	instance.get_node("MainLayout/Body/Editor/FieldScroll/Fields/Buttons/Save").emit_signal("pressed")
	await process_frame
	var definition = RepositoryScript.get_definition("p1_smoke_vfx")
	if definition == null:
		print("VFX_EDITOR_AUTHORING_FAIL missing saved definition")
		quit(1)
		return
	if definition.components.size() != 1 or str(definition.components[0].get("type", "")) != "Sprite":
		print("VFX_EDITOR_AUTHORING_FAIL component")
		quit(1)
		return
	if float(definition.timeline.get("duration", 0.0)) != 0.75 or not bool(definition.timeline.get("loop", false)):
		print("VFX_EDITOR_AUTHORING_FAIL timeline")
		quit(1)
		return
	RepositoryScript.delete_definition("p1_smoke_vfx")
	print("VFX_EDITOR_AUTHORING_PASS")
	instance.queue_free()
	quit(0)

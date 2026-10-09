extends RefCounted

const VFX_FILE := "vfx_definitions"
const VFX_LOADER = preload("res://scripts/vfx_definition_loader.gd")

func validate_vfx_catalog(errors: Array[String], warnings: Array[String]) -> void:
	var catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog(VFX_FILE)
	if catalog.is_empty():
		return
	for vfx_id in catalog.keys():
		var raw = catalog[vfx_id]
		if not (raw is Dictionary):
			errors.append("VFX[%s] is not an object" % vfx_id)
			continue
		_validate_vfx_definition(str(vfx_id), raw, errors, warnings)

func _validate_vfx_definition(vfx_id: String, data: Dictionary, errors: Array[String], warnings: Array[String]) -> void:
	if str(data.get("id", "")) != vfx_id:
		errors.append("VFX[%s].id does not match catalog key" % vfx_id)
	var schema_version := int(data.get("schema_version", -1))
	if schema_version != VFX_LOADER.SUPPORTED_SCHEMA_VERSION:
		errors.append("VFX[%s].schema_version is unsupported: %d" % [vfx_id, schema_version])
	if int(data.get("revision", 0)) < 1:
		errors.append("VFX[%s].revision must be >= 1" % vfx_id)
	var status := str(data.get("status", ""))
	if status not in ["Draft", "Review", "Validated", "Production", "Deprecated"]:
		errors.append("VFX[%s].status is invalid: %s" % [vfx_id, status])
	if str(data.get("category", "")).strip_edges().is_empty():
		errors.append("VFX[%s].category is required" % vfx_id)
	var components = data.get("components", [])
	if not (components is Array):
		errors.append("VFX[%s].components must be an array" % vfx_id)
	else:
		for index in components.size():
			var component = components[index]
			if not (component is Dictionary):
				errors.append("VFX[%s].components[%d] must be an object" % [vfx_id, index])
			elif str(component.get("type", "")).strip_edges().is_empty():
				errors.append("VFX[%s].components[%d].type is required" % [vfx_id, index])
	var timeline = data.get("timeline", {})
	if not (timeline is Dictionary):
		errors.append("VFX[%s].timeline must be an object" % vfx_id)
	else:
		if float(timeline.get("duration", 0.0)) <= 0.0:
			errors.append("VFX[%s].timeline.duration must be > 0" % vfx_id)
		if str(timeline.get("playback", "once")) not in ["once", "loop", "ping_pong"]:
			errors.append("VFX[%s].timeline.playback is invalid" % vfx_id)
		if not (timeline.get("tracks", []) is Array):
			errors.append("VFX[%s].timeline.tracks must be an array" % vfx_id)
	if not (data.get("transform", {}) is Dictionary):
		errors.append("VFX[%s].transform must be an object" % vfx_id)
	if not (data.get("parameters", {}) is Dictionary):
		errors.append("VFX[%s].parameters must be an object" % vfx_id)
	var resources = data.get("visual_resource_refs", [])
	if not (resources is Array):
		errors.append("VFX[%s].visual_resource_refs must be an array" % vfx_id)
	else:
		for resource_id in resources:
			var ref := str(resource_id).strip_edges()
			if ref.is_empty():
				errors.append("VFX[%s] contains an empty visual resource reference" % vfx_id)
			elif not ref.begins_with("res://") and not VisualAssetRepository.exists(ref):
				errors.append("VFX[%s] references missing Visual Asset: %s" % [vfx_id, ref])
	if int(data.get("priority", 0)) < 0:
		errors.append("VFX[%s].priority is negative" % vfx_id)
	if str(data.get("concurrency", "")).strip_edges().is_empty():
		errors.append("VFX[%s].concurrency is required" % vfx_id)
	if int(data.get("max_instances", 0)) < 0:
		errors.append("VFX[%s].max_instances is negative" % vfx_id)
	if status == "Production" and errors.size() > 0:
		warnings.append("VFX[%s] is Production but has validation errors" % vfx_id)

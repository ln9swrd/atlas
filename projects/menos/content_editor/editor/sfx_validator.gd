class_name SFXValidator
extends RefCounted

static func validate_definition(definition, errors: Array, warnings: Array) -> void:
	if definition == null:
		errors.append("SFX definition is null")
		return
	var id := str(definition.id).strip_edges()
	if id.is_empty():
		errors.append("SFX[%s] id is empty" % id)
	var asset := str(definition.audio_asset).strip_edges()
	if asset.is_empty():
		errors.append("SFX[%s].audio_asset is empty" % id)
	elif not ResourceLoader.exists(asset):
		errors.append("SFX[%s].audio_asset is unresolved: %s" % [id, asset])
	if float(definition.volume) < 0.0:
		errors.append("SFX[%s].volume is negative" % id)
	if float(definition.pitch) <= 0.0:
		errors.append("SFX[%s].pitch must be > 0" % id)
	if str(definition.bus).strip_edges().is_empty():
		errors.append("SFX[%s].bus is empty" % id)
	if int(definition.max_instances) < 0:
		errors.append("SFX[%s].max_instances is negative" % id)
	if float(definition.cooldown) < 0.0:
		errors.append("SFX[%s].cooldown is negative" % id)

static func validate_catalog(errors: Array, warnings: Array) -> void:
	var catalog := SFXDefinitionLoader.load_catalog()
	for id in catalog.keys():
		validate_definition(catalog[id], errors, warnings)

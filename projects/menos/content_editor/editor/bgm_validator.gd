class_name BGMValidator
extends RefCounted

static func validate_definition(definition, errors: Array, warnings: Array) -> void:
	if definition == null:
		errors.append("BGM definition is null")
		return
	var id := str(definition.id).strip_edges()
	if id.is_empty():
		errors.append("BGM[%s] id is empty" % id)
	if str(definition.faction).strip_edges().is_empty():
		errors.append("BGM[%s].faction is empty" % id)
	if str(definition.context).strip_edges().is_empty():
		errors.append("BGM[%s].context is empty" % id)
	var asset := str(definition.audio_asset).strip_edges()
	if asset.is_empty():
		errors.append("BGM[%s].audio_asset is empty" % id)
	elif not ResourceLoader.exists(asset):
		errors.append("BGM[%s].audio_asset is unresolved: %s" % [id, asset])
	if str(definition.bus).strip_edges().is_empty():
		errors.append("BGM[%s].bus is empty" % id)
	if float(definition.volume) < 0.0:
		errors.append("BGM[%s].volume is negative" % id)
	if float(definition.crossfade_seconds) < 0.0:
		errors.append("BGM[%s].crossfade_seconds is negative" % id)
	if float(definition.loop_point) < 0.0:
		errors.append("BGM[%s].loop_point is negative" % id)
	if float(definition.duration) > 0.0 and float(definition.loop_point) >= float(definition.duration):
		errors.append("BGM[%s].loop_point must be less than duration" % id)

static func validate_catalog(errors: Array, warnings: Array) -> void:
	var catalog := BGMDefinitionLoader.load_catalog()
	for id in catalog.keys():
		validate_definition(catalog[id], errors, warnings)

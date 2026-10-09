class_name VoiceValidator
extends RefCounted
static func validate_definition(definition, errors: Array, warnings: Array) -> void:
	if definition == null: errors.append("Definition is null"); return
	if str(definition.id).is_empty(): errors.append("Voice ID is required")
	if str(definition.dialogue_id).is_empty(): errors.append("Dialogue ID is required")
	if str(definition.voice_profile_id).is_empty(): warnings.append("Voice Profile ID is not assigned")
	if str(definition.voice_asset).is_empty(): warnings.append("Voice Asset is not assigned; silent fallback remains active")
	elif not ResourceLoader.exists(str(definition.voice_asset)): errors.append("Voice Asset does not resolve: %s" % definition.voice_asset)
	if str(definition.language).is_empty(): errors.append("Language is required")
	if str(definition.bus).is_empty(): errors.append("Voice bus is required")

class_name VoiceDefinitionLoader
extends RefCounted
const CATALOG_PATH := "voice_definitions"
const DEFINITION_SCRIPT = preload("res://scripts/voice_definition.gd")
static func load_catalog() -> Dictionary:
	var raw := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	var result := {}
	for key in raw.keys():
		if raw[key] is Dictionary:
			result[str(key)] = DEFINITION_SCRIPT.from_dict(raw[key])
	return result

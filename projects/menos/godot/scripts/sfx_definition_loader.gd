class_name SFXDefinitionLoader
extends RefCounted

const CATALOG_PATH := "sfx_definitions"
const DEFINITION_SCRIPT = preload("res://scripts/sfx_definition.gd")

static func load_catalog() -> Dictionary:
	var raw := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	var result := {}
	for key in raw.keys():
		var data = raw[key]
		if data is Dictionary:
			var d = DEFINITION_SCRIPT.from_dict(data)
			if d != null and not d.id.is_empty():
				result[d.id] = d
	return result

static func load_definition(sfx_id: String):
	var raw := ContentCatalogLoader.load_single_entry(CATALOG_PATH, sfx_id)
	if raw.is_empty():
		return null
	return DEFINITION_SCRIPT.from_dict(raw)

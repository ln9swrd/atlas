class_name VFXDefinitionLoader
extends RefCounted

const CATALOG_PATH := "vfx_definitions"
const SUPPORTED_SCHEMA_VERSION := 1
const DEFINITION_SCRIPT = preload("res://scripts/vfx_definition.gd")

static func load_catalog() -> Dictionary:
	var raw_catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	var result: Dictionary = {}
	for key in raw_catalog.keys():
		var raw_data = raw_catalog[key]
		if not (raw_data is Dictionary):
			continue
		var definition = from_dict(raw_data)
		if definition == null:
			continue
		result[definition.id] = definition
	return result

static func load_definition(vfx_id: String):
	var raw_data: Dictionary = ContentCatalogLoader.load_single_entry(CATALOG_PATH, vfx_id)
	if raw_data.is_empty():
		return null
	return from_dict(raw_data)

static func from_dict(data: Dictionary):
	var schema_version := int(data.get("schema_version", 1))
	if schema_version != SUPPORTED_SCHEMA_VERSION:
		push_error("VFXDefinitionLoader: unsupported schema_version %d" % schema_version)
		return null
	var definition = DEFINITION_SCRIPT.from_dict(data)
	if definition.id.is_empty():
		push_error("VFXDefinitionLoader: definition id is empty")
		return null
	return definition

class_name MissionDefinitionLoader
extends RefCounted

const CATALOG_PATH := "res://content/missions/missions.json"

static func load_catalog() -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)

static func load_definition(mission_id: String) -> MissionDefinition:
	var catalog := load_catalog()
	if not catalog.has(mission_id):
		push_error("MissionDefinitionLoader: mission '%s' not found." % mission_id)
		return null
	return MissionDefinition.from_dict(catalog[mission_id], mission_id)

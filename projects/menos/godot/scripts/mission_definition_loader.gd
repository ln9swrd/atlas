class_name MissionDefinitionLoader
extends RefCounted

const CATALOG_PATH := "missions"

static func load_catalog() -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)

static func load_definition(mission_id: String) -> MissionDefinition:
	var resolved_id := mission_id
	if mission_id.is_valid_int():
		resolved_id = ContentCatalogLoader.resolve_odb_pk("mission", int(mission_id))
	elif mission_id.is_valid_float():
		var numeric_id := float(mission_id)
		if is_equal_approx(numeric_id, round(numeric_id)):
			resolved_id = ContentCatalogLoader.resolve_odb_pk("mission", int(numeric_id))
	var catalog := load_catalog()
	if not catalog.has(resolved_id):
		push_error("MissionDefinitionLoader: mission '%s' not found." % mission_id)
		return null
	return MissionDefinition.from_dict(catalog[resolved_id], resolved_id)

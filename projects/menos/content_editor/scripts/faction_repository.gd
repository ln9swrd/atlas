class_name FactionRepository
extends RefCounted

const CATALOG_PATH := "factions"

static var _catalog: Dictionary = {}
static var _loaded := false

static func load_catalog() -> Dictionary:
	_catalog = ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	_loaded = true
	return _catalog.duplicate(true)

static func reload() -> Dictionary:
	_loaded = false
	return load_catalog()

static func _ensure_loaded() -> void:
	if not _loaded:
		load_catalog()

static func get_faction(faction_id: String) -> FactionDefinition:
	_ensure_loaded()
	var data: Dictionary = _catalog.get(faction_id, {})
	if data.is_empty():
		return null
	return FactionDefinition.from_catalog(data)

static func exists(faction_id: String) -> bool:
	_ensure_loaded()
	return _catalog.has(faction_id)

static func list_factions() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for key in _catalog.keys():
		ids.append(str(key))
	ids.sort()
	return ids

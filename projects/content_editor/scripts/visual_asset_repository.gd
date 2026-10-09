class_name VisualAssetRepository
extends RefCounted

const CATALOG_PATH := "visual_assets"

static var _catalog: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed := ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)
	if not parsed.is_empty():
		_catalog = parsed

static func reload() -> void:
	_catalog.clear()
	_loaded = false
	_ensure_loaded()

static func get_asset(asset_id: String) -> VisualAssetDefinition:
	_ensure_loaded()
	var data = _catalog.get(asset_id)
	if not (data is Dictionary):
		return null
	return VisualAssetDefinition.from_dict(data)

static func exists(asset_id: String) -> bool:
	_ensure_loaded()
	return _catalog.has(asset_id) and _catalog[asset_id] is Dictionary

static func list(category: String = "") -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys():
		var data = _catalog[key]
		if category.is_empty() or (data is Dictionary and str(data.get("category", "")) == category):
			result.append(str(key))
	result.sort()
	return result

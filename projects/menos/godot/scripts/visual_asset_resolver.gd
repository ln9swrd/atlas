class_name VisualAssetResolver
extends RefCounted

const CATALOG_PATH := "res://content/editor/visual_assets.json"

static var _catalog: Dictionary = {}
static var _loaded := false

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	if not FileAccess.file_exists(CATALOG_PATH):
		return
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_catalog = parsed

static func get_asset(asset_id: String) -> VisualAssetDefinition:
	_ensure_loaded()
	var data = _catalog.get(asset_id)
	if not (data is Dictionary):
		return null
	return VisualAssetDefinition.from_dict(data)

static func resolve(value: String) -> VisualAssetDefinition:
	if value.is_empty():
		return null
	var asset := get_asset(value)
	if asset != null:
		return asset
	return _legacy_source(value)

static func _legacy_source(source: String) -> VisualAssetDefinition:
	var asset := VisualAssetDefinition.new()
	asset.id = "legacy:" + source
	asset.category = "Runtime"
	asset.source = source
	asset.region = Rect2()
	asset.frames = 1
	asset.usage = "legacy_source"
	return asset

static func list_ids(category: String = "") -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for key in _catalog.keys():
		var data = _catalog[key]
		if category.is_empty() or (data is Dictionary and str(data.get("category", "")) == category):
			result.append(str(key))
	result.sort()
	return result

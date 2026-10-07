class_name VisualAssetResolver
extends RefCounted

static func reload() -> void:
	VisualAssetRepository.reload()

static func get_asset(asset_id: String) -> VisualAssetDefinition:
	return VisualAssetRepository.get_asset(asset_id)

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
	var legacy_sprite_path := "res://assets/menos/sprites/%s.png" % source
	if ResourceLoader.exists(legacy_sprite_path):
		asset.source = legacy_sprite_path
		asset.usage = "legacy_sprite"
	else:
		asset.source = source
		asset.usage = "legacy_source"
	asset.region = Rect2()
	asset.frames = 1
	return asset

static func list_ids(category: String = "") -> Array[String]:
	return VisualAssetRepository.list(category)

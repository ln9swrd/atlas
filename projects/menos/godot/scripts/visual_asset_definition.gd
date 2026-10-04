class_name VisualAssetDefinition
extends RefCounted

var id: String = ""
var category: String = ""
var source: String = ""
var region: Rect2 = Rect2()
var frames: int = 1
var columns: int = 1
var rows: int = 1
var frame_order: String = "row_major"
var anchor_mode: String = "BOTTOM_CENTER"
var anchor_x: float = 0.5
var anchor_y: float = 1.0
var owner_id: String = ""
var usage: String = ""
var team_mask_source: String = ""
var frame_regions: Array = []

static func from_dict(data: Dictionary) -> VisualAssetDefinition:
	var definition := VisualAssetDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.category = str(data.get("category", ""))
	definition.source = str(data.get("source", ""))
	var region_data: Array = data.get("region", [])
	if region_data.size() >= 4:
		definition.region = Rect2(
			float(region_data[0]),
			float(region_data[1]),
			float(region_data[2]),
			float(region_data[3])
		)
	definition.frames = maxi(1, int(data.get("frames", 1)))
	definition.columns = maxi(1, int(data.get("columns", definition.frames)))
	definition.rows = maxi(1, int(data.get("rows", 1)))
	definition.frame_order = str(data.get("frame_order", "row_major"))
	var anchor_data: Dictionary = data.get("anchor", {}) if data.get("anchor", {}) is Dictionary else {}
	definition.anchor_mode = str(anchor_data.get("mode", data.get("anchor_mode", "BOTTOM_CENTER")))
	definition.anchor_x = clampf(float(anchor_data.get("x", data.get("anchor_x", 0.5))), 0.0, 1.0)
	definition.anchor_y = clampf(float(anchor_data.get("y", data.get("anchor_y", 1.0))), 0.0, 1.0)
	definition.owner_id = str(data.get("owner", ""))
	definition.usage = str(data.get("usage", ""))
	var team_mask_data: Variant = data.get("team_mask", {})
	if team_mask_data is Dictionary:
		definition.team_mask_source = str(team_mask_data.get("source", ""))
	var frame_regions_data: Variant = data.get("frame_regions", [])
	if frame_regions_data is Array:
		definition.frame_regions = frame_regions_data.duplicate(true)
	return definition

func to_dict() -> Dictionary:
	return {
		"id": id,
		"category": category,
		"source": source,
		"region": [region.position.x, region.position.y, region.size.x, region.size.y],
		"frames": frames,
		"columns": columns,
		"rows": rows,
		"frame_order": frame_order,
		"anchor": {
			"mode": anchor_mode,
			"x": anchor_x,
			"y": anchor_y
		},
		"owner": owner_id,
		"usage": usage,
		"team_mask": {"source": team_mask_source} if not team_mask_source.is_empty() else {},
		"frame_regions": frame_regions.duplicate(true)
	}

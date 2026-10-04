class_name VisualAssetDefinition
extends RefCounted

var id: String = ""
var category: String = ""
var source: String = ""
var region: Rect2 = Rect2()
var frames: int = 1
var owner_id: String = ""
var usage: String = ""
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
	definition.owner_id = str(data.get("owner", ""))
	definition.usage = str(data.get("usage", ""))
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
		"owner": owner_id,
		"usage": usage,
		"frame_regions": frame_regions.duplicate(true)
	}

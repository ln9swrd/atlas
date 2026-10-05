class_name VisualAssetFrame
extends RefCounted

static func region_for(definition: VisualAssetDefinition, frame_index: int, fallback_region: Rect2 = Rect2()) -> Rect2:
	if definition != null and not definition.frame_regions.is_empty():
		var index := posmod(frame_index, definition.frame_regions.size())
		var values: Variant = definition.frame_regions[index]
		if values is Array and values.size() >= 4:
			return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
	if definition == null:
		return fallback_region
	var frames := maxi(1, definition.frames)
	var columns := maxi(1, definition.columns)
	var rows := maxi(1, definition.rows)
	var index := posmod(frame_index, frames)
	var column := index % columns
	var row := index / columns
	if definition.frame_order == "column_major":
		column = index / rows
		row = index % rows
	var region := definition.region
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		return fallback_region
	if frames <= 1:
		return region
	var left := region.position.x + floorf(region.size.x * float(column) / float(columns))
	var right := region.position.x + floorf(region.size.x * float(column + 1) / float(columns))
	var top := region.position.y + floorf(region.size.y * float(row) / float(rows))
	var bottom := region.position.y + floorf(region.size.y * float(row + 1) / float(rows))
	return Rect2(left, top, maxf(1.0, right - left), maxf(1.0, bottom - top))

static func anchor_normalized(definition: VisualAssetDefinition) -> Vector2:
	if definition == null:
		return Vector2(0.5, 1.0)
	return Vector2(clampf(definition.anchor_x, 0.0, 1.0), clampf(definition.anchor_y, 0.0, 1.0))

static func anchor_offset(definition: VisualAssetDefinition, frame_size: Vector2) -> Vector2:
	var anchor := anchor_normalized(definition)
	return Vector2((0.5 - anchor.x) * frame_size.x, (0.5 - anchor.y) * frame_size.y)

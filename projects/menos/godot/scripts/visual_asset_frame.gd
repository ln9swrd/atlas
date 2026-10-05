class_name VisualAssetFrame
extends RefCounted

static func region_for(definition: VisualAssetDefinition, frame_index: int, fallback_region: Rect2 = Rect2()) -> Rect2:
	if definition == null:
		return fallback_region
	var frames := maxi(1, definition.frames)
	if definition.frame_regions.size() == frames:
		var explicit_index := posmod(frame_index, frames)
		var explicit_values: Variant = definition.frame_regions[explicit_index]
		if explicit_values is Array and explicit_values.size() >= 4:
			var explicit_region := Rect2(float(explicit_values[0]), float(explicit_values[1]), float(explicit_values[2]), float(explicit_values[3]))
			if explicit_region.size.x > 0.0 and explicit_region.size.y > 0.0:
				return explicit_region
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

static func anchor_normalized(definition: VisualAssetDefinition, frame_index: int = -1) -> Vector2:
	if definition == null:
		return Vector2(0.5, 1.0)
	if frame_index >= 0 and frame_index < definition.frame_anchors.size():
		var index := frame_index
		var values: Variant = definition.frame_anchors[index]
		if values is Array and values.size() >= 2:
			return Vector2(clampf(float(values[0]), 0.0, 1.0), clampf(float(values[1]), 0.0, 1.0))
	return Vector2(clampf(definition.anchor_x, 0.0, 1.0), clampf(definition.anchor_y, 0.0, 1.0))

static func anchor_offset(definition: VisualAssetDefinition, frame_size: Vector2, frame_index: int = -1) -> Vector2:
	var anchor := anchor_normalized(definition, frame_index)
	return Vector2((0.5 - anchor.x) * frame_size.x, (0.5 - anchor.y) * frame_size.y)

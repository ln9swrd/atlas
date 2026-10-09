class_name GeometryResolver
extends RefCounted

static func get_animation_offset(definition: ObjectDefinition, animation: String) -> Dictionary:
	var geometry_result := _get_canonical_geometry(definition)
	if not geometry_result.ok:
		return geometry_result
	var geometry: Dictionary = geometry_result.geometry
	var offsets: Variant = geometry.get("animation_offsets", {})
	if offsets == null:
		return {"ok": true, "offset": Vector2.ZERO}
	if not (offsets is Dictionary):
		return _error("animation_offsets must be an object for %s" % definition.id)
	var value: Variant = offsets.get(animation, [0, 0])
	if not _is_numeric_pair(value):
		return _error("animation_offsets[%s] must be [x, y] numeric for %s" % [animation, definition.id])
	return {"ok": true, "offset": Vector2(float(value[0]), float(value[1]))}

static func get_render_offset(definition: ObjectDefinition, animation: String, frame_size: Vector2) -> Dictionary:
	var geometry_result := _get_canonical_geometry(definition)
	if not geometry_result.ok:
		return geometry_result
	var geometry: Dictionary = geometry_result.geometry
	var center: Variant = geometry.get("canonical_body_center", null)
	if not _is_numeric_pair(center):
		return _error("canonical_body_center must be [x, y] numeric for %s" % definition.id)
	var animation_result := get_animation_offset(definition, animation)
	if not animation_result.ok:
		return animation_result
	var canonical_body_center := Vector2(float(center[0]), float(center[1]))
	return {
		"ok": true,
		"offset": (frame_size * 0.5 - canonical_body_center) + animation_result.offset
	}

static func _get_canonical_geometry(definition: ObjectDefinition) -> Dictionary:
	if definition == null or not definition.has_geometry():
		return {"ok": false, "reason": "legacy_or_missing"}
	var geometry := definition.get_geometry()
	if geometry.is_empty():
		return _error("canonical geometry is missing for %s" % definition.id)
	return {"ok": true, "geometry": geometry}

static func _error(message: String) -> Dictionary:
	push_error("GeometryResolver: %s" % message)
	return {"ok": false, "reason": "malformed", "message": message}

static func _is_numeric_pair(value: Variant) -> bool:
	if not (value is Array) or value.size() != 2:
		return false
	for component in value:
		if not (component is int or component is float) or component is bool:
			return false
	return true

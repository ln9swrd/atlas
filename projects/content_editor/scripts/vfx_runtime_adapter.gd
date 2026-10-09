class_name VFXRuntimeAdapter
extends RefCounted

const SUPPORTED_COMPONENTS := ["sprite", "shape", "ring", "line", "trail", "beam"]

var definition = null
var variant: Dictionary = {}
var instance_overrides: Dictionary = {}
var time := 0.0
var playing := false

func configure(vfx_definition, variant_values: Dictionary = {}, overrides: Dictionary = {}) -> void:
	definition = vfx_definition
	variant = variant_values.duplicate(true)
	instance_overrides = overrides.duplicate(true)
	time = 0.0
	playing = false

func play() -> void:
	time = 0.0
	playing = true

func stop() -> void:
	playing = false

func restart() -> void:
	time = 0.0
	playing = true

func seek(value: float) -> void:
	time = clampf(value, 0.0, duration())
	playing = false

func tick(delta: float) -> void:
	if definition == null or not playing:
		return
	var d := duration()
	time += maxf(delta, 0.0)
	if time >= d:
		var playback := str(definition.timeline.get("playback", "once"))
		if playback == "loop" or bool(definition.timeline.get("loop", false)):
			time = fmod(time, maxf(d, 0.001))
		else:
			time = d
			playing = false

func duration() -> float:
	if definition == null:
		return 0.0
	return maxf(float(definition.timeline.get("duration", 0.0)), 0.0)

func progress() -> float:
	var d := duration()
	return 0.0 if d <= 0.0 else clampf(time / d, 0.0, 1.0)

func is_complete() -> bool:
	return definition != null and not playing and is_equal_approx(time, duration())

func render_commands() -> Array:
	if definition == null:
		return []
	var transform: Dictionary = definition.transform
	var offset_data: Dictionary = transform.get("offset", {}) if transform.get("offset", {}) is Dictionary else {}
	var position := Vector2(float(offset_data.get("x", 0.0)), float(offset_data.get("y", 0.0)))
	var instance_position = instance_overrides.get("position", Vector2.ZERO)
	if instance_position is Vector2:
		position += instance_position
	var scale := maxf(0.01, float(transform.get("scale", 1.0)))
	var rotation := float(transform.get("rotation", 0.0))
	if instance_overrides.has("rotation"):
		rotation += float(instance_overrides.get("rotation", 0.0))
	var opacity := 1.0
	var commands: Array = []
	for track in definition.timeline.get("tracks", []):
		if not (track is Dictionary):
			continue
		var value = _evaluate_track(track, time)
		if value == null:
			continue
		match str(track.get("property", "")):
			"opacity":
				opacity = clampf(float(value), 0.0, 1.0)
			"scale":
				scale = maxf(0.01, scale * float(value))
			"rotation":
				rotation += float(value)
			"position_offset":
				var parsed = _parse_value(value)
				if parsed is Vector2:
					position += parsed
	for component in definition.components:
		if not (component is Dictionary):
			continue
		var component_type := str(component.get("type", "")).to_lower()
		if component_type not in SUPPORTED_COMPONENTS:
			commands.append({"type": "unsupported", "component": component_type})
			continue
		var command := {
			"type": component_type,
			"resource": str(component.get("resource", "")),
			"position": position,
			"scale": scale,
			"rotation": rotation,
			"opacity": opacity,
			"progress": progress()
		}
		commands.append(command)
	return commands

func _evaluate_track(track: Dictionary, current_time: float):
	var keys = track.get("keys", [])
	if not (keys is Array) or keys.is_empty():
		return null
	var before = null
	var after = null
	for key in keys:
		if not (key is Dictionary):
			continue
		var key_time := float(key.get("time", 0.0))
		if key_time <= current_time:
			before = key
		if key_time >= current_time:
			after = key
			break
	if before == null:
		return _parse_value(after.get("value", "")) if after != null else null
	if after == null:
		return _parse_value(before.get("value", ""))
	var t0 := float(before.get("time", 0.0))
	var t1 := float(after.get("time", t0))
	if is_equal_approx(t0, t1):
		return _parse_value(after.get("value", ""))
	var ratio := clampf((current_time - t0) / (t1 - t0), 0.0, 1.0)
	match str(after.get("interpolation", "linear")):
		"step":
			ratio = 0.0
		"ease_in":
			ratio = ratio * ratio
		"ease_out":
			ratio = 1.0 - (1.0 - ratio) * (1.0 - ratio)
	return _interpolate(_parse_value(before.get("value", "")), _parse_value(after.get("value", "")), ratio)

func _parse_value(value):
	if value is Vector2:
		return value
	var parsed = JSON.parse_string(str(value))
	if parsed is Array and parsed.size() >= 2:
		return Vector2(float(parsed[0]), float(parsed[1]))
	return parsed if parsed != null else value

func _interpolate(a, b, ratio: float):
	if (a is float or a is int) and (b is float or b is int):
		return lerpf(float(a), float(b), ratio)
	if a is Vector2 and b is Vector2:
		return a.lerp(b, ratio)
	return b if ratio >= 1.0 else a

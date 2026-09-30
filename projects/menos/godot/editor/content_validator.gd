extends Node

const ROOT := "res://"
const ENEMY_FILE := "res://content/enemies/enemies.json"
const TOWER_FILE := "res://content/towers/towers.json"
const ROBOT_FILE := "res://content/robots/robots.json"

var errors: Array[String] = []
var warnings: Array[String] = []

func _ready() -> void:
	_validate_catalog("ENEMY", ENEMY_FILE, ["name", "hp", "speed", "armor", "base_damage", "reward", "radius", "sprite_anim"])
	_validate_catalog("TOWER", TOWER_FILE, ["name", "cost", "damage", "cooldown", "range", "preference", "sprite_anim", "level2"])
	_validate_catalog("ROBOT", ROBOT_FILE, ["id", "name", "hp", "speed", "damage", "cooldown", "range", "max_moves", "sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "projectile_anim", "progression", "energy"])
	_validate_resource_refs()
	if errors.is_empty():
		print("CONTENT_VALIDATION PASS")
	else:
		print("CONTENT_VALIDATION FAIL")
	for warning in warnings:
		print("WARNING: ", warning)
	for error in errors:
		push_error(error)
	quit(1 if not errors.is_empty() else 0)

func _validate_catalog(label: String, path: String, required: Array[String]) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("%s catalog missing: %s" % [label, path])
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or parsed.is_empty():
		errors.append("%s catalog is not a non-empty object: %s" % [label, path])
		return
	for id in parsed.keys():
		var entry = parsed[id]
		if not (entry is Dictionary):
			errors.append("%s[%s] is not an object" % [label, id])
			continue
		for key in required:
			if not entry.has(key):
				errors.append("%s[%s] missing required field: %s" % [label, id, key])
		for key in entry.keys():
			var value = entry[key]
			if value is float or value is int:
				if float(value) < 0.0:
					errors.append("%s[%s].%s is negative" % [label, id, key])

func _validate_resource_refs() -> void:
	for path in [ENEMY_FILE, TOWER_FILE, ROBOT_FILE]:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		_walk_refs(parsed, path)

func _walk_refs(value, source: String) -> void:
	if value is Dictionary:
		for key in value.keys():
			var child = value[key]
			if child is String and child.begins_with("res://"):
				if not ResourceLoader.exists(child):
					errors.append("Missing resource in %s: %s" % [source, child])
			_walk_refs(child, source)
	elif value is Array:
		for child in value:
			_walk_refs(child, source)



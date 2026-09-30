extends Node

const ROOT := "res://"
const ENEMY_FILE := "res://content/enemies/enemies.json"
const TOWER_FILE := "res://content/towers/towers.json"
const ROBOT_FILE := "res://content/robots/robots.json"
const SKILL_FILE := "res://content/skills/skills.json"
const GAMEPLAY_FILE := "res://content/settings/gameplay.json"

var errors: Array[String] = []
var warnings: Array[String] = []

func _ready() -> void:
	_validate_catalog("ENEMY", ENEMY_FILE, ["name", "hp", "speed", "armor", "base_damage", "reward", "radius", "sprite_anim"])
	_validate_catalog("TOWER", TOWER_FILE, ["name", "cost", "damage", "cooldown", "range", "preference", "sprite_anim", "level2"])
	_validate_catalog("ROBOT", ROBOT_FILE, ["id", "name", "hp", "speed", "damage", "cooldown", "range", "max_moves", "sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "projectile_anim", "progression", "energy"])
	var skills := _load_json_dictionary(SKILL_FILE, "SKILL")
	_validate_skills(skills)
	_validate_gameplay_settings(skills)
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

func _load_json_dictionary(path: String, label: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("%s catalog missing: %s" % [label, path])
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		errors.append("%s data is not an object: %s" % [label, path])
		return {}
	return parsed

func _validate_skills(skills: Dictionary) -> void:
	if skills.is_empty():
		return
	for skill_id in skills.keys():
		var skill = skills[skill_id]
		if not (skill is Dictionary):
			errors.append("SKILL[%s] is not an object" % skill_id)
			continue
		for key in ["id", "name", "growth_available"]:
			if not skill.has(key):
				errors.append("SKILL[%s] missing required field: %s" % [skill_id, key])
		if str(skill.get("id", "")) != str(skill_id):
			errors.append("SKILL[%s].id does not match catalog key" % skill_id)
		if skill.get("growth_available", false) and not skill.has("execution_type"):
			errors.append("SKILL[%s] missing execution_type for growth skill" % skill_id)
		var execution_type := str(skill.get("execution_type", ""))
		if not execution_type.is_empty() and execution_type not in ["area", "target_pierce"]:
			errors.append("SKILL[%s] has unsupported execution_type: %s" % [skill_id, execution_type])
		if execution_type == "area":
			for key in ["damage", "radius", "cooldown", "energy_cost", "duration", "threshold"]:
				if not skill.has(key):
					errors.append("SKILL[%s] missing area field: %s" % [skill_id, key])
		elif execution_type == "target_pierce":
			for key in ["damage", "cooldown", "energy_cost", "duration"]:
				if not skill.has(key):
					errors.append("SKILL[%s] missing target_pierce field: %s" % [skill_id, key])
		for key in skill.keys():
			var value = skill[key]
			if value is float or value is int:
				if float(value) < 0.0:
					errors.append("SKILL[%s].%s is negative" % [skill_id, key])

func _validate_gameplay_settings(skills: Dictionary) -> void:
	var gameplay := _load_json_dictionary(GAMEPLAY_FILE, "GAMEPLAY")
	if gameplay.is_empty():
		return
	var wave_group_gap = gameplay.get("wave_group_gap", {})
	if not (wave_group_gap is Dictionary) or not wave_group_gap.has("delay"):
		errors.append("GAMEPLAY.wave_group_gap.delay is required")
	elif float(wave_group_gap.get("delay", 0.0)) < 0.0:
		errors.append("GAMEPLAY.wave_group_gap.delay is negative")
	var slots = gameplay.get("skill_slots", {})
	if not (slots is Dictionary):
		errors.append("GAMEPLAY.skill_slots must be an object")
		return
	for slot in ["1", "2", "3"]:
		if not slots.has(slot):
			errors.append("GAMEPLAY.skill_slots missing slot: %s" % slot)
			continue
		var skill_id := str(slots[slot])
		if skill_id.is_empty():
			continue
		if not skills.has(skill_id):
			errors.append("GAMEPLAY.skill_slots[%s] references unknown skill: %s" % [slot, skill_id])
			continue
		var skill = skills[skill_id]
		if not (skill is Dictionary):
			continue
		if not bool(skill.get("growth_available", false)):
			errors.append("GAMEPLAY.skill_slots[%s] references non-growth skill: %s" % [slot, skill_id])

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



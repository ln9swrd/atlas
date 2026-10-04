extends Node

const ROOT := "res://"
const ENEMY_FILE := "res://content/enemies/enemies.json"
const ALLIED_UNIT_FILE := "res://content/allied_units/allied_units.json"
const TOWER_FILE := "res://content/towers/towers.json"
const ROBOT_FILE := "res://content/robots/robots.json"
const SKILL_FILE := "res://content/skills/skills.json"
const GAMEPLAY_FILE := "res://content/settings/gameplay.json"
const CAMPAIGN_FILE := "res://content/campaign/main_campaign.json"
const STAGE_CATALOG_FILE := "res://content/stages/stage_catalog.json"

var errors: Array[String] = []
var warnings: Array[String] = []

func _ready() -> void:
	_validate_catalog("ENEMY", ENEMY_FILE, ["name", "hp", "speed", "armor", "base_damage", "reward", "radius", "sprite_anim"])
	_validate_catalog("TOWER", TOWER_FILE, ["name", "cost", "damage", "cooldown", "range", "preference", "sprite_anim", "level2"])
	_validate_catalog("ROBOT", ROBOT_FILE, ["id", "name", "hp", "speed", "damage", "cooldown", "range", "sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "projectile_anim", "progression", "energy"])
	var skills := _load_json_dictionary(SKILL_FILE, "SKILL")
	_validate_skills(skills)
	_validate_gameplay_settings(skills)
	_validate_stage_catalog()
	_validate_campaign()
	_validate_stages()
	_validate_resource_refs()
	if errors.is_empty():
		print("CONTENT_VALIDATION PASS")
	else:
		print("CONTENT_VALIDATION FAIL")
	for warning in warnings:
		print("WARNING: ", warning)
	for error in errors:
		push_error(error)
	get_tree().quit(1 if not errors.is_empty() else 0)

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

func _validate_stage_catalog() -> void:
	var file := FileAccess.open(STAGE_CATALOG_FILE, FileAccess.READ)
	if file == null:
		errors.append("STAGE CATALOG file missing: %s" % STAGE_CATALOG_FILE)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get("stages", []) is Array) or parsed["stages"].is_empty():
		errors.append("STAGE CATALOG stages must be a non-empty array: %s" % STAGE_CATALOG_FILE)
		return
	var seen := {}
	for index in parsed["stages"].size():
		var stage_id := str(parsed["stages"][index])
		if stage_id.is_empty() or seen.has(stage_id):
			errors.append("STAGE CATALOG stages[%d] is empty or duplicated: %s" % [index, stage_id])
		elif not FileAccess.file_exists(StageLoader.resolve_stage_path(stage_id)):
			errors.append("STAGE CATALOG stages[%d] references missing stage: %s" % [index, stage_id])
		seen[stage_id] = true

func _validate_campaign() -> void:
	var file := FileAccess.open(CAMPAIGN_FILE, FileAccess.READ)
	if file == null:
		errors.append("CAMPAIGN file missing: %s" % CAMPAIGN_FILE)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get("stages", []) is Array) or parsed["stages"].is_empty():
		errors.append("CAMPAIGN stages must be a non-empty array: %s" % CAMPAIGN_FILE)
		return
	var catalog_ids := _load_stage_catalog_ids()
	for index in parsed["stages"].size():
		var stage_id := str(parsed["stages"][index])
		if stage_id.is_empty() or not FileAccess.file_exists(StageLoader.resolve_stage_path(stage_id)):
			errors.append("CAMPAIGN stages[%d] references missing stage: %s" % [index, stage_id])
		elif not catalog_ids.has(stage_id):
			errors.append("CAMPAIGN stages[%d] is not present in STAGE CATALOG: %s" % [index, stage_id])

func _load_stage_catalog_ids() -> Dictionary:
	var ids := {}
	var file := FileAccess.open(STAGE_CATALOG_FILE, FileAccess.READ)
	if file == null:
		return ids
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or not (parsed.get("stages", []) is Array):
		return ids
	for stage_id in parsed["stages"]:
		var id := str(stage_id)
		if not id.is_empty():
			ids[id] = true
	return ids

func _validate_stages() -> void:
	var dir := DirAccess.open("res://content/stages/")
	if dir == null: errors.append("STAGE directory missing"); return
	dir.list_dir_begin()
	var file := dir.get_next()
	while not file.is_empty():
		if not dir.current_is_dir() and file.ends_with(".json"):
			var path := "res://content/stages/" + file
			var parsed = _load_json_dictionary(path, "STAGE")
			if not parsed.is_empty(): _validate_stage(parsed, path)
		file = dir.get_next()
	dir.list_dir_end()

func _validate_stage(stage: Dictionary, path: String) -> void:
	var stage_id := str(stage.get("stage_id", ""))
	var order = stage.get("order", null)
	if not (order is int or order is float) or float(order) < 0.0:
		errors.append("STAGE[%s].order is invalid" % path)
	for key in ["stage_id", "order", "name", "map_file", "balance", "encounters"]:
		if not stage.has(key): errors.append("STAGE[%s] missing required field: %s" % [path, key]); return
	var map_file := str(stage.get("map_file", ""))
	if map_file.is_empty() or not FileAccess.file_exists(map_file):
		errors.append("STAGE[%s].map_file is missing or not found: %s" % [path, map_file])
	else:
		_validate_map_file(map_file, path)
	var allied_units = stage.get("allied_units", [])
	if not (allied_units is Array):
		errors.append("STAGE[%s].allied_units must be an array" % path)
	else:
		for allied_index in allied_units.size():
			var allied = allied_units[allied_index]
			if not (allied is Dictionary):
				errors.append("STAGE[%s].allied_units[%d] must be an object" % [path, allied_index]); continue
			var allied_id := str(allied.get("id", ""))
			if allied_id.is_empty() or not _catalog_contains(ALLIED_UNIT_FILE, allied_id):
				errors.append("STAGE[%s].allied_units[%d] references unknown allied unit: %s" % [path, allied_index, allied_id])
			var allied_count = allied.get("count", null)
			if not (allied_count is int or allied_count is float) or float(allied_count) < 0.0:
				errors.append("STAGE[%s].allied_units[%d].count is invalid" % [path, allied_index])
			var spawn := str(allied.get("spawn", "")).strip_edges()
			if spawn.is_empty():
				errors.append("STAGE[%s].allied_units[%d].spawn is required" % [path, allied_index])
			elif spawn != "robot" and not _map_has_allied_spawn(map_file, spawn):
				errors.append("STAGE[%s].allied_units[%d].spawn references unknown map point: %s" % [path, allied_index, spawn])
	var encounters = stage.get("encounters")
	if not (encounters is Array) or encounters.is_empty(): errors.append("STAGE[%s].encounters must be non-empty" % path); return
	for encounter_index in encounters.size():
		var encounter = encounters[encounter_index]
		if not (encounter is Dictionary): errors.append("STAGE[%s].encounters[%d] must be an object" % [path, encounter_index]); continue
		if str(encounter.get("id", "")).is_empty(): errors.append("STAGE[%s].encounters[%d].id is required" % [path, encounter_index])
		var waves = encounter.get("waves")
		if not (waves is Array) or waves.is_empty(): errors.append("STAGE[%s].encounters[%d].waves must be non-empty" % [path, encounter_index]); continue
		for wave_index in waves.size():
			var wave = waves[wave_index]
			if not (wave is Dictionary) or str(wave.get("label", "")).is_empty() or not (wave.get("groups", []) is Array) or wave["groups"].is_empty():
				errors.append("STAGE[%s].encounters[%d].waves[%d] is invalid" % [path, encounter_index, wave_index]); continue
			for group_index in wave["groups"].size():
				var group = wave["groups"][group_index]
				if not (group is Array) or group.size() < 4:
					errors.append("STAGE[%s] group %d/%d/%d is invalid" % [path, encounter_index, wave_index, group_index]); continue
				var enemy_id := str(group[0])
				if enemy_id.is_empty() or not _catalog_contains(ENEMY_FILE, enemy_id):
					errors.append("STAGE[%s] group %d/%d/%d references unknown enemy: %s" % [path, encounter_index, wave_index, group_index, enemy_id])
				if not (group[1] is int or group[1] is float) or float(group[1]) < 0.0:
					errors.append("STAGE[%s] group %d/%d/%d count is invalid" % [path, encounter_index, wave_index, group_index])
				if not (group[2] is int or group[2] is float) or float(group[2]) < 0.0:
					errors.append("STAGE[%s] group %d/%d/%d interval is invalid" % [path, encounter_index, wave_index, group_index])
				if not (group[3] is Array):
					errors.append("STAGE[%s] group %d/%d/%d lanes must be an array" % [path, encounter_index, wave_index, group_index])

func _map_has_allied_spawn(map_file: String, spawn_id: String) -> bool:
	var lookup_id := spawn_id.substr(6) if spawn_id.begins_with("point:") else spawn_id
	var file := FileAccess.open(map_file, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return false
	var robot_spots = parsed.get("robot_spots", {})
	if robot_spots is Dictionary and robot_spots.has(lookup_id):
		return true
	var gameplay_points = parsed.get("gameplay_points", [])
	if gameplay_points is Array:
		for point in gameplay_points:
			if point is Dictionary and bool(point.get("enabled", true)) and str(point.get("type", "")) == "robot_position_point" and str(point.get("id", "")) == lookup_id:
				return true
	return false

func _catalog_contains(path: String, entry_id: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed is Dictionary and parsed.has(entry_id)

func _validate_map_file(map_file: String, stage_path: String) -> void:
	var file := FileAccess.open(map_file, FileAccess.READ)
	if file == null:
		errors.append("MAP referenced by STAGE[%s] cannot be opened: %s" % [stage_path, map_file])
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		errors.append("MAP referenced by STAGE[%s] is not an object: %s" % [stage_path, map_file])
		return
	for key in ["map_id", "name", "map_size", "tile_size", "map_origin", "map_pixel_size", "goal"]:
		if not parsed.has(key):
			errors.append("MAP[%s] missing required field: %s" % [map_file, key])
	_validate_map_vector(parsed, "map_size", map_file, true)
	_validate_map_vector(parsed, "tile_size", map_file, true)
	_validate_map_vector(parsed, "map_origin", map_file, false)
	_validate_map_vector(parsed, "map_pixel_size", map_file, true)
	var goal = parsed.get("goal", {})
	if not (goal is Dictionary):
		errors.append("MAP[%s].goal must be an object" % map_file)
	elif not goal.has("position"):
		errors.append("MAP[%s].goal.position is required" % map_file)
	else:
		_validate_map_vector(goal, "position", map_file, false, "goal")
	for key in ["spawns", "robot_spots", "tower_slots"]:
		if parsed.has(key) and not (parsed[key] is Dictionary):
			errors.append("MAP[%s].%s must be an object" % [map_file, key])
	for key in ["tiles", "objects", "gameplay_areas", "gameplay_points"]:
		if parsed.has(key) and not (parsed[key] is Dictionary or parsed[key] is Array):
			errors.append("MAP[%s].%s has invalid container type" % [map_file, key])

func _validate_map_vector(container: Dictionary, key: String, map_file: String, positive: bool, prefix: String = "") -> void:
	var value = container.get(key, null)
	if not (value is Array) or value.size() < 2:
		errors.append("MAP[%s].%s%s must be an array with 2 values" % [map_file, prefix + "." if not prefix.is_empty() else "", key])
		return
	if positive and (float(value[0]) <= 0.0 or float(value[1]) <= 0.0):
		errors.append("MAP[%s].%s%s must contain positive values" % [map_file, prefix + "." if not prefix.is_empty() else "", key])

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

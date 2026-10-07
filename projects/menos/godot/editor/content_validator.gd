class_name ContentValidator
extends RefCounted

const ROOT := "res://"
const ENEMY_FILE := "enemies"
const ALLIED_UNIT_FILE := "allied_units"
const TOWER_FILE := "towers"
const ROBOT_FILE := "robots"
const SKILL_FILE := "skills"
const GAMEPLAY_FILE := "gameplay"
const CAMPAIGN_FILE := "campaign"
const STAGE_CATALOG_FILE := "stage_catalog"
const MISSION_FILE := "missions"
const REWARD_FILE := "rewards"
const ITEM_FILE := "items"
const VISUAL_ASSET_FILE := "visual_assets"
const VFX_VALIDATOR = preload("res://editor/vfx_validator.gd")
var vfx_validator = VFX_VALIDATOR.new()

var errors: Array[String] = []
var warnings: Array[String] = []

func run() -> Dictionary:
	errors.clear()
	warnings.clear()
	_run()
	return {"valid": errors.is_empty(), "errors": errors.duplicate(), "warnings": warnings.duplicate()}

func _run() -> void:
	_validate_vfx_catalog()
	_validate_visual_asset_catalog()
	_validate_animation_asset_refs()
	_validate_catalog("ENEMY", ENEMY_FILE, ["name", "hp", "speed", "armor", "base_damage", "reward", "radius", "sprite_anim"])
	_validate_catalog("ALLIED_UNIT", ALLIED_UNIT_FILE, ["name", "description", "hp", "speed", "armor", "damage", "cooldown", "range", "radius", "attack_type", "reward", "color", "projectile_anim", "robot_damage", "robot_range", "robot_cooldown", "ai", "visuals"])
	_validate_catalog("TOWER", TOWER_FILE, ["name", "cost", "damage", "cooldown", "range", "preference", "sprite_anim", "level2"])
	_validate_catalog("ROBOT", ROBOT_FILE, ["id", "name", "hp", "speed", "damage", "cooldown", "range", "sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "projectile_anim", "progression", "energy"])
	var skills := _load_catalog_dictionary(SKILL_FILE, "SKILL")
	_validate_skills(skills)
	_validate_gameplay_settings(skills)
	_validate_mission_catalog()
	_validate_reward_catalog()
	_validate_stage_catalog()
	_validate_campaign()
	_validate_stages()
	_validate_resource_refs()

func _validate_vfx_catalog() -> void:
	vfx_validator.validate_vfx_catalog(errors, warnings)

func _validate_visual_asset_catalog() -> void:
	var catalog := _load_catalog_dictionary(VISUAL_ASSET_FILE, "VISUAL_ASSET")
	if catalog.is_empty():
		return
	for asset_id in catalog.keys():
		var entry = catalog[asset_id]
		if not (entry is Dictionary):
			errors.append("VISUAL_ASSET[%s] is not an object" % asset_id)
			continue
		var frames_value = entry.get("frames", null)
		if not (frames_value is int or frames_value is float) or int(frames_value) < 1:
			errors.append("VISUAL_ASSET[%s].frames is invalid" % asset_id)
			continue
		var frames := int(frames_value)
		var source_path := str(entry.get("source", "")).strip_edges()
		if source_path.is_empty() or not ResourceLoader.exists(source_path):
			errors.append("VISUAL_ASSET[%s].source is missing or unresolved: %s" % [asset_id, source_path])
		else:
			var source_texture := ResourceLoader.load(source_path) as Texture2D
			if source_texture == null:
				errors.append("VISUAL_ASSET[%s].source is not a texture: %s" % [asset_id, source_path])
			else:
				var source_size := Vector2(source_texture.get_width(), source_texture.get_height())
				var declared_region: Array = entry.get("region", [])
				if declared_region.size() >= 4:
					var base_region := Rect2(float(declared_region[0]), float(declared_region[1]), float(declared_region[2]), float(declared_region[3]))
					if base_region.size.x <= 0.0 or base_region.size.y <= 0.0 or not Rect2(Vector2.ZERO, source_size).encloses(base_region):
						errors.append("VISUAL_ASSET[%s].region is outside source bounds" % asset_id)
				var mask_data: Variant = entry.get("team_mask", {})
				if mask_data is Dictionary:
					var mask_path := str(mask_data.get("source", "")).strip_edges()
					if not mask_path.is_empty():
						if not ResourceLoader.exists(mask_path):
							errors.append("VISUAL_ASSET[%s].team_mask.source is unresolved: %s" % [asset_id, mask_path])
						else:
							var mask_texture := ResourceLoader.load(mask_path) as Texture2D
							if mask_texture == null or mask_texture.get_width() != source_texture.get_width() or mask_texture.get_height() != source_texture.get_height():
								errors.append("VISUAL_ASSET[%s].team_mask.source size does not match source" % asset_id)
		var frame_regions = entry.get("frame_regions", [])
		if frame_regions == null:
			continue
		if not (frame_regions is Array):
			errors.append("VISUAL_ASSET[%s].frame_regions must be an array" % asset_id)
			continue
		if frame_regions.is_empty():
			continue
		if frame_regions.size() != frames:
			errors.append("VISUAL_ASSET[%s].frame_regions size %d does not match frames %d" % [asset_id, frame_regions.size(), frames])
			continue
		for frame_index in frame_regions.size():
			var values = frame_regions[frame_index]
			if not (values is Array) or values.size() < 4:
				errors.append("VISUAL_ASSET[%s].frame_regions[%d] must be [x, y, width, height]" % [asset_id, frame_index])
				continue
			if not (values[0] is int or values[0] is float) or not (values[1] is int or values[1] is float) or not (values[2] is int or values[2] is float) or not (values[3] is int or values[3] is float):
				errors.append("VISUAL_ASSET[%s].frame_regions[%d] contains non-numeric values" % [asset_id, frame_index])
				continue
			if float(values[2]) <= 0.0 or float(values[3]) <= 0.0:
				errors.append("VISUAL_ASSET[%s].frame_regions[%d] has non-positive size" % [asset_id, frame_index])
				continue
			if source_path.is_empty() or not ResourceLoader.exists(source_path):
				continue
			var frame_rect := Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
			var frame_texture := ResourceLoader.load(source_path) as Texture2D
			if frame_texture != null and not Rect2(Vector2.ZERO, Vector2(frame_texture.get_width(), frame_texture.get_height())).encloses(frame_rect):
				errors.append("VISUAL_ASSET[%s].frame_regions[%d] is outside source bounds" % [asset_id, frame_index])

func _validate_animation_asset_refs() -> void:
	var visual_catalog := _load_catalog_dictionary(VISUAL_ASSET_FILE, "VISUAL_ASSET")
	if visual_catalog.is_empty():
		return
	var robot_catalog := _load_catalog_dictionary(ROBOT_FILE, "ROBOT_ANIMATION")
	for robot_id in robot_catalog.keys():
		var robot = robot_catalog[robot_id]
		if not (robot is Dictionary):
			continue
		var animations: Variant = robot.get("animations", {})
		if animations is Dictionary:
			for animation_name in animations.keys():
				var value := str(animations[animation_name]).strip_edges()
				if value.is_empty():
					continue
				if not value.begins_with("res://") and not visual_catalog.has(value):
					errors.append("ROBOT[%s].animations[%s] references missing Visual Asset: %s" % [robot_id, animation_name, value])

	var allied_catalog := _load_catalog_dictionary(ALLIED_UNIT_FILE, "ALLIED_UNIT_ANIMATION")
	for unit_id in allied_catalog.keys():
		var unit = allied_catalog[unit_id]
		if not (unit is Dictionary):
			continue
		for key in ["projectile_anim"]:
			var value := str(unit.get(key, "")).strip_edges()
			if value.begins_with("res://") or value.is_empty():
				continue
			if not visual_catalog.has(value):
				errors.append("ALLIED_UNIT[%s].%s references missing Visual Asset: %s" % [unit_id, key, value])

func _validate_catalog(label: String, path: String, required: Array[String]) -> void:
	var parsed := ObjectRepository.load_catalog(path)
	if parsed.is_empty():
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
		_validate_geometry(label, str(id), entry)
		for key in entry.keys():
			var value = entry[key]
			if value is float or value is int:
				if float(value) < 0.0:
					errors.append("%s[%s].%s is negative" % [label, id, key])

func _validate_geometry(label: String, object_id: String, entry: Dictionary) -> void:
	if not entry.has("geometry_mode"):
		errors.append("%s[%s] missing required field: geometry_mode" % [label, object_id])
		return
	var mode := str(entry.get("geometry_mode", ""))
	if mode not in ["legacy", "canonical"]:
		errors.append("%s[%s].geometry_mode is invalid: %s" % [label, object_id, mode])
		return
	if mode == "legacy":
		return
	if not entry.has("geometry"):
		errors.append("%s[%s] canonical geometry_mode requires geometry" % [label, object_id])
		return
	var geometry = entry.get("geometry")
	if not (geometry is Dictionary):
		errors.append("%s[%s].geometry must be an object" % [label, object_id])
		return
	if not geometry.has("canonical_body_center"):
		errors.append("%s[%s].geometry missing canonical_body_center" % [label, object_id])
	else:
		var center = geometry.get("canonical_body_center")
		if not _is_numeric_pair(center):
			errors.append("%s[%s].geometry.canonical_body_center must be [x, y] numeric" % [label, object_id])
	var offsets = geometry.get("animation_offsets", null)
	if offsets != null:
		if not (offsets is Dictionary):
			errors.append("%s[%s].geometry.animation_offsets must be an object" % [label, object_id])
		else:
			for animation in offsets.keys():
				if not _is_numeric_pair(offsets[animation]):
					errors.append("%s[%s].geometry.animation_offsets[%s] must be [x, y] numeric" % [label, object_id, animation])

func _is_numeric_pair(value: Variant) -> bool:
	if not (value is Array) or value.size() != 2:
		return false
	for component in value:
		if not (component is int or component is float) or component is bool:
			return false
	return true
func _load_catalog_dictionary(identifier: String, label: String) -> Dictionary:
	var parsed := ContentCatalogLoader.load_dictionary_catalog(identifier)
	if parsed.is_empty():
		errors.append("%s catalog missing or empty in SQLite: %s" % [label, identifier])
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
	var gameplay := _load_catalog_dictionary(GAMEPLAY_FILE, "GAMEPLAY")
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
		if slots[slot] is int or slots[slot] is float:
			skill_id = ContentCatalogLoader.resolve_odb_pk("skill", int(slots[slot]))
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

func _validate_mission_catalog() -> void:
	var missions := _load_catalog_dictionary(MISSION_FILE, "MISSION")
	if missions.is_empty():
		return
	for mission_id in missions.keys():
		var mission = missions[mission_id]
		if not (mission is Dictionary):
			errors.append("MISSION[%s] is not an object" % mission_id)
			continue
		if str(mission.get("id", "")) != str(mission_id):
			errors.append("MISSION[%s].id does not match catalog key" % mission_id)
		for key in ["id", "title", "briefing", "primary_type", "target_id", "time_limit"]:
			if not mission.has(key):
				errors.append("MISSION[%s] missing required field: %s" % [mission_id, key])
		var primary_type := str(mission.get("primary_type", ""))
		if primary_type not in ["defend_base", "clear_encounters", "defeat_giant"]:
			errors.append("MISSION[%s] has unsupported primary_type: %s" % [mission_id, primary_type])
		var time_limit = mission.get("time_limit", null)
		if not (time_limit is int or time_limit is float) or float(time_limit) < 0.0:
			errors.append("MISSION[%s].time_limit is invalid" % mission_id)
		elif primary_type == "defend_base" and float(time_limit) <= 0.0:
			errors.append("MISSION[%s].time_limit must be greater than 0 for defend_base" % mission_id)

func _validate_reward_catalog() -> void:
	var rewards := _load_catalog_dictionary(REWARD_FILE, "REWARD")
	if rewards.is_empty():
		return
	var items := _load_catalog_dictionary(ITEM_FILE, "ITEM")
	for reward_id in rewards.keys():
		var reward = rewards[reward_id]
		if not (reward is Dictionary):
			errors.append("REWARD[%s] is not an object" % reward_id); continue
		if str(reward.get("id", "")) != str(reward_id):
			errors.append("REWARD[%s].id does not match catalog key" % reward_id)
		for key in ["id", "gold", "item_ids"]:
			if not reward.has(key): errors.append("REWARD[%s] missing required field: %s" % [reward_id, key])
		var gold = reward.get("gold", null)
		if not (gold is int or gold is float) or float(gold) < 0.0: errors.append("REWARD[%s].gold is invalid" % reward_id)
		var item_ids = reward.get("item_ids", null)
		if not (item_ids is Array):
			errors.append("REWARD[%s].item_ids must be an array" % reward_id)
		else:
			for item_id in item_ids:
				if str(item_id).is_empty() or not items.has(str(item_id)):
					errors.append("REWARD[%s] references unknown item: %s" % [reward_id, str(item_id)])

func _validate_stage_catalog() -> void:
	var parsed: Dictionary = ContentCatalogLoader.load_document(STAGE_CATALOG_FILE)
	var stages = parsed.get("stages", [])
	if not (stages is Array) or stages.is_empty():
		errors.append("STAGE CATALOG stages must be a non-empty array in SQLite: %s" % STAGE_CATALOG_FILE)
		return
	var seen := {}
	for index in stages.size():
		var stage_id := str(stages[index])
		if stage_id.is_empty() or seen.has(stage_id):
			errors.append("STAGE CATALOG stages[%d] is empty or duplicated: %s" % [index, stage_id])
		elif ContentCatalogLoader.load_document(StageLoader.resolve_stage_path(stage_id)).is_empty():
			errors.append("STAGE CATALOG stages[%d] references missing stage in SQLite: %s" % [index, stage_id])
		seen[stage_id] = true

func _validate_campaign() -> void:
	var parsed: Dictionary = ContentCatalogLoader.load_document(CAMPAIGN_FILE)
	var stages = parsed.get("stages", [])
	if not (stages is Array) or stages.is_empty():
		errors.append("CAMPAIGN stages must be a non-empty array in SQLite: %s" % CAMPAIGN_FILE)
		return
	var catalog_ids := _load_stage_catalog_ids()
	for index in stages.size():
		var stage_id := str(stages[index])
		if stage_id.is_empty() or ContentCatalogLoader.load_document(StageLoader.resolve_stage_path(stage_id)).is_empty():
			errors.append("CAMPAIGN stages[%d] references missing stage in SQLite: %s" % [index, stage_id])
		elif not catalog_ids.has(stage_id):
			errors.append("CAMPAIGN stages[%d] is not present in STAGE CATALOG: %s" % [index, stage_id])

func _load_stage_catalog_ids() -> Dictionary:
	var ids := {}
	var parsed: Dictionary = ContentCatalogLoader.load_document(STAGE_CATALOG_FILE)
	var stages = parsed.get("stages", [])
	if not (stages is Array):
		return ids
	for stage_id in stages:
		var id := str(stage_id)
		if not id.is_empty():
			ids[id] = true
	return ids

func _validate_stages() -> void:
	var catalog: Dictionary = ContentCatalogLoader.load_document(STAGE_CATALOG_FILE)
	var stages = catalog.get("stages", [])
	if not (stages is Array):
		return
	for stage_id in stages:
		var id := str(stage_id)
		var path := StageLoader.resolve_stage_path(id)
		var parsed := ContentCatalogLoader.load_document(path)
		if not parsed.is_empty():
			_validate_stage(parsed, path)

func _validate_stage(stage: Dictionary, path: String) -> void:
	var stage_id := str(stage.get("stage_id", ""))
	var order = stage.get("order", null)
	if not (order is int or order is float) or float(order) < 0.0:
		errors.append("STAGE[%s].order is invalid" % path)
	for key in ["stage_id", "order", "name", "map_file", "balance", "encounters", "mission_id"]:
		if not stage.has(key): errors.append("STAGE[%s] missing required field: %s" % [path, key]); return
	var mission_id := str(stage.get("mission_id", ""))
	var reward_id := str(stage.get("reward_id", ""))
	if mission_id.is_empty() or not _catalog_contains(MISSION_FILE, mission_id):
		errors.append("STAGE[%s].mission_id references unknown mission: %s" % [path, mission_id])
	if reward_id.is_empty() or not _catalog_contains(REWARD_FILE, reward_id):
		errors.append("STAGE[%s].reward_id references unknown reward: %s" % [path, reward_id])
	var map_file := str(stage.get("map_file", ""))
	if map_file.is_empty():
		errors.append("STAGE[%s].map_file is missing: %s" % [path, map_file])
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
			if allied.get("id") is int or allied.get("id") is float:
				allied_id = ContentCatalogLoader.resolve_odb_pk("unit", int(allied.get("id")))
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
	var parsed: Dictionary = MapLoader.load_map_data(map_file)
	if parsed.is_empty():
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
	return ObjectRepository.load_catalog(path).has(entry_id)

func _validate_map_file(map_file: String, stage_path: String) -> void:
	var parsed: Dictionary = MapLoader.load_map_data(map_file)
	if parsed.is_empty():
		errors.append("MAP referenced by STAGE[%s] cannot be loaded from SQLite: %s" % [stage_path, map_file])
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
	_validate_catalog_visual_refs(ENEMY_FILE, ["sprite_anim"], true)
	_validate_catalog_visual_refs(ALLIED_UNIT_FILE, ["visuals.default_image", "visuals.sprite"])
	_validate_catalog_visual_refs(TOWER_FILE, ["sprite_anim", "projectile_anim"])
	_validate_catalog_visual_refs(ROBOT_FILE, ["default_image", "animations.*"])
	for path in [ENEMY_FILE, ALLIED_UNIT_FILE, TOWER_FILE, ROBOT_FILE]:
		_walk_refs(ObjectRepository.load_catalog(path), path)

func _validate_catalog_visual_refs(path: String, fields: Array[String], allow_legacy_sprite_ids: bool = false) -> void:
	var catalog := ObjectRepository.load_catalog(path)
	for entry_id in catalog.keys():
		var entry = catalog[entry_id]
		if not (entry is Dictionary):
			continue
		for field_path in fields:
			if field_path.ends_with(".*"):
				var parent_key := field_path.trim_suffix(".*")
				var parent = entry.get(parent_key, {})
				if parent is Dictionary:
					for child_key in parent.keys():
						_validate_visual_asset_ref(parent[child_key], "%s[%s].%s.%s" % [path, entry_id, parent_key, child_key], allow_legacy_sprite_ids)
			else:
				var value = _get_nested_value(entry, field_path)
				_validate_visual_asset_ref(value, "%s[%s].%s" % [path, entry_id, field_path], allow_legacy_sprite_ids)

func _get_nested_value(value, field_path: String):
	var current = value
	for key in field_path.split("."):
		if not (current is Dictionary) or not current.has(key):
			return null
		current = current[key]
	return current

func _validate_visual_asset_ref(value, source: String, allow_legacy_sprite_id: bool = false) -> void:
	if not (value is String):
		return
	var asset_id: String = value.strip_edges()
	if asset_id.is_empty() or asset_id.begins_with("res://"):
		return
	if VisualAssetRepository.exists(asset_id):
		return
	if allow_legacy_sprite_id and ResourceLoader.exists("res://assets/menos/sprites/%s.png" % asset_id):
		return
	errors.append("Missing visual asset in %s: %s" % [source, asset_id])
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

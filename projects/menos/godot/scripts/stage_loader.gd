class_name StageLoader
extends RefCounted
const STAGE_DIRECTORY := "res://content/stages/"
static func resolve_stage_path(stage_id_or_path: String) -> String:
	if stage_id_or_path.begins_with("res://") or stage_id_or_path.begins_with("user://"):
		return stage_id_or_path
	var normalized := stage_id_or_path.strip_edges()
	if normalized.is_valid_int():
		var resolved := ContentCatalogLoader.resolve_odb_pk("stage", int(normalized))
		if not resolved.is_empty():
			return resolved
	return normalized
static func load_stage_data(stage_id_or_path: String) -> Dictionary:
	var file_path := resolve_stage_path(stage_id_or_path)
	var raw_data: Dictionary = ContentCatalogLoader.load_document(file_path)
	if raw_data.is_empty():
		push_error("StageLoader: Stage data not found in SQLite: %s" % file_path)
		return {}
	return parse_and_validate_raw_data(raw_data, file_path)
static func parse_and_validate_raw_data(raw_data: Dictionary, file_path: String = "") -> Dictionary:
	for key in ["stage_id", "order", "name", "map_file", "balance", "encounters", "mission_id", "reward_id"]:
		if not raw_data.has(key): push_error("StageLoader: Missing required key '%s' in stage data (%s)" % [key, file_path]); return {}
	if str(raw_data["stage_id"]).is_empty() or str(raw_data["name"]).is_empty() or str(raw_data["mission_id"]).is_empty() or str(raw_data["reward_id"]).is_empty():
		push_error("StageLoader: stage_id/name/mission_id must not be empty (%s)" % file_path); return {}
	var mission_ref := str(int(raw_data["mission_id"])) if (raw_data["mission_id"] is int or raw_data["mission_id"] is float) else str(raw_data["mission_id"])
	if MissionDefinitionLoader.load_definition(mission_ref) == null:
		push_error("StageLoader: Referenced mission_id '%s' could not be resolved (%s)" % [mission_ref, file_path]); return {}
	var reward_ref := str(int(raw_data["reward_id"])) if (raw_data["reward_id"] is int or raw_data["reward_id"] is float) else str(raw_data["reward_id"])
	if RewardDefinitionLoader.load_definition(reward_ref) == null:
		push_error("StageLoader: Referenced reward_id '%s' could not be resolved (%s)" % [reward_ref, file_path]); return {}
	if not (raw_data["order"] is int or raw_data["order"] is float): push_error("StageLoader: order must be numeric (%s)" % file_path); return {}
	var map_file_path: String = str(raw_data["map_file"])
	if map_file_path.is_empty(): push_error("StageLoader: Referenced map_file is empty (%s)" % file_path); return {}
	var map_data := MapLoader.load_map_data(map_file_path)
	if map_data.is_empty():
		push_error("StageLoader: Referenced map_file '%s' could not be loaded (%s)" % [map_file_path, file_path])
		return {}
	for key in ["map_tiles", "map_origin", "map_pixel_size", "base"]:
		if not map_data.has(key):
			push_error("StageLoader: Referenced map '%s' is missing required gameplay field '%s' (%s)" % [map_file_path, key, file_path])
			return {}
	if not (map_data["map_tiles"] is Vector2i) or not (map_data["map_origin"] is Vector2) or not (map_data["map_pixel_size"] is Vector2) or not (map_data["base"] is Vector2):
		push_error("StageLoader: Referenced map '%s' has invalid gameplay geometry (%s)" % [map_file_path, file_path])
		return {}
	if map_data["map_tiles"].x <= 0 or map_data["map_tiles"].y <= 0 or map_data["map_pixel_size"].x <= 0.0 or map_data["map_pixel_size"].y <= 0.0:
		push_error("StageLoader: Referenced map '%s' has non-positive gameplay geometry (%s)" % [map_file_path, file_path])
		return {}
	var balance_raw = raw_data.get("balance", null)
	if not (balance_raw is Dictionary): push_error("StageLoader: balance must be a Dictionary in stage (%s)" % file_path); return {}
	var balance_dict: Dictionary = balance_raw
	if not balance_dict.has("initial_gold") or not balance_dict.has("base_hp"): push_error("StageLoader: Balance missing initial_gold/base_hp in stage (%s)" % file_path); return {}
	if not (balance_dict["initial_gold"] is int or balance_dict["initial_gold"] is float) or not (balance_dict["base_hp"] is int or balance_dict["base_hp"] is float):
		push_error("StageLoader: Balance initial_gold/base_hp must be numeric in stage (%s)" % file_path)
		return {}
	if raw_data.has("allied_units"):
		var allied_units = raw_data["allied_units"]
		if not (allied_units is Array):
			push_error("StageLoader: allied_units must be an Array when present (%s)" % file_path)
			return {}
		for allied_index in allied_units.size():
			var allied = allied_units[allied_index]
			if not (allied is Dictionary) or str(allied.get("id", "")).is_empty():
				if not (allied is Dictionary):
					push_error("StageLoader: allied_units[%d] must be an object (%s)" % [allied_index + 1, file_path])
				else:
					push_error("StageLoader: allied_units[%d].id is required (%s)" % [allied_index + 1, file_path])
				return {}
			if allied.get("id") is int or allied.get("id") is float:
				var resolved_unit_id := ContentCatalogLoader.resolve_odb_pk("unit", int(allied.get("id")))
				if resolved_unit_id.is_empty():
					push_error("StageLoader: allied_units[%d].id references unknown unit ODB PK (%s)" % [allied_index + 1, str(allied.get("id"))])
					return {}
				allied["id"] = resolved_unit_id
			var count = allied.get("count", null)
			if not (count is int or count is float) or float(count) < 0.0 or str(allied.get("spawn", "")).is_empty():
				push_error("StageLoader: allied_units[%d] has invalid count/spawn (%s)" % [allied_index + 1, file_path])
				return {}
	var encounters_raw = raw_data.get("encounters", null)
	if not (encounters_raw is Array) or encounters_raw.is_empty(): push_error("StageLoader: encounters must be a non-empty Array in stage (%s)" % file_path); return {}
	for encounter_index in encounters_raw.size():
		var encounter = encounters_raw[encounter_index]
		if not (encounter is Dictionary) or not encounter.has("id") or not encounter.has("waves"): push_error("StageLoader: Encounter %d is invalid in stage (%s)" % [encounter_index + 1, file_path]); return {}
		if str(encounter.get("id", "")).is_empty(): push_error("StageLoader: Encounter %d id must not be empty in stage (%s)" % [encounter_index + 1, file_path]); return {}
		var waves = encounter["waves"]
		if not (waves is Array) or waves.is_empty(): push_error("StageLoader: Encounter %d waves must be non-empty in stage (%s)" % [encounter_index + 1, file_path]); return {}
		for wave_index in waves.size():
			var wave = waves[wave_index]
			if not (wave is Dictionary) or str(wave.get("label", "")).is_empty(): push_error("StageLoader: Encounter %d Wave %d must have a non-empty label" % [encounter_index + 1, wave_index + 1]); return {}
			var groups = wave.get("groups", null)
			if not (groups is Array) or groups.is_empty(): push_error("StageLoader: Encounter %d Wave %d groups must be a non-empty Array" % [encounter_index + 1, wave_index + 1]); return {}
			for group_index in groups.size():
				var group = groups[group_index]
				if not (group is Array) or group.size() < 4: push_error("StageLoader: Encounter %d Wave %d Group %d must contain enemy, count, interval, and lanes" % [encounter_index + 1, wave_index + 1, group_index + 1]); return {}
				if str(group[0]).is_empty() or not (group[1] is int or group[1] is float) or float(group[1]) < 0.0 or not (group[2] is int or group[2] is float) or float(group[2]) < 0.0 or not (group[3] is Array): push_error("StageLoader: Encounter %d Wave %d Group %d has invalid fields" % [encounter_index + 1, wave_index + 1, group_index + 1]); return {}
	var reference_errors := validate_gameplay_references(raw_data, map_data)
	if not reference_errors.is_empty():
		for error in reference_errors:
			push_error("StageLoader: %s (%s)" % [error, file_path])
		return {}
	var parsed := {"stage_id": str(raw_data["stage_id"]), "order": int(raw_data["order"]), "name": str(raw_data["name"]), "map_file": map_file_path, "mission_id": mission_ref, "reward_id": reward_ref, "initial_gold": int(balance_dict["initial_gold"]), "base_hp": float(balance_dict["base_hp"]), "balance": balance_dict.duplicate(true), "encounters": encounters_raw.duplicate(true), }
	if raw_data.has("allied_units"): parsed["allied_units"] = raw_data["allied_units"].duplicate(true)
	if raw_data.has("gameplay"):
		var gameplay_raw: Variant = raw_data["gameplay"]
		if not (gameplay_raw is Dictionary):
			push_error("StageLoader: gameplay must be a Dictionary when present (%s)" % file_path)
			return {}
		var gameplay: Dictionary = gameplay_raw
		for key in ["wave_auto_start_delay", "wave_group_gap"]:
			if gameplay.has(key) and not (gameplay[key] is int or gameplay[key] is float):
				push_error("StageLoader: gameplay.%s must be numeric (%s)" % [key, file_path])
				return {}
			if gameplay.has(key) and float(gameplay[key]) < 0.0:
				push_error("StageLoader: gameplay.%s must not be negative (%s)" % [key, file_path])
				return {}
		parsed["gameplay"] = gameplay.duplicate(true)
	return parsed

static func validate_gameplay_references(stage_data: Dictionary, map_data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var enemy_catalog := ContentCatalogLoader.load_dictionary_catalog("enemies")
	var has_giant := false
	var mission_ref := str(stage_data.get("mission_id", ""))
	if mission_ref.is_valid_int():
		mission_ref = ContentCatalogLoader.resolve_odb_pk("mission", int(mission_ref))
	var mission := MissionDefinitionLoader.load_definition(mission_ref) if not mission_ref.is_empty() else null

	var lane_ids: Dictionary = {}
	var spawn_area_count := 0
	var map_lanes: Variant = map_data.get("lanes", {})
	if map_lanes is Dictionary:
		for lane_id in map_lanes:
			lane_ids[str(lane_id)] = true
	var gameplay_areas: Variant = map_data.get("gameplay_areas", [])
	if gameplay_areas is Array:
		for area in gameplay_areas:
			if not area is Dictionary or not bool(area.get("enabled", true)) or str(area.get("type", "")) != "spawn_area":
				continue
			var position: Variant = area.get("position", [])
			var size: Variant = area.get("size", [])
			if not position is Array or position.size() < 2 or not size is Array or size.size() < 2:
				continue
			lane_ids["spawn_%d" % spawn_area_count] = true
			spawn_area_count += 1
	if lane_ids.is_empty():
		errors.append("Map has no usable enemy spawn lanes: %s" % str(stage_data.get("map_file", "")))

	var encounters: Variant = stage_data.get("encounters", [])
	if encounters is Array:
		for encounter_index in encounters.size():
			var encounter: Variant = encounters[encounter_index]
			if not encounter is Dictionary:
				continue
			var waves: Variant = encounter.get("waves", [])
			if not waves is Array:
				continue
			for wave_index in waves.size():
				var wave: Variant = waves[wave_index]
				if not wave is Dictionary:
					continue
				var groups: Variant = wave.get("groups", [])
				if not groups is Array:
					continue
				for group_index in groups.size():
					var group: Variant = groups[group_index]
					if not group is Array or group.size() < 4:
						continue
					var enemy_id := str(group[0]).strip_edges()
					if enemy_id.is_empty() or not enemy_catalog.has(enemy_id):
						errors.append("Encounter %d Wave %d Group %d references unknown enemy: %s" % [encounter_index + 1, wave_index + 1, group_index + 1, enemy_id])
						continue
					var count_value: Variant = group[1]
					if enemy_id == "giant" and (count_value is int or count_value is float) and float(count_value) > 0.0:
						has_giant = true
					var requested_lanes: Variant = group[3]
					if not requested_lanes is Array:
						continue
					for lane_value in requested_lanes:
						var lane_id := str(lane_value).strip_edges()
						var lane_is_valid := lane_ids.has(lane_id) or (lane_id in ["left", "right"] and spawn_area_count > 0)
						if lane_id.is_empty() or not lane_is_valid:
							errors.append("Encounter %d Wave %d Group %d references unknown map lane: %s" % [encounter_index + 1, wave_index + 1, group_index + 1, lane_id])

	if mission != null and mission.primary_type == "defeat_giant" and not has_giant:
		errors.append("defeat_giant mission requires at least one Giant in the Stage waves")
	return errors

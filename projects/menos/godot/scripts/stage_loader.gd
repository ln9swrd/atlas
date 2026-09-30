class_name StageLoader
extends RefCounted
const STAGE_DIRECTORY := "res://content/stages/"
static func resolve_stage_path(stage_id_or_path: String) -> String:
	if stage_id_or_path.begins_with("res://") or stage_id_or_path.begins_with("user://"):
		return stage_id_or_path
	var filename := stage_id_or_path
	if not filename.ends_with(".json"): filename += ".json"
	return STAGE_DIRECTORY + filename
static func load_stage_data(stage_id_or_path: String) -> Dictionary:
	var file_path := resolve_stage_path(stage_id_or_path)
	if not FileAccess.file_exists(file_path): push_error("StageLoader: Stage data file not found at path: %s" % file_path); return {}
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null: push_error("StageLoader: Failed to open stage file at path: %s" % file_path); return {}
	var json_text := file.get_as_text(); file.close()
	var json := JSON.new(); var parse_result: Error = json.parse(json_text)
	if parse_result != OK: push_error("StageLoader: JSON parse error '%s' at line %d in %s" % [json.get_error_message(), json.get_error_line(), file_path]); return {}
	if not (json.get_data() is Dictionary): push_error("StageLoader: Expected JSON object in stage file (%s)" % file_path); return {}
	return parse_and_validate_raw_data(json.get_data(), file_path)
static func parse_and_validate_raw_data(raw_data: Dictionary, file_path: String = "") -> Dictionary:
	for key in ["stage_id", "order", "name", "map_file", "balance", "encounters"]:
		if not raw_data.has(key): push_error("StageLoader: Missing required key '%s' in stage data (%s)" % [key, file_path]); return {}
	if str(raw_data["stage_id"]).is_empty() or str(raw_data["name"]).is_empty(): push_error("StageLoader: stage_id/name must not be empty (%s)" % file_path); return {}
	if not (raw_data["order"] is int or raw_data["order"] is float): push_error("StageLoader: order must be numeric (%s)" % file_path); return {}
	var map_file_path: String = str(raw_data["map_file"])
	if map_file_path.is_empty() or not FileAccess.file_exists(map_file_path): push_error("StageLoader: Referenced map_file not found on disk: '%s' in stage (%s)" % [map_file_path, file_path]); return {}
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
	var parsed := {"stage_id": str(raw_data["stage_id"]), "order": int(raw_data["order"]), "name": str(raw_data["name"]), "map_file": map_file_path, "initial_gold": int(balance_dict["initial_gold"]), "base_hp": float(balance_dict["base_hp"]), "balance": balance_dict.duplicate(true), "encounters": encounters_raw.duplicate(true), }
	if raw_data.has("allied_units"): parsed["allied_units"] = raw_data["allied_units"].duplicate(true)
	return parsed

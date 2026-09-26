class_name StageLoader
extends RefCounted

const STAGE_DIRECTORY := "res://content/stages/"

static func resolve_stage_path(stage_id_or_path: String) -> String:
	if stage_id_or_path.begins_with("res://") or stage_id_or_path.begins_with("user://"):
		return stage_id_or_path
	var filename := stage_id_or_path
	if not filename.ends_with(".json"):
		filename += ".json"
	return STAGE_DIRECTORY + filename

static func load_stage_data(stage_id_or_path: String) -> Dictionary:
	var file_path := resolve_stage_path(stage_id_or_path)
	if not FileAccess.file_exists(file_path):
		push_error("StageLoader: Stage data file not found at path: %s" % file_path)
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("StageLoader: Failed to open stage file at path: %s" % file_path)
		return {}

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("StageLoader: JSON parse error '%s' at line %d in %s" % [json.get_error_message(), json.get_error_line(), file_path])
		return {}

	if not (json.get_data() is Dictionary):
		push_error("StageLoader: Expected JSON object in stage file (%s)" % file_path)
		return {}

	var raw_data: Dictionary = json.get_data()
	return parse_and_validate_raw_data(raw_data, file_path)

static func parse_and_validate_raw_data(raw_data: Dictionary, file_path: String = "") -> Dictionary:
	var required_keys := ["stage_id", "order", "name", "map_file", "balance", "waves"]
	for key in required_keys:
		if not raw_data.has(key):
			push_error("StageLoader: Missing required key '%s' in stage data (%s)" % [key, file_path])
			return {}

	var map_file_path: String = str(raw_data["map_file"])
	if not FileAccess.file_exists(map_file_path):
		push_error("StageLoader: Referenced map_file not found on disk: '%s' in stage (%s)" % [map_file_path, file_path])
		return {}

	var balance_raw = raw_data.get("balance", null)
	if not (balance_raw is Dictionary):
		push_error("StageLoader: 'balance' field is not a Dictionary in stage (%s)" % file_path)
		return {}
	var balance_dict: Dictionary = balance_raw

	if not balance_dict.has("initial_gold") or not balance_dict.has("base_hp"):
		push_error("StageLoader: Balance dict missing 'initial_gold' or 'base_hp' in stage (%s)" % file_path)
		return {}

	var waves_raw = raw_data.get("waves", null)
	if not (waves_raw is Array):
		push_error("StageLoader: 'waves' field is not an Array in stage (%s)" % file_path)
		return {}
	var waves_list: Array = waves_raw

	if waves_list.is_empty():
		push_warning("StageLoader: Stage waves list is empty in stage (%s)" % file_path)

	var parsed := {
		"stage_id": str(raw_data["stage_id"]),
		"order": int(raw_data["order"]),
		"name": str(raw_data["name"]),
		"map_file": map_file_path,
		"initial_gold": int(balance_dict["initial_gold"]),
		"base_hp": float(balance_dict["base_hp"]),
		"balance": balance_dict.duplicate(true),
		"waves": waves_list.duplicate(true),
		"next_stage_id": str(raw_data.get("next_stage_id", ""))
	}

	return parsed

class_name StageManager
extends RefCounted

static var current_stage_id: String = "stage_01"
static var current_stage_data: Dictionary = {}
static var run_mode: String = "campaign"
static var selected_stage_id: String = "stage_01"
static var campaign_stage_ids: Array[String] = []

static func begin_run(mode: String, stage_id: String = "stage_01") -> void:
	run_mode = mode
	_load_campaign_data()
	selected_stage_id = stage_id
	current_stage_id = stage_id
	current_stage_data = {}

static func _load_campaign_data() -> void:
	campaign_stage_ids.clear()
	var file := FileAccess.open("res://content/campaign/main_campaign.json", FileAccess.READ)
	if file == null:
		push_error("StageManager: Failed to open campaign data.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or not parsed.has("stages") or not parsed["stages"] is Array:
		push_error("StageManager: Invalid campaign data.")
		return
	for stage_id in parsed["stages"]:
		if not str(stage_id).is_empty():
			campaign_stage_ids.append(str(stage_id))

static func get_next_campaign_stage_id() -> String:
	if run_mode != "campaign":
		return ""
	if campaign_stage_ids.is_empty():
		_load_campaign_data()
	var index := campaign_stage_ids.find(current_stage_id)
	if index < 0 or index + 1 >= campaign_stage_ids.size():
		return ""
	return campaign_stage_ids[index + 1]

static func load_stage(stage_id: String) -> Dictionary:
	var loaded_data := StageLoader.load_stage_data(stage_id)
	if loaded_data.is_empty():
		push_error("StageManager: Failed to load stage data for '%s'" % stage_id)
		return {}

	current_stage_id = stage_id
	current_stage_data = loaded_data
	return current_stage_data

static func get_current_stage() -> Dictionary:
	if current_stage_data.is_empty():
		return load_stage(current_stage_id)
	return current_stage_data

static func get_map_file() -> String:
	var stage := get_current_stage()
	return stage.get("map_file", "res://map_data/northbridge_sector_01.json")

static func get_initial_gold() -> int:
	var stage := get_current_stage()
	return stage.get("initial_gold", 180)

static func get_base_hp() -> float:
	var stage := get_current_stage()
	return stage.get("base_hp", 100.0)

static func get_waves() -> Array:
	var stage := get_current_stage()
	return stage.get("waves", [])

static func reset_session() -> void:
	campaign_stage_ids.clear()
	run_mode = "campaign"
	selected_stage_id = "stage_01"
	current_stage_id = "stage_01"
	current_stage_data = {}

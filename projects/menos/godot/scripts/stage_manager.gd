class_name StageManager
extends RefCounted

static var current_stage_id: String = "stage_01"
static var current_stage_data: Dictionary = {}

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
	current_stage_id = "stage_01"
	current_stage_data = {}

class_name CampaignProgressionState
extends RefCounted

var unlocked_stage_ids: Array[String] = []
var completed_stage_ids: Array[String] = []

func reset() -> void:
	unlocked_stage_ids.clear()
	completed_stage_ids.clear()

func load_from_data(data: Dictionary) -> void:
	reset()
	_load_string_array(data.get("unlocked_stage_ids", []), unlocked_stage_ids)
	_load_string_array(data.get("completed_stage_ids", []), completed_stage_ids)
	ensure_initial_stage("stage_01")

func to_data() -> Dictionary:
	return {
		"unlocked_stage_ids": unlocked_stage_ids.duplicate(),
		"completed_stage_ids": completed_stage_ids.duplicate()
	}

func ensure_initial_stage(stage_id: String) -> void:
	if stage_id.is_empty() or unlocked_stage_ids.has(stage_id):
		return
	unlocked_stage_ids.append(stage_id)

func is_stage_unlocked(stage_id: String) -> bool:
	return unlocked_stage_ids.has(stage_id)

func is_stage_completed(stage_id: String) -> bool:
	return completed_stage_ids.has(stage_id)

func complete_stage(stage_id: String, next_stage_id: String = "") -> void:
	if not stage_id.is_empty() and not completed_stage_ids.has(stage_id):
		completed_stage_ids.append(stage_id)
	if not next_stage_id.is_empty() and not unlocked_stage_ids.has(next_stage_id):
		unlocked_stage_ids.append(next_stage_id)

func _load_string_array(value: Variant, target: Array[String]) -> void:
	if not value is Array:
		return
	for entry in value:
		var id := str(entry)
		if not id.is_empty() and not target.has(id):
			target.append(id)

class_name MissionDefinition
extends RefCounted

var id: String = ""
var title: String = ""
var briefing: String = ""
var primary_type: String = "clear_encounters"
var target_id: String = ""
var time_limit: int = 0

func _init(mission_id: String = "", mission_title: String = "") -> void:
	id = mission_id
	title = mission_title

static func from_dict(data: Dictionary, mission_id: String = "") -> MissionDefinition:
	var definition := MissionDefinition.new(str(data.get("id", mission_id)), str(data.get("title", "")))
	definition.briefing = str(data.get("briefing", ""))
	definition.primary_type = str(data.get("primary_type", "clear_encounters"))
	definition.target_id = str(data.get("target_id", ""))
	definition.time_limit = int(data.get("time_limit", 0))
	return definition

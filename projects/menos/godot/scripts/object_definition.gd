class_name ObjectDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var combat: Dictionary = {}
var weapon_refs: Array = []
var skill_refs: Array = []
var visual_refs: Array = []
var specialized: Dictionary = {}
var geometry_mode: String = ""
var geometry: Dictionary = {}

func _init(object_id: String = "", object_name: String = "") -> void:
	id = object_id
	name = object_name

func apply_geometry_from_catalog(data: Dictionary) -> void:
	geometry_mode = str(data.get("geometry_mode", ""))
	var raw_geometry = data.get("geometry", null)
	geometry = raw_geometry.duplicate(true) if raw_geometry is Dictionary else {}

func has_geometry() -> bool:
	return geometry_mode == "canonical"

func get_geometry() -> Dictionary:
	return geometry.duplicate(true)

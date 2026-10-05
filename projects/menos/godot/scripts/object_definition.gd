class_name ObjectDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var combat: Dictionary = {}
var weapon_refs: Array = []
var skill_refs: Array = []
var visual_refs: Array = []
var specialized: Dictionary = {}

func _init(object_id: String = "", object_name: String = "") -> void:
	id = object_id
	name = object_name

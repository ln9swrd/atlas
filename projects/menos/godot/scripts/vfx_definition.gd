class_name VFXDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var category: String = "generic"
var schema_version: int = 1
var revision: int = 1
var status: String = "Draft"
var description: String = ""
var components: Array = []
var timeline: Dictionary = {}
var transform: Dictionary = {}
var parameters: Dictionary = {}
var visual_resource_refs: Array = []
var priority: int = 0
var concurrency: String = "allow_multiple"
var max_instances: int = 0

static func from_dict(data: Dictionary):
	var definition = preload("res://scripts/vfx_definition.gd").new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", definition.id))
	definition.category = str(data.get("category", "generic"))
	definition.schema_version = int(data.get("schema_version", 1))
	definition.revision = maxi(1, int(data.get("revision", 1)))
	definition.status = str(data.get("status", "Draft"))
	definition.description = str(data.get("description", ""))
	definition.components = _array_copy(data.get("components", []))
	definition.timeline = _dictionary_copy(data.get("timeline", {}))
	definition.transform = _dictionary_copy(data.get("transform", {}))
	definition.parameters = _dictionary_copy(data.get("parameters", {}))
	definition.visual_resource_refs = _array_copy(data.get("visual_resource_refs", []))
	definition.priority = int(data.get("priority", 0))
	definition.concurrency = str(data.get("concurrency", "allow_multiple"))
	definition.max_instances = maxi(0, int(data.get("max_instances", 0)))
	return definition

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"category": category,
		"schema_version": schema_version,
		"revision": revision,
		"status": status,
		"description": description,
		"components": components.duplicate(true),
		"timeline": timeline.duplicate(true),
		"transform": transform.duplicate(true),
		"parameters": parameters.duplicate(true),
		"visual_resource_refs": visual_resource_refs.duplicate(true),
		"priority": priority,
		"concurrency": concurrency,
		"max_instances": max_instances
	}

static func _array_copy(value: Variant) -> Array:
	return value.duplicate(true) if value is Array else []

static func _dictionary_copy(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}

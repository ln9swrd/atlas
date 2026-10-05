class_name FactionDefinition
extends RefCounted

var id: String = ""
var name: String = ""

static func from_catalog(data: Dictionary) -> FactionDefinition:
	var definition := FactionDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	return definition

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name
	}

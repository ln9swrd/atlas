class_name FactionDefinition
extends RefCounted

var id: String = ""
var name: String = ""
var color: Color = Color.WHITE

static func from_catalog(data: Dictionary) -> FactionDefinition:
	var definition := FactionDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.name = str(data.get("name", ""))
	definition.color = Color.from_string(str(data.get("color", "ffffffff")), Color.WHITE)
	return definition

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"color": color.to_html(true)
	}

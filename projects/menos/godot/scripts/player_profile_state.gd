class_name PlayerProfileState
extends RefCounted

var robot_progression: RobotProgressionState = RobotProgressionState.new()
var inventory: Array = []
var equipped_items: Dictionary = {
	"weapon": "",
	"armor": "",
	"core": ""
}

func reset() -> void:
	robot_progression.reset()
	inventory.clear()
	equipped_items = {
		"weapon": "",
		"armor": "",
		"core": ""
	}

func load_from_data(data: Dictionary) -> void:
	reset()
	robot_progression.load_from_data(data)
	var saved_inventory: Variant = data.get("inventory", [])
	if saved_inventory is Array:
		inventory = saved_inventory.duplicate(true)
	var saved_equipped: Variant = data.get("equipped_items", equipped_items)
	if saved_equipped is Dictionary:
		equipped_items = saved_equipped.duplicate(true)

func to_data() -> Dictionary:
	var data := robot_progression.to_data()
	data["inventory"] = inventory.duplicate(true)
	data["equipped_items"] = equipped_items.duplicate(true)
	return data

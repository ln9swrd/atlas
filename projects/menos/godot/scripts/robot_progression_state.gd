class_name RobotProgressionState
extends RefCounted

var level: int = 1
var xp: int = 0
var unlocked_abilities: Array[String] = []

func reset() -> void:
	level = 1
	xp = 0
	unlocked_abilities.clear()

func load_from_data(data: Dictionary) -> void:
	level = max(1, int(data.get("level", 1)))
	xp = max(0, int(data.get("xp", 0)))
	unlocked_abilities.clear()
	var unlocked: Variant = data.get("unlocked_abilities", [])
	if unlocked is Array:
		for ability_id in unlocked:
			unlocked_abilities.append(str(ability_id))

func to_data() -> Dictionary:
	return {
		"level": level,
		"xp": xp,
		"unlocked_abilities": unlocked_abilities.duplicate()
	}

func has_ability(ability_id: String) -> bool:
	return unlocked_abilities.has(ability_id)

func unlock_ability(ability_id: String) -> void:
	if not has_ability(ability_id):
		unlocked_abilities.append(ability_id)

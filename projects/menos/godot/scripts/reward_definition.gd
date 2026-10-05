class_name RewardDefinition
extends RefCounted

var id: String = ""
var gold: int = 0
var item_ids: Array[String] = []

func _init(reward_id: String = "") -> void:
	id = reward_id

static func from_dict(data: Dictionary, reward_id: String = "") -> RewardDefinition:
	var definition := RewardDefinition.new(str(data.get("id", reward_id)))
	definition.gold = int(data.get("gold", 0))
	for item_id in data.get("item_ids", []):
		definition.item_ids.append(str(item_id))
	return definition

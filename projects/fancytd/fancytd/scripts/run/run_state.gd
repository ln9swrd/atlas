class_name RunState
extends Node

signal build_changed

var unlocked_tower_ids: Array[String] = []
var tower_damage_modifiers: Dictionary = {}
var ice_slow_bonus: float = 0.0
var lightning_chain_bonus: float = 0.0


func reset(initial_tower_ids: Array[String]) -> void:
	unlocked_tower_ids.clear()
	for tower_id in initial_tower_ids:
		if not unlocked_tower_ids.has(tower_id):
			unlocked_tower_ids.append(tower_id)
	tower_damage_modifiers.clear()
	ice_slow_bonus = 0.0
	lightning_chain_bonus = 0.0
	build_changed.emit()


func unlock_tower(tower_id: String) -> void:
	if tower_id.is_empty() or unlocked_tower_ids.has(tower_id):
		return
	unlocked_tower_ids.append(tower_id)
	build_changed.emit()


func has_tower(tower_id: String) -> bool:
	return unlocked_tower_ids.has(tower_id)


func add_tower_damage(tower_id: String, amount: float) -> void:
	tower_damage_modifiers[tower_id] = float(tower_damage_modifiers.get(tower_id, 0.0)) + amount
	build_changed.emit()


func get_tower_damage_bonus(tower_id: String) -> float:
	return float(tower_damage_modifiers.get(tower_id, 0.0))


func apply_reward(reward: RewardData) -> void:
	if reward == null:
		return
	match reward.reward_type:
		"unlock_tower":
			unlock_tower(reward.target_id)
		"tower_damage":
			add_tower_damage(reward.target_id, reward.value)
		"ice_slow":
			ice_slow_bonus += reward.value
		"lightning_chain":
			lightning_chain_bonus += reward.value
	build_changed.emit()
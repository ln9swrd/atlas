class_name SynergyResolver
extends RefCounted

const THERMAL_SHOCK := "Thermal Shock"
const CONDUCTIVE := "Conductive"


static func active_synergies(run_state: RunState) -> Array[String]:
	var result: Array[String] = []
	if run_state == null:
		return result
	if run_state.has_tower("fire") and run_state.has_tower("ice"):
		result.append(THERMAL_SHOCK)
	if run_state.has_tower("ice") and run_state.has_tower("lightning"):
		result.append(CONDUCTIVE)
	return result


static func damage_multiplier(run_state: RunState, attacker_id: String, target: Node) -> float:
	if run_state == null or target == null:
		return 1.0
	var is_slowed: bool = target.get("slow_remaining") is float and target.get("slow_remaining") > 0.0
	if not is_slowed:
		return 1.0
	if attacker_id == "fire" and run_state.has_tower("fire") and run_state.has_tower("ice"):
		return 1.5
	if attacker_id == "lightning" and run_state.has_tower("ice") and run_state.has_tower("lightning"):
		return 1.35
	return 1.0
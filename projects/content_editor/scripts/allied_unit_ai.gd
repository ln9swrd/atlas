class_name AlliedUnitAI
extends RefCounted

static func update(unit: AlliedUnitRuntimeState, enemies: Array, delta: float, robot: RobotRuntimeState = null, allies: Array[AlliedUnitRuntimeState] = []) -> GameplayEvent:
	if unit == null or unit.definition == null or unit.hp <= 0.0:
		return null
	if str(unit.get_ai_value("role", "combat")) == "support":
		var support_event := _update_support(unit, robot, allies, delta)
		if support_event != null:
			return support_event
	var target := _select_target(unit, enemies)
	unit.target = target
	if target == null:
		return null
	var attack_range := unit.weapon.range if unit.weapon != null else float(unit.get_combat_value("range", 0.0))
	var distance := unit.position.distance_to(target.position)
	if distance > attack_range:
		var speed := float(unit.get_combat_value("speed", 0.0))
		var step := speed * delta
		if distance <= step:
			unit.position = target.position
		else:
			unit.position += unit.position.direction_to(target.position) * step
		return null
	unit.attack_timer = max(0.0, unit.attack_timer - delta)
	if unit.attack_timer > 0.0:
		return null
	unit.attack_timer = max(0.05, unit.weapon.cooldown if unit.weapon != null else float(unit.get_combat_value("cooldown", 0.0)))
	var event := GameplayEvent.create("damage_requested", "allied_unit", unit.id)
	event.target = target
	event.position = target.position
	event.damage = unit.weapon.damage if unit.weapon != null else float(unit.get_combat_value("damage", 0.0))
	event.payload = {"source": unit.type}
	return event

static func _update_support(unit: AlliedUnitRuntimeState, robot: RobotRuntimeState, allies: Array[AlliedUnitRuntimeState], delta: float) -> GameplayEvent:
	unit.support_timer = max(0.0, unit.support_timer - delta)
	if unit.support_timer > 0.0:
		return null
	var support_range := float(unit.get_ai_value("support_range", unit.get_combat_value("range", 0.0)))
	var heal_amount := float(unit.get_combat_value("heal", 0.0))
	var target: Variant = null
	if robot != null and robot.active and robot.hp < robot.max_hp and unit.position.distance_to(robot.position) <= support_range:
		target = robot
	else:
		var best_ratio := 1.0
		for ally in allies:
			if ally == null or ally.hp <= 0.0 or ally == unit or ally.max_hp <= 0.0:
				continue
			var ratio := ally.hp / ally.max_hp
			if ratio < best_ratio and unit.position.distance_to(ally.position) <= support_range:
				best_ratio = ratio
				target = ally
	if target == null:
		return null
	unit.support_timer = max(0.05, float(unit.get_combat_value("support_cooldown", 2.0)))
	var event := GameplayEvent.create("heal_requested", "allied_unit", unit.id)
	event.target = target
	event.position = target.position
	event.heal = heal_amount
	event.payload = {"source": unit.type}
	return event

static func _select_target(unit: AlliedUnitRuntimeState, enemies: Array) -> EnemyRuntimeState:
	var candidates: Array[EnemyRuntimeState] = []
	for enemy in enemies:
		if enemy is EnemyRuntimeState and enemy.hp > 0.0:
			candidates.append(enemy)
	if candidates.is_empty():
		return null
	var preference := str(unit.get_ai_value("target_preference", "front"))
	if preference == "heavy":
		var heavy: Array[EnemyRuntimeState] = []
		for enemy in candidates:
			if enemy.type in ["heavy", "giant"]:
				heavy.append(enemy)
		if not heavy.is_empty():
			candidates = heavy
	elif preference == "fast":
		var fast: Array[EnemyRuntimeState] = []
		for enemy in candidates:
			if enemy.type in ["normal", "rusher"]:
				fast.append(enemy)
		if not fast.is_empty():
			candidates = fast
	candidates.sort_custom(func(a, b): return a.position.x > b.position.x)
	return candidates[0]

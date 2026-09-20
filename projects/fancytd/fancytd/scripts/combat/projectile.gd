extends Node2D

signal hit(target: Node2D)

@export var speed: float = 240.0
@export var hit_distance: float = 8.0

var target: Node2D
var damage: float = 0.0
var has_hit: bool = false
var attacker_id: String = "fire"
var slow_factor: float = 1.0
var slow_duration: float = 0.0
var chain_range: float = 0.0
var chain_damage_ratio: float = 0.0
var enemies_container: Node
var run_state: RunState


func set_target(next_target: Node2D) -> void:
	target = next_target


func set_damage(amount: float) -> void:
	damage = amount


func set_effect(effect_id: String, next_slow_factor: float, next_slow_duration: float, next_chain_range: float, next_chain_damage_ratio: float, next_enemies_container: Node, next_run_state: RunState) -> void:
	attacker_id = effect_id
	slow_factor = next_slow_factor
	slow_duration = next_slow_duration
	chain_range = next_chain_range
	chain_damage_ratio = next_chain_damage_ratio
	enemies_container = next_enemies_container
	run_state = next_run_state

	var visual: Polygon2D = get_node_or_null("Visual") as Polygon2D
	if visual != null:
		match attacker_id:
			"fire":
				visual.color = Color(1.0, 0.45, 0.15)
			"ice":
				visual.color = Color(0.25, 0.85, 1.0)
			"lightning":
				visual.color = Color(1.0, 0.95, 0.25)
			_:
				visual.color = Color(0.96, 0.78, 0.2)

	if is_instance_valid(target):
		var mult := SynergyResolver.damage_multiplier(run_state, attacker_id, target)
		if mult > 1.0:
			scale = Vector2(1.6, 1.6)
			modulate = Color(1.4, 1.4, 1.4, 1.0)


func _physics_process(delta: float) -> void:
	if has_hit:
		return

	if not is_instance_valid(target) or target.get("is_dead") == true or target.get("has_reached_goal") == true:
		queue_free()
		return

	global_position = global_position.move_toward(target.global_position, speed * delta)
	if global_position.distance_to(target.global_position) <= hit_distance:
		_hit()


func _hit() -> void:
	if has_hit:
		return

	has_hit = true
	if is_instance_valid(target):
		hit.emit(target)
		var multiplier := SynergyResolver.damage_multiplier(run_state, attacker_id, target)
		if target.has_method("apply_damage"):
			target.apply_damage(damage * multiplier)
		if attacker_id == "ice" and target.has_method("apply_slow"):
			target.apply_slow(slow_factor, slow_duration)
		if attacker_id == "lightning":
			_chain_hit(target)
	queue_free()


func _chain_hit(primary_target: Node2D) -> void:
	if enemies_container == null or chain_range <= 0.0 or chain_damage_ratio <= 0.0:
		return
	var closest: Node2D
	var closest_distance := chain_range
	for child in enemies_container.get_children():
		if child == primary_target or not child is Node2D or child.get("is_dead") == true:
			continue
		var distance := primary_target.global_position.distance_to(child.global_position)
		if distance <= closest_distance:
			closest = child
			closest_distance = distance
	if closest != null and closest.has_method("apply_damage"):
		var multiplier := SynergyResolver.damage_multiplier(run_state, attacker_id, closest)
		closest.apply_damage(damage * chain_damage_ratio * multiplier)

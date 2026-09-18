extends Node2D

signal hit(target: Node2D)

@export var speed: float = 240.0
@export var hit_distance: float = 8.0

var target: Node2D
var damage: float = 0.0
var has_hit: bool = false


func set_target(next_target: Node2D) -> void:
	target = next_target


func set_damage(amount: float) -> void:
	damage = amount


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
		if target.has_method("apply_damage"):
			target.apply_damage(damage)
	queue_free()

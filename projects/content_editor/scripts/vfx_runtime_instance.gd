class_name VFXRuntimeInstance
extends RefCounted

const AdapterScript = preload("res://scripts/vfx_runtime_adapter.gd")

var adapter = AdapterScript.new()
var instance_id := ""
var context: Dictionary = {}
var source_effect: Dictionary = {}
var active := false

func configure(instance_definition, instance_context: Dictionary = {}) -> void:
	context = instance_context.duplicate(true)
	instance_id = str(context.get("instance_id", ""))
	adapter.configure(instance_definition)
	_sync_context_to_adapter()
	active = false

func bind_effect(effect: Dictionary) -> void:
	source_effect = effect

func play() -> void:
	_sync_context_to_adapter()
	adapter.play()
	active = true

func stop() -> void:
	adapter.stop()
	active = false

func tick(delta: float) -> void:
	if not active:
		return
	_sync_context_to_adapter()
	if not source_effect.is_empty() and float(source_effect.get("progress", 0.0)) >= 1.0:
		adapter.seek(adapter.duration())
		active = false
		return
	adapter.tick(delta)
	if adapter.is_complete():
		active = false

func seek(value: float) -> void:
	adapter.seek(value)
	active = false

func is_complete() -> bool:
	return not active and adapter.is_complete()

func render_commands() -> Array:
	return adapter.render_commands()

func _sync_context_to_adapter() -> void:
	var overrides: Dictionary = {}
	if not source_effect.is_empty():
		var start: Vector2 = source_effect.get("start", Vector2.ZERO)
		var target: Vector2 = source_effect.get("target", start)
		var progress := clampf(float(source_effect.get("progress", 0.0)), 0.0, 1.0)
		overrides["position"] = start.lerp(target, progress)
		overrides["rotation"] = start.angle_to_point(target)
	elif context.get("position", null) is Vector2:
		overrides["position"] = context["position"]
	adapter.instance_overrides = overrides

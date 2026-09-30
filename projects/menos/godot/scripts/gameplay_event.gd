class_name GameplayEvent
extends RefCounted

var type: String = ""
var source: String = ""
var source_id: String = ""
var target: Variant = null
var position: Vector2 = Vector2.ZERO
var damage: float = 0.0
var payload: Dictionary = {}

static func create(event_type: String, event_source: String = "", event_source_id: String = "") -> GameplayEvent:
	var event := GameplayEvent.new()
	event.type = event_type
	event.source = event_source
	event.source_id = event_source_id
	return event

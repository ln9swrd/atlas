class_name VoiceDefinition
extends RefCounted
var id := ""
var dialogue_id := ""
var voice_profile_id := ""
var voice_asset := ""
var language := "ko"
var volume := 1.0
var bus := "Master"
var priority := 0
var status := "Draft"
static func from_dict(data: Dictionary):
	var d = preload("res://scripts/voice_definition.gd").new()
	d.id = str(data.get("id", ""))
	d.dialogue_id = str(data.get("dialogue_id", ""))
	d.voice_profile_id = str(data.get("voice_profile_id", ""))
	d.voice_asset = str(data.get("voice_asset", ""))
	d.language = str(data.get("language", "ko"))
	d.volume = clampf(float(data.get("volume", 1.0)), 0.0, 2.0)
	d.bus = str(data.get("bus", "Master"))
	d.priority = int(data.get("priority", 0))
	d.status = str(data.get("status", "Draft"))
	return d
func to_dict() -> Dictionary:
	return {"id":id,"dialogue_id":dialogue_id,"voice_profile_id":voice_profile_id,"voice_asset":voice_asset,"language":language,"volume":volume,"bus":bus,"priority":priority,"status":status}

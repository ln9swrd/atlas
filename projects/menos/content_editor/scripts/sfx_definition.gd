class_name SFXDefinition
extends RefCounted

var id := ""
var name := ""
var category := "generic"
var schema_version := 1
var revision := 1
var status := "Draft"
var audio_asset := ""
var variants: Array = []
var volume := 1.0
var pitch := 1.0
var bus := "SFX"
var playback := "one_shot"
var spatial_mode := "screen"
var priority := 0
var concurrency := "allow_multiple"
var max_instances := 0
var steal_policy := "oldest"
var cooldown := 0.0

static func from_dict(data: Dictionary):
	var d = preload("res://scripts/sfx_definition.gd").new()
	d.id = str(data.get("id", ""))
	d.name = str(data.get("name", d.id))
	d.category = str(data.get("category", "generic"))
	d.schema_version = int(data.get("schema_version", 1))
	d.revision = maxi(1, int(data.get("revision", 1)))
	d.status = str(data.get("status", "Draft"))
	d.audio_asset = str(data.get("audio_asset", ""))
	d.variants = data.get("variants", []).duplicate(true) if data.get("variants", []) is Array else []
	d.volume = maxf(0.0, float(data.get("volume", 1.0)))
	d.pitch = maxf(0.01, float(data.get("pitch", 1.0)))
	d.bus = str(data.get("bus", "SFX"))
	d.playback = str(data.get("playback", "one_shot"))
	d.spatial_mode = str(data.get("spatial_mode", "screen"))
	d.priority = int(data.get("priority", 0))
	d.concurrency = str(data.get("concurrency", "allow_multiple"))
	d.max_instances = maxi(0, int(data.get("max_instances", 0)))
	d.steal_policy = str(data.get("steal_policy", "oldest"))
	d.cooldown = maxf(0.0, float(data.get("cooldown", 0.0)))
	return d

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "category": category, "schema_version": schema_version,
		"revision": revision, "status": status, "audio_asset": audio_asset,
		"variants": variants.duplicate(true), "volume": volume, "pitch": pitch,
		"bus": bus, "playback": playback, "spatial_mode": spatial_mode,
		"priority": priority, "concurrency": concurrency, "max_instances": max_instances,
		"steal_policy": steal_policy, "cooldown": cooldown
	}

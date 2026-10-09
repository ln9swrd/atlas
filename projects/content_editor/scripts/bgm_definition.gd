class_name BGMDefinition
extends RefCounted

var id := ""
var name := ""
var faction := ""
var context := ""
var schema_version := 1
var revision := 1
var status := "Draft"
var audio_asset := ""
var loop := true
var loop_point := 0.0
var duration := 0.0
var bpm := 0.0
var transition := "crossfade"
var crossfade_seconds := 1.0
var volume := 1.0
var bus := "BGM"
var priority := 0
var variant := ""
var approval_status := "UNVERIFIED"
var production_lock := false

static func from_dict(data: Dictionary):
	var d = preload("res://scripts/bgm_definition.gd").new()
	d.id = str(data.get("id", ""))
	d.name = str(data.get("name", d.id))
	d.faction = str(data.get("faction", ""))
	d.context = str(data.get("context", ""))
	d.schema_version = int(data.get("schema_version", 1))
	d.revision = maxi(1, int(data.get("revision", 1)))
	d.status = str(data.get("status", "Draft"))
	d.audio_asset = str(data.get("audio_asset", ""))
	d.loop = bool(data.get("loop", true))
	d.loop_point = maxf(0.0, float(data.get("loop_point", 0.0)))
	d.duration = maxf(0.0, float(data.get("duration", 0.0)))
	d.bpm = maxf(0.0, float(data.get("bpm", 0.0)))
	d.transition = str(data.get("transition", "crossfade"))
	d.crossfade_seconds = maxf(0.0, float(data.get("crossfade_seconds", 1.0)))
	d.volume = maxf(0.0, float(data.get("volume", 1.0)))
	d.bus = str(data.get("bus", "BGM"))
	d.priority = int(data.get("priority", 0))
	d.variant = str(data.get("variant", ""))
	d.approval_status = str(data.get("approval_status", "UNVERIFIED"))
	d.production_lock = bool(data.get("production_lock", false))
	return d

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "faction": faction, "context": context,
		"schema_version": schema_version, "revision": revision, "status": status,
		"audio_asset": audio_asset, "loop": loop, "loop_point": loop_point,
		"duration": duration, "bpm": bpm, "transition": transition,
		"crossfade_seconds": crossfade_seconds, "volume": volume, "bus": bus,
		"priority": priority, "variant": variant,
		"approval_status": approval_status, "production_lock": production_lock
	}

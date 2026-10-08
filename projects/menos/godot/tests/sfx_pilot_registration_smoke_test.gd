extends SceneTree

const SFXRepositoryScript = preload("res://scripts/sfx_definition_repository.gd")
const SFXAdapterScript = preload("res://scripts/sfx_runtime_adapter.gd")

const DB_PATH := "res://content/menos.sqlite"
const SFX_ID := "ROBOT_LASER_FIRE"
const RAW_JSON := """{
  "id":"ROBOT_LASER_FIRE",
  "name":"Robot Laser Fire",
  "category":"robot_combat",
  "schema_version":1,
  "revision":1,
  "status":"Pilot",
  "audio_asset":"res://sound/ROBOT_LASER_FIRE.wav",
  "variants":[],
  "volume":0.8,
  "pitch":1.0,
  "bus":"SFX",
  "playback":"one_shot",
  "spatial_mode":"screen",
  "priority":0,
  "concurrency":"allow_multiple",
  "max_instances":4,
  "steal_policy":"oldest",
  "cooldown":0.0
}"""

func _init() -> void:
	var db = SQLite.new()
	db.path = DB_PATH
	db.read_only = false
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		print("SFX_PILOT_DB_FAIL open")
		quit(1)
		return
	if not db.query("CREATE TABLE IF NOT EXISTS sfx_definitions (id TEXT PRIMARY KEY, raw_json TEXT NOT NULL)"):
		print("SFX_PILOT_DB_FAIL create")
		db.close_db()
		quit(1)
		return
	if not db.query_with_bindings("INSERT OR REPLACE INTO sfx_definitions(id, raw_json) VALUES(?, ?)", [SFX_ID, RAW_JSON]):
		print("SFX_PILOT_DB_FAIL insert")
		db.close_db()
		quit(1)
		return
	db.close_db()
	SFXRepositoryScript.reload()
	var definition = SFXRepositoryScript.get_definition(SFX_ID)
	if definition == null:
		print("SFX_PILOT_FAIL loader")
		quit(1)
		return
	var adapter = SFXAdapterScript.new()
	adapter.configure(definition)
	if not adapter.is_valid() or adapter.resolve_stream() == null:
		print("SFX_PILOT_FAIL adapter")
		quit(1)
		return
	print("SFX_PILOT_DEFINITION_PASS")
	quit(0)

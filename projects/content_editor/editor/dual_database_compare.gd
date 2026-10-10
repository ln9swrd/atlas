extends Window

const CONTENT_DB_PATH := "res://data/content_editor.sqlite"
const SETTINGS_PATH := "user://menos_settings.cfg"
const REGISTRY_DB_PATH := "res://data/runtime_registry.sqlite"
const RUNTIME_STATUS_TOOL := "res://tools/runtime_config_status.py"
const TABLES_BY_SCENE := {
	"res://editor/mission_editor.tscn": {"table": "missions", "label": "Mission"},
	"res://editor/faction_editor.tscn": {"table": "factions", "label": "Faction"},
	"res://editor/building_editor.tscn": {"table": "buildings", "label": "Building"},
	"res://editor/skill_editor.tscn": {"table": "skills", "label": "Skill"},
	"res://editor/vfx_editor.tscn": {"table": "vfx_definitions", "label": "VFX"},
	"res://editor/sfx_editor.tscn": {"table": "sfx_definitions", "label": "SFX"},
	"res://editor/bgm_editor.tscn": {"table": "bgm_definitions", "label": "BGM"},
	"res://editor/voice_editor.tscn": {"table": "voice_definitions", "label": "Voice"}
}

var table_name := ""
var editor_label := ""
var left_path_label: Label
var right_path_label: Label
var left_data: TextEdit
var right_data: TextEdit
var status_label: Label
var runtime_context_label: Label

func configure_for_scene(scene_path: String) -> bool:
	var spec: Dictionary = TABLES_BY_SCENE.get(scene_path, {})
	if spec.is_empty():
		return false
	table_name = str(spec["table"])
	editor_label = str(spec["label"])
	return true

func _ready() -> void:
	title = "Content DB / Runtime DB Comparison"
	size = Vector2i(1280, 780)
	min_size = Vector2i(900, 560)
	_build_ui()
	_load_both_databases()
	close_requested.connect(queue_free)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var heading := Label.new()
	heading.text = "%s data | two independent read-only SQLite connections" % editor_label
	heading.add_theme_font_size_override("font_size", 16)
	root.add_child(heading)

	var runtime_context_heading := Label.new()
	runtime_context_heading.text = "RuntimeContext (read-only)"
	runtime_context_heading.add_theme_font_size_override("font_size", 14)
	root.add_child(runtime_context_heading)
	runtime_context_label = Label.new()
	runtime_context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	runtime_context_label.text = "Runtime status has not been queried."
	root.add_child(runtime_context_label)

	var split := HSplitContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size.x = 360
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(left_column)
	var left_heading := Label.new()
	left_heading.text = "LEFT - Content Editor DB"
	left_column.add_child(left_heading)
	left_path_label = Label.new()
	left_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_column.add_child(left_path_label)
	left_data = TextEdit.new()
	left_data.editable = false
	left_data.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_data.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_data.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	left_column.add_child(left_data)

	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size.x = 360
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(right_column)
	var right_heading := Label.new()
	right_heading.text = "RIGHT - Selected Runtime DB"
	right_column.add_child(right_heading)
	right_path_label = Label.new()
	right_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_column.add_child(right_path_label)
	right_data = TextEdit.new()
	right_data.editable = false
	right_data.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_data.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_data.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	right_column.add_child(right_data)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(actions)
	var refresh := Button.new()
	refresh.text = "Refresh"
	refresh.pressed.connect(_load_both_databases)
	actions.add_child(refresh)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(queue_free)
	actions.add_child(close_button)

func _load_both_databases() -> void:
	var content_path := ProjectSettings.globalize_path(CONTENT_DB_PATH)
	var runtime_context := _read_runtime_context()
	var runtime_path := ""
	if str(runtime_context.get("status", "")) == "PASS":
		var project_root := str(runtime_context.get("project_root", ""))
		if not project_root.is_empty():
			runtime_path = project_root.path_join("content").path_join("menos.sqlite")
	_update_runtime_context_label(runtime_context)
	left_path_label.text = content_path
	right_path_label.text = runtime_path if not runtime_path.is_empty() else "No usable enabled Runtime target selected."

	if runtime_path.is_empty():
		left_data.text = "ERROR: Runtime target is not selected or RuntimeContext query failed."
		right_data.text = "Review the RuntimeContext status above and select an enabled Runtime in Runtime Targets manager."
		status_label.text = "Both database handles were not opened because RuntimeContext could not resolve an enabled target."
		return

	var content_db = _open_read_only_database(content_path, "Content Editor")
	if content_db == null:
		left_data.text = "ERROR: Could not open Content Editor DB.\n" + content_path
		right_data.text = "Runtime DB was not opened because the Content Editor DB failed."
		status_label.text = "Database comparison aborted."
		return

	var runtime_db = _open_read_only_database(runtime_path, "Runtime")
	if runtime_db == null:
		left_data.text = "Content Editor DB opened successfully, but Runtime DB could not be opened."
		right_data.text = "ERROR: Could not open Runtime DB.\n" + runtime_path
		content_db.close_db()
		status_label.text = "Database comparison aborted."
		return

	# Keep both independent read-only handles open at the same time during both queries.
	left_data.text = _read_table_from_handle(content_db, content_path)
	right_data.text = _read_table_from_handle(runtime_db, runtime_path)
	runtime_db.close_db()
	content_db.close_db()
	status_label.text = "Read complete: %s | Both independent read-only SQLite handles were open simultaneously." % table_name

func _read_runtime_context() -> Dictionary:
	var settings := ConfigFile.new()
	var selected_id := 0
	if settings.load(SETTINGS_PATH) == OK:
		selected_id = int(settings.get_value("runtime", "selected_runtime_id", 0))
	var registry_path := ProjectSettings.globalize_path(REGISTRY_DB_PATH)
	var tool_path := ProjectSettings.globalize_path(RUNTIME_STATUS_TOOL)
	var appdata := OS.get_environment("APPDATA")
	if appdata.is_empty():
		return {"status": "FAIL", "state": "USERDATA_BASE_UNAVAILABLE", "error": "APPDATA environment variable is unavailable."}
	var userdata_base := appdata.path_join("Godot").path_join("app_userdata")
	var args := PackedStringArray([
		tool_path,
		"--registry-db", registry_path,
		"--selected-runtime-id", str(selected_id),
		"--userdata-base", userdata_base
	])
	var output: Array = []
	var exit_code := OS.execute("python", args, output, false)
	if exit_code == -1:
		output.clear()
		var fallback_args := PackedStringArray(["-3"])
		fallback_args.append_array(args)
		exit_code = OS.execute("py", fallback_args, output, false)
	if output.is_empty():
		return {"status": "FAIL", "state": "STATUS_QUERY_FAILED", "error": "RuntimeContext query produced no output (exit %d)." % exit_code}
	var parsed: Variant = JSON.parse_string("\n".join(PackedStringArray(output)).strip_edges())
	if not (parsed is Dictionary):
		return {"status": "FAIL", "state": "STATUS_QUERY_INVALID_JSON", "error": "RuntimeContext query did not return a JSON object."}
	return parsed

func _update_runtime_context_label(context: Dictionary) -> void:
	var state := str(context.get("state", ""))
	if str(context.get("status", "")) != "PASS":
		runtime_context_label.text = "RuntimeContext ERROR | %s | %s" % [state, str(context.get("error", ""))]
		return
	var lines := PackedStringArray()
	lines.append("Runtime: %s (ID %s)" % [str(context.get("runtime_name", "Unknown")), str(context.get("selected_runtime_id", "?"))])
	lines.append("Identity: %s" % str(context.get("runtime_identity", "")))
	lines.append("Project: %s" % str(context.get("project_root", "")))
	lines.append("Config: %s | %s" % [str(context.get("config_state", "UNKNOWN")), str(context.get("config_path", ""))])
	lines.append("Package: %s" % (str(context.get("package_root", "")) if bool(context.get("configured", false)) else "(not configured)"))
	lines.append("Integrity: %s" % str(context.get("package_state", "UNKNOWN")))
	runtime_context_label.text = "\n".join(lines)

func _open_read_only_database(database_path: String, _source_label: String):
	if not FileAccess.file_exists(database_path):
		return null
	var db = SQLite.new()
	db.path = database_path
	db.read_only = true
	db.foreign_keys = true
	db.verbosity_level = 0
	if not db.open_db():
		return null
	return db

func _read_table_from_handle(db, database_path: String) -> String:
	var escaped_table := table_name.replace("\"", "\"\"")
	var ok: bool = db.query('SELECT * FROM "%s"' % escaped_table)
	if not ok:
		return "Table query failed: %s\n%s" % [table_name, database_path]
	var rows: Array = db.query_result.duplicate(true)
	var records: Array = []
	for row in rows:
		var record: Dictionary = {}
		for key in row.keys():
			var value = row[key]
			if str(key) == "raw_json" and value is String:
				var parsed = JSON.parse_string(value)
				record["data"] = parsed if parsed != null else value
			else:
				record[str(key)] = value
		records.append(record)
	return "Table: %s\nRows: %d\n\n%s" % [table_name, records.size(), JSON.stringify(records, "  ")]

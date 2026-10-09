extends Control

const ImageEditorState = preload("res://editor/image_editor_state.gd")

const MAP_EDITOR_SCENE := "res://editor/map_editor.tscn"
const STAGE_EDITOR_SCENE := "res://editor/stage_editor.tscn"
const UNIT_EDITOR_SCENE := "res://editor/unit_editor.tscn"
const TOWER_EDITOR_SCENE := "res://editor/tower_editor.tscn"
const BUILDING_EDITOR_SCENE := "res://editor/building_editor.tscn"
const ROBOT_EDITOR_SCENE := "res://editor/robot_editor.tscn"
const IMAGE_EDITOR_SCENE := "res://editor/image_editor.tscn"
const FACTION_EDITOR_SCENE := "res://editor/faction_editor.tscn"
const SKILL_EDITOR_SCENE := "res://editor/skill_editor.tscn"
const MISSION_EDITOR_SCENE := "res://editor/mission_editor.tscn"
const CAMPAIGN_EDITOR_SCENE := "res://editor/campaign_editor.tscn"
const VFX_EDITOR_SCENE := "res://editor/vfx_editor.tscn"
const SFX_EDITOR_SCENE := "res://editor/sfx_editor.tscn"
const VOICE_EDITOR_SCENE := "res://editor/voice_editor.tscn"
const BGM_EDITOR_SCENE := "res://editor/bgm_editor.tscn"
const SETTINGS_DIALOG_SCENE := "res://editor/editor_settings_dialog.tscn"
const RUNTIME_TARGETS_SCENE := "res://editor/runtime_targets_manager.tscn"
const DATABASE_COMPARE_SCRIPT := preload("res://editor/dual_database_compare.gd")


var current_editor: Node = null
var content_host: Control
var current_editor_scene := ""
var previous_editor_scene := MAP_EDITOR_SCENE
var _runtime_import_source := ""
var _runtime_import_preview: Dictionary = {}
var _runtime_import_file_dialog: FileDialog
var _runtime_import_confirm: ConfirmationDialog
var _runtime_import_result: AcceptDialog
var _runtime_data_menu: PopupMenu
var _publish_runtime_root_dialog: FileDialog
var _runtime_launch_root_dialog: FileDialog
var _publish_output_parent_dialog: FileDialog
var _publish_confirm: ConfirmationDialog
var _publish_result: AcceptDialog
var _publish_runtime_root := ""
var _publish_output_path := ""
const SETTINGS_PATH := "user://menos_settings.cfg"

func _ready() -> void:
	_apply_editor_theme()
	_setup_language()
	content_host = $MainLayout/Content
	$MainLayout/TopMenu/Buttons/BtnMap.pressed.connect(_open_map_editor)
	$MainLayout/TopMenu/Buttons/BtnStage.pressed.connect(_open_stage_editor)
	$MainLayout/TopMenu/Buttons/BtnUnit.pressed.connect(_open_unit_editor)
	$MainLayout/TopMenu/Buttons/BtnTower.pressed.connect(_open_tower_editor)
	$MainLayout/TopMenu/Buttons/BtnBuilding.pressed.connect(_open_building_editor)
	$MainLayout/TopMenu/Buttons/BtnRobot.pressed.connect(_open_robot_editor)
	$MainLayout/TopMenu/Buttons/BtnCatalog.pressed.connect(_open_image_editor)
	$MainLayout/TopMenu/Buttons/BtnFaction.pressed.connect(_open_faction_editor)
	$MainLayout/TopMenu/Buttons/BtnSkill.pressed.connect(_open_skill_editor)
	$MainLayout/TopMenu/Buttons/BtnMission.pressed.connect(_open_mission_editor)
	$MainLayout/TopMenu/Buttons/BtnCampaign.pressed.connect(_open_campaign_editor)
	$MainLayout/TopMenu/Buttons/BtnVFX.pressed.connect(_open_vfx_editor)
	$MainLayout/TopMenu/Buttons/BtnSFX.pressed.connect(_open_sfx_editor)
	$MainLayout/TopMenu/Buttons/BtnVoice.pressed.connect(_open_voice_editor)
	$MainLayout/TopMenu/Buttons/BtnBGM.pressed.connect(_open_bgm_editor)
	$MainLayout/TopMenu/Buttons/BtnSettings.pressed.connect(_open_settings_dialog)
	$MainLayout/RuntimeToolbar/Actions/BtnRuntimeMenu.pressed.connect(_open_runtime_targets_manager)
	$MainLayout/RuntimeToolbar/Actions/BtnDatabaseCompare.pressed.connect(_open_database_compare)
	_setup_runtime_import_ui()
	_refresh_runtime_button_label()
	_open_map_editor()

func _setup_language() -> void:
	EditorSettingsManager.initialize()
	var language_option: OptionButton = $MainLayout/TopMenu/Buttons/LanguageOption
	language_option.select(0 if EditorSettingsManager.language == "ko" else 1)
	language_option.item_selected.connect(_on_language_selected)

func _on_language_selected(index: int) -> void:
	EditorSettingsManager.set_language("ko" if index == 0 else "en")

func _open_settings_dialog() -> void:
	var packed := load(SETTINGS_DIALOG_SCENE) as PackedScene
	if packed == null:
		push_error("Could not load editor settings dialog.")
		return
	var dialog := packed.instantiate() as Window
	add_child(dialog)
	dialog.tree_exited.connect(_sync_language_option)
	dialog.popup_centered()

func _sync_language_option() -> void:
	var language_option: OptionButton = $MainLayout/TopMenu/Buttons/LanguageOption
	language_option.select(0 if EditorSettingsManager.language == "ko" else 1)

func _apply_editor_theme() -> void:
	var editor_theme := Theme.new()
	editor_theme.default_font_size = 10
	var text_color := Color("#e6eee9")
	var muted_text_color := Color("#aab9b1")
	var panel_color := Color("#202a28")
	var control_color := Color("#2b3734")
	var border_color := Color("#465650")
	var accent_color := Color("#4d9b86")
	editor_theme.set_color("font_color", "Label", text_color)
	editor_theme.set_color("font_color", "Button", text_color)
	editor_theme.set_color("font_hover_color", "Button", Color("#ffffff"))
	editor_theme.set_color("font_pressed_color", "Button", Color("#ffffff"))
	editor_theme.set_color("font_disabled_color", "Button", muted_text_color)
	editor_theme.set_color("font_color", "LineEdit", text_color)
	editor_theme.set_color("font_placeholder_color", "LineEdit", muted_text_color)
	editor_theme.set_color("font_color", "OptionButton", text_color)
	editor_theme.set_color("font_color", "SpinBox", text_color)
	editor_theme.set_color("font_color", "CheckButton", text_color)

	var panel := _make_editor_style(panel_color, border_color, 1, 8)
	editor_theme.set_stylebox("panel", "PanelContainer", panel)
	editor_theme.set_stylebox("normal", "Button", _make_editor_style(control_color, border_color, 1, 5))
	editor_theme.set_stylebox("hover", "Button", _make_editor_style(Color("#374641"), accent_color, 1, 5))
	editor_theme.set_stylebox("pressed", "Button", _make_editor_style(Color("#245c50"), accent_color, 1, 5))
	editor_theme.set_stylebox("focus", "Button", _make_editor_style(Color("#00000000"), accent_color, 2, 5))
	editor_theme.set_stylebox("disabled", "Button", _make_editor_style(Color("#252e2c"), Color("#394440"), 1, 5))
	editor_theme.set_stylebox("normal", "LineEdit", _make_editor_style(Color("#18211f"), border_color, 1, 4))
	editor_theme.set_stylebox("focus", "LineEdit", _make_editor_style(Color("#18211f"), accent_color, 2, 4))
	editor_theme.set_stylebox("read_only", "LineEdit", _make_editor_style(Color("#252e2c"), Color("#394440"), 1, 4))
	editor_theme.set_stylebox("normal", "OptionButton", _make_editor_style(Color("#2b3734"), border_color, 1, 4))
	editor_theme.set_stylebox("hover", "OptionButton", _make_editor_style(Color("#374641"), accent_color, 1, 4))
	editor_theme.set_stylebox("pressed", "OptionButton", _make_editor_style(Color("#245c50"), accent_color, 1, 4))
	editor_theme.set_stylebox("panel", "TabContainer", _make_editor_style(panel_color, border_color, 1, 6))
	editor_theme.set_color("font_color", "TabBar", text_color)
	editor_theme.set_color("font_selected_color", "TabBar", Color("#8bd2ba"))
	editor_theme.set_stylebox("tab_unselected", "TabBar", _make_editor_style(control_color, border_color, 1, 5))
	editor_theme.set_stylebox("tab_selected", "TabBar", _make_editor_style(panel_color, accent_color, 1, 5))
	editor_theme.set_stylebox("separator", "HSeparator", _make_editor_style(border_color, border_color, 0, 0))
	theme = editor_theme

func _make_editor_style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style

func _open_map_editor() -> void:
	_load_editor(MAP_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnMap)

func _open_stage_editor() -> void:
	_load_editor(STAGE_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnStage)

func _open_unit_editor() -> void:
	_load_editor(UNIT_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnUnit)

func _open_tower_editor() -> void:
	_load_editor(TOWER_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnTower)

func _open_building_editor() -> void:
	_load_editor(BUILDING_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnBuilding)

func _open_robot_editor() -> void:
	_load_editor(ROBOT_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnRobot)

func _open_faction_editor() -> void:
	_load_editor(FACTION_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnFaction)

func _open_skill_editor() -> void:
	_load_editor(SKILL_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnSkill)

func _open_mission_editor() -> void:
	_load_editor(MISSION_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnMission)

func _open_campaign_editor() -> void:
	_load_editor(CAMPAIGN_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnCampaign)

func _open_vfx_editor() -> void:
	_load_editor(VFX_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnVFX)

func _open_sfx_editor() -> void:
	_load_editor(SFX_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnSFX)

func _open_voice_editor() -> void:
	_load_editor(VOICE_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnVoice)

func _open_bgm_editor() -> void:
	_load_editor(BGM_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnBGM)

func _open_image_editor() -> void:
	if current_editor_scene != IMAGE_EDITOR_SCENE and not current_editor_scene.is_empty():
		previous_editor_scene = current_editor_scene
	_load_editor(IMAGE_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnCatalog)

func _load_editor(scene_path: String) -> void:
	current_editor_scene = scene_path
	if current_editor:
		current_editor.queue_free()
		current_editor = null
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("Could not load content editor: %s" % scene_path)
		return
	current_editor = packed.instantiate()
	content_host.add_child(current_editor)
	current_editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if current_editor.has_signal("request_content_editor"):
		current_editor.request_content_editor.connect(_open_content_editor_from_child)
	if current_editor.has_signal("request_image_editor"):
		current_editor.request_image_editor.connect(_open_image_editor_from_child)
	if current_editor.has_signal("request_previous_editor"):
		current_editor.request_previous_editor.connect(_open_previous_editor_from_child)
	if current_editor.has_signal("request_map_editor_for_path"):
		current_editor.request_map_editor_for_path.connect(_open_map_editor_for_path)

func _open_content_editor_from_child() -> void:
	_load_editor(MAP_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnMap)

func _open_image_editor_from_child() -> void:
	if current_editor_scene != IMAGE_EDITOR_SCENE and not current_editor_scene.is_empty():
		previous_editor_scene = current_editor_scene
	_load_editor(IMAGE_EDITOR_SCENE)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnCatalog)

func _open_previous_editor_from_child() -> void:
	var target_scene := ImageEditorState.selection_return_scene
	if target_scene.is_empty():
		target_scene = previous_editor_scene
	if target_scene.is_empty() or target_scene == IMAGE_EDITOR_SCENE:
		target_scene = MAP_EDITOR_SCENE
	_load_editor(target_scene)
	_set_active_button_for_scene(target_scene)

func _open_map_editor_for_path(map_path: String) -> void:
	var editor := load(MAP_EDITOR_SCENE) as PackedScene
	if editor == null:
		push_error("Could not load map editor.")
		return
	if current_editor:
		current_editor.queue_free()
		current_editor = null
	current_editor = editor.instantiate()
	if current_editor is MapEditorMain:
		current_editor.initial_map_path = map_path
	content_host.add_child(current_editor)
	current_editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if current_editor.has_signal("request_content_editor"):
		current_editor.request_content_editor.connect(_open_content_editor_from_child)
	_set_active_button($MainLayout/TopMenu/Buttons/BtnMap)

func _set_active_button_for_scene(scene_path: String) -> void:
	if scene_path == MAP_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnMap)
	elif scene_path == STAGE_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnStage)
	elif scene_path == UNIT_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnUnit)
	elif scene_path == TOWER_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnTower)
	elif scene_path == BUILDING_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnBuilding)
	elif scene_path == ROBOT_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnRobot)
	elif scene_path == IMAGE_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnCatalog)
	elif scene_path == FACTION_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnFaction)
	elif scene_path == SKILL_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnSkill)
	elif scene_path == MISSION_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnMission)
	elif scene_path == CAMPAIGN_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnCampaign)
	elif scene_path == VFX_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnVFX)
	elif scene_path == SFX_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnSFX)
	elif scene_path == VOICE_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnVoice)
	elif scene_path == BGM_EDITOR_SCENE:
		_set_active_button($MainLayout/TopMenu/Buttons/BtnBGM)

func _set_active_button(active: Button) -> void:
	$MainLayout/TopMenu/Buttons/BtnMap.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnMap
	$MainLayout/TopMenu/Buttons/BtnStage.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnStage
	$MainLayout/TopMenu/Buttons/BtnUnit.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnUnit
	$MainLayout/TopMenu/Buttons/BtnTower.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnTower
	$MainLayout/TopMenu/Buttons/BtnBuilding.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnBuilding
	$MainLayout/TopMenu/Buttons/BtnRobot.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnRobot
	$MainLayout/TopMenu/Buttons/BtnCatalog.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnCatalog
	$MainLayout/TopMenu/Buttons/BtnFaction.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnFaction
	$MainLayout/TopMenu/Buttons/BtnSkill.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnSkill
	$MainLayout/TopMenu/Buttons/BtnMission.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnMission
	$MainLayout/TopMenu/Buttons/BtnCampaign.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnCampaign
	$MainLayout/TopMenu/Buttons/BtnVFX.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnVFX
	$MainLayout/TopMenu/Buttons/BtnSFX.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnSFX
	$MainLayout/TopMenu/Buttons/BtnVoice.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnVoice
	$MainLayout/TopMenu/Buttons/BtnBGM.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnBGM

func _quit() -> void:
	get_tree().quit()

func _setup_runtime_import_ui() -> void:
	$MainLayout/RuntimeToolbar/Actions/BtnRuntimeData.pressed.connect(_on_runtime_data_pressed)
	_runtime_data_menu = PopupMenu.new()
	_runtime_data_menu.add_item("Import Runtime Data...", 0)
	_runtime_data_menu.add_item("Publish Runtime Package...", 1)
	_runtime_data_menu.add_separator()
	_runtime_data_menu.add_item("Run MENOS Runtime...", 2)
	_runtime_data_menu.add_separator()
	_runtime_data_menu.add_item("Manage Runtime Targets / Tables...", 3)
	_runtime_data_menu.id_pressed.connect(_on_runtime_data_action)
	add_child(_runtime_data_menu)

	_runtime_import_file_dialog = FileDialog.new()
	_runtime_import_file_dialog.title = "Select Runtime SQLite database"
	_runtime_import_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_runtime_import_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_runtime_import_file_dialog.filters = PackedStringArray(["*.sqlite ; SQLite database"])
	_runtime_import_file_dialog.file_selected.connect(_on_runtime_db_selected)
	add_child(_runtime_import_file_dialog)
	_runtime_import_confirm = ConfirmationDialog.new()
	_runtime_import_confirm.title = "Import Runtime content"
	_runtime_import_confirm.confirmed.connect(_apply_runtime_import)
	add_child(_runtime_import_confirm)
	_runtime_import_result = AcceptDialog.new()
	_runtime_import_result.title = "Runtime content import"
	add_child(_runtime_import_result)

	_publish_runtime_root_dialog = FileDialog.new()
	_publish_runtime_root_dialog.title = "Select MENOS Runtime project root"
	_publish_runtime_root_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_publish_runtime_root_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_publish_runtime_root_dialog.dir_selected.connect(_on_publish_runtime_root_selected)
	add_child(_publish_runtime_root_dialog)
	_runtime_launch_root_dialog = FileDialog.new()
	_runtime_launch_root_dialog.title = "Select MENOS Runtime project root to launch"
	_runtime_launch_root_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_runtime_launch_root_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_runtime_launch_root_dialog.dir_selected.connect(_on_runtime_launch_root_selected)
	add_child(_runtime_launch_root_dialog)
	_publish_output_parent_dialog = FileDialog.new()
	_publish_output_parent_dialog.title = "Select parent folder for new Runtime package"
	_publish_output_parent_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_publish_output_parent_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_publish_output_parent_dialog.dir_selected.connect(_on_publish_output_parent_selected)
	add_child(_publish_output_parent_dialog)
	_publish_confirm = ConfirmationDialog.new()
	_publish_confirm.title = "Publish Runtime package"
	_publish_confirm.confirmed.connect(_publish_runtime_package)
	add_child(_publish_confirm)
	_publish_result = AcceptDialog.new()
	_publish_result.title = "Runtime package publishing"
	add_child(_publish_result)

func _on_runtime_data_pressed() -> void:
	_runtime_data_menu.position = Vector2i(get_global_mouse_position())
	_runtime_data_menu.popup()

func _on_run_runtime_pressed() -> void:
	_runtime_launch_root_dialog.popup_centered(Vector2i(900, 600))

func _on_runtime_launch_root_selected(path: String) -> void:
	var project_file := path.path_join("project.godot")
	if not FileAccess.file_exists(project_file):
		_runtime_import_result.dialog_text = "The selected folder does not contain project.godot:\n" + path
		_runtime_import_result.popup_centered()
		return
	var process_id := OS.create_process(OS.get_executable_path(), PackedStringArray(["--path", path]), false)
	if process_id <= 0:
		_runtime_import_result.dialog_text = "Could not launch MENOS Runtime.\nProject: " + path
	else:
		_runtime_import_result.dialog_text = "MENOS Runtime launched in a separate process.\nProject: " + path + "\nProcess ID: " + str(process_id)
	_runtime_import_result.popup_centered()

func _refresh_runtime_button_label() -> void:
	var runtime_button: Button = $MainLayout/RuntimeToolbar/Actions/BtnRuntimeMenu
	var config := ConfigFile.new()
	var selected_id := 0
	if config.load(SETTINGS_PATH) == OK:
		selected_id = int(config.get_value("runtime", "selected_runtime_id", 0))
	if selected_id <= 0:
		runtime_button.text = "RUNTIME · 선택 필요"
		return
	var script_path := ProjectSettings.globalize_path("res://tools/manage_runtime_registry.py")
	var output: Array = []
	var exit_code := OS.execute("python", PackedStringArray([script_path, "list"]), output, true)
	if exit_code == -1:
		output.clear()
		exit_code = OS.execute("py", PackedStringArray(["-3", script_path, "list"]), output, true)
	if exit_code != 0:
		runtime_button.text = "RUNTIME · 선택 필요"
		return
	var parsed: Variant = JSON.parse_string("\n".join(PackedStringArray(output)))
	if not (parsed is Dictionary) or str(parsed.get("status", "")) != "PASS":
		runtime_button.text = "RUNTIME · 선택 필요"
		return
	for target in parsed.get("targets", []):
		if int(target.get("id", 0)) == selected_id and int(target.get("enabled", 0)) == 1:
			runtime_button.text = "RUNTIME · " + str(target.get("name", ""))
			return
	runtime_button.text = "RUNTIME · 선택 필요"

func _open_database_compare() -> void:
	var dialog := DATABASE_COMPARE_SCRIPT.new() as Window
	if not dialog.configure_for_scene(current_editor_scene):
		dialog.free()
		var notice := AcceptDialog.new()
		notice.title = "DB 비교"
		notice.dialog_text = "DB 좌우 비교는 미션, 팩션, 건물, 스킬, VFX, SFX, BGM, Voice 편집기에서 사용할 수 있습니다."
		add_child(notice)
		notice.confirmed.connect(notice.queue_free)
		notice.popup_centered()
		return
	add_child(dialog)
	dialog.popup_centered(Vector2i(1280, 780))

func _open_runtime_targets_manager() -> void:
	var packed := load(RUNTIME_TARGETS_SCENE) as PackedScene
	if packed == null:
		push_error("Could not load Runtime Targets manager.")
		return
	var manager := packed.instantiate() as Window
	add_child(manager)
	manager.tree_exited.connect(_refresh_runtime_button_label)
	manager.popup_centered(Vector2i(1120, 760))

func _on_runtime_data_action(id: int) -> void:
	if id == 0:
		_runtime_import_file_dialog.popup_centered(Vector2i(900, 600))
	elif id == 1:
		_publish_runtime_root_dialog.popup_centered(Vector2i(900, 600))
	elif id == 2:
		_runtime_launch_root_dialog.popup_centered(Vector2i(900, 600))
	elif id == 3:
		_open_runtime_targets_manager()

func _on_runtime_db_selected(path: String) -> void:
	_runtime_import_source = path
	var result := _run_runtime_import_tool(false)
	if int(result.get("exit_code", -1)) != 0:
		_runtime_import_result.dialog_text = "Import preview failed.\n" + str(result.get("output", "No diagnostic output."))
		_runtime_import_result.popup_centered()
		return
	var parsed: Variant = JSON.parse_string(str(result.get("output", "")))
	if not (parsed is Dictionary):
		_runtime_import_result.dialog_text = "Import preview returned invalid JSON.\n" + str(result.get("output", ""))
		_runtime_import_result.popup_centered()
		return
	_runtime_import_preview = parsed
	var map_lines := PackedStringArray()
	for map_id in parsed.get("maps_to_import", {}):
		var map_info: Dictionary = parsed["maps_to_import"][map_id]
		map_lines.append("- %s: %s objects" % [map_id, str(map_info.get("objects", 0))])
	_runtime_import_confirm.dialog_text = "Source Runtime DB:\n%s\n\nSHA-256: %s\nTables: %s\n\nMaps to import:\n%s\n\nThis replaces the Content Editor authoring database and canonical map JSON files. A timestamped backup is created first. Custom map JSON files are preserved. The Runtime source DB is never modified. Continue?" % [path, str(parsed.get("runtime_sha256", "")), str(parsed.get("schema_table_count", 0)), "\n".join(map_lines)]
	_runtime_import_confirm.popup_centered(Vector2i(760, 560))

func _apply_runtime_import() -> void:
	if _runtime_import_source.is_empty():
		return
	var result := _run_runtime_import_tool(true)
	if int(result.get("exit_code", -1)) != 0:
		_runtime_import_result.dialog_text = "Import failed.\n" + str(result.get("output", "No diagnostic output."))
	else:
		var parsed: Variant = JSON.parse_string(str(result.get("output", "")))
		if parsed is Dictionary and str(parsed.get("result", "")) == "PASS":
			_runtime_import_result.dialog_text = "Runtime content imported and verified.\n\nBackup: %s\n\nRestart the Content Editor before continuing to avoid stale in-memory content." % str(parsed.get("backup_directory", ""))
		else:
			_runtime_import_result.dialog_text = "Import returned an unrecognized result.\n" + str(result.get("output", ""))
	_runtime_import_result.popup_centered(Vector2i(760, 400))

func _run_runtime_import_tool(apply_import: bool) -> Dictionary:
	var script_path := ProjectSettings.globalize_path("res://tools/import_runtime_content.py")
	var args := PackedStringArray([script_path, "--source-db", _runtime_import_source])
	if apply_import:
		args.append("--apply")
	var output: Array = []
	var exit_code := OS.execute("python", args, output, true)
	if exit_code == -1:
		output.clear()
		var fallback_args := PackedStringArray(["-3", script_path, "--source-db", _runtime_import_source])
		if apply_import:
			fallback_args.append("--apply")
		exit_code = OS.execute("py", fallback_args, output, true)
	return {"exit_code": exit_code, "output": "\n".join(PackedStringArray(output))}

func _on_publish_runtime_root_selected(path: String) -> void:
	_publish_runtime_root = path
	_publish_output_parent_dialog.popup_centered(Vector2i(900, 600))

func _on_publish_output_parent_selected(path: String) -> void:
	var stamp := Time.get_datetime_dict_from_system(true)
	var suffix := "%04d%02d%02d_%02d%02d%02d" % [stamp.year, stamp.month, stamp.day, stamp.hour, stamp.minute, stamp.second]
	_publish_output_path = path.path_join("menos-runtime-package-" + suffix)
	_publish_confirm.dialog_text = "Runtime source:\n%s\n\nNew package output (must not already exist):\n%s\n\nThe publisher validates the source DB and map JSON, copies referenced Runtime assets, and writes a filtered SQLite database plus manifest. It will not overwrite an existing directory, change the Runtime DB, or activate the package. Continue?" % [_publish_runtime_root, _publish_output_path]
	_publish_confirm.popup_centered(Vector2i(760, 460))

func _publish_runtime_package() -> void:
	var script_path := ProjectSettings.globalize_path("res://tools/publish_runtime_package.py")
	var args := PackedStringArray([script_path, "--runtime-root", _publish_runtime_root, "--output", _publish_output_path])
	var output: Array = []
	var exit_code := OS.execute("python", args, output, true)
	if exit_code == -1:
		output.clear()
		var fallback_args := PackedStringArray(["-3", script_path, "--runtime-root", _publish_runtime_root, "--output", _publish_output_path])
		exit_code = OS.execute("py", fallback_args, output, true)
	_publish_result.dialog_text = ("Publisher completed.\n\n" if exit_code == 0 else "Publisher failed.\n\n") + "Output:\n" + "\n".join(PackedStringArray(output))
	_publish_result.popup_centered(Vector2i(760, 500))

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


var current_editor: Node = null
var content_host: Control
var current_editor_scene := ""
var previous_editor_scene := MAP_EDITOR_SCENE
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
	_open_map_editor()

func _setup_language() -> void:
	var language_option: OptionButton = $MainLayout/TopMenu/Buttons/LanguageOption
	var config := ConfigFile.new()
	var locale := "en"
	if config.load(SETTINGS_PATH) == OK:
		locale = str(config.get_value("localization", "language", "en"))
	if locale != "ko" and locale != "en":
		locale = "en"
	TranslationServer.set_locale(locale)
	language_option.select(0 if locale == "ko" else 1)
	language_option.item_selected.connect(_on_language_selected)

func _on_language_selected(index: int) -> void:
	var locale := "ko" if index == 0 else "en"
	TranslationServer.set_locale(locale)
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("localization", "language", locale)
	config.save(SETTINGS_PATH)

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
	$MainLayout/TopMenu/Buttons/BtnBGM.button_pressed = active == $MainLayout/TopMenu/Buttons/BtnBGM

func _quit() -> void:
	get_tree().quit()

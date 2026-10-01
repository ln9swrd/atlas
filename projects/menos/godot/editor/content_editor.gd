extends Control

const MAP_EDITOR_SCENE := "res://editor/map_editor.tscn"
const STAGE_EDITOR_SCENE := "res://editor/stage_editor.tscn"
const ENEMY_EDITOR_SCENE := "res://editor/enemy_editor.tscn"
const TOWER_EDITOR_SCENE := "res://editor/tower_editor.tscn"
const ROBOT_EDITOR_SCENE := "res://editor/robot_editor.tscn"
const IMAGE_EDITOR_SCENE := "res://editor/image_editor.tscn"

var current_editor: Node = null
var content_host: Control

func _ready() -> void:
	_apply_editor_theme()
	content_host = $MainLayout/Content
	$MainLayout/Sidebar/Buttons/BtnMap.pressed.connect(_open_map_editor)
	$MainLayout/Sidebar/Buttons/BtnStage.pressed.connect(_open_stage_editor)
	$MainLayout/Sidebar/Buttons/BtnEnemy.pressed.connect(_open_enemy_editor)
	$MainLayout/Sidebar/Buttons/BtnTower.pressed.connect(_open_tower_editor)
	$MainLayout/Sidebar/Buttons/BtnRobot.pressed.connect(_open_robot_editor)
	$MainLayout/Sidebar/Buttons/BtnImage.pressed.connect(_open_image_editor)
	$MainLayout/Sidebar/Buttons/BtnQuit.pressed.connect(_quit)
	_open_map_editor()

func _apply_editor_theme() -> void:
	var editor_theme := Theme.new()
	editor_theme.default_font_size = 12
	editor_theme.set_color("font_color", "Label", Color("#263332"))
	editor_theme.set_color("font_color", "Button", Color("#263332"))
	editor_theme.set_color("font_hover_color", "Button", Color("#173f3c"))
	editor_theme.set_color("font_pressed_color", "Button", Color("#f5f7f2"))
	editor_theme.set_color("font_disabled_color", "Button", Color("#87918b"))
	editor_theme.set_color("font_color", "LineEdit", Color("#263332"))
	editor_theme.set_color("font_placeholder_color", "LineEdit", Color("#87918b"))
	editor_theme.set_color("font_color", "OptionButton", Color("#263332"))
	editor_theme.set_color("font_color", "SpinBox", Color("#263332"))
	editor_theme.set_color("font_color", "CheckButton", Color("#263332"))

	var panel := _make_editor_style(Color("#f3f6f1"), Color("#c5d0c8"), 1, 8)
	editor_theme.set_stylebox("panel", "PanelContainer", panel)
	editor_theme.set_stylebox("normal", "Button", _make_editor_style(Color("#e5ebe4"), Color("#c5d0c8"), 1, 5))
	editor_theme.set_stylebox("hover", "Button", _make_editor_style(Color("#d8e5dc"), Color("#73958a"), 1, 5))
	editor_theme.set_stylebox("pressed", "Button", _make_editor_style(Color("#1f625b"), Color("#1f625b"), 1, 5))
	editor_theme.set_stylebox("focus", "Button", _make_editor_style(Color("#00000000"), Color("#4b8175"), 2, 5))
	editor_theme.set_stylebox("disabled", "Button", _make_editor_style(Color("#e9ede8"), Color("#d8dfd8"), 1, 5))
	editor_theme.set_stylebox("normal", "LineEdit", _make_editor_style(Color("#fbfcf8"), Color("#c5d0c8"), 1, 4))
	editor_theme.set_stylebox("focus", "LineEdit", _make_editor_style(Color("#ffffff"), Color("#4b8175"), 2, 4))
	editor_theme.set_stylebox("read_only", "LineEdit", _make_editor_style(Color("#e9ede8"), Color("#d8dfd8"), 1, 4))
	editor_theme.set_stylebox("normal", "OptionButton", _make_editor_style(Color("#fbfcf8"), Color("#c5d0c8"), 1, 4))
	editor_theme.set_stylebox("hover", "OptionButton", _make_editor_style(Color("#edf3ed"), Color("#73958a"), 1, 4))
	editor_theme.set_stylebox("pressed", "OptionButton", _make_editor_style(Color("#1f625b"), Color("#1f625b"), 1, 4))
	editor_theme.set_stylebox("panel", "TabContainer", _make_editor_style(Color("#f3f6f1"), Color("#c5d0c8"), 1, 6))
	editor_theme.set_color("font_color", "TabBar", Color("#263332"))
	editor_theme.set_color("font_selected_color", "TabBar", Color("#1f625b"))
	editor_theme.set_stylebox("tab_unselected", "TabBar", _make_editor_style(Color("#e5ebe4"), Color("#c5d0c8"), 1, 5))
	editor_theme.set_stylebox("tab_selected", "TabBar", _make_editor_style(Color("#f3f6f1"), Color("#73958a"), 1, 5))
	editor_theme.set_stylebox("separator", "HSeparator", _make_editor_style(Color("#c5d0c8"), Color("#c5d0c8"), 0, 0))
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
	_set_active_button($MainLayout/Sidebar/Buttons/BtnMap)

func _open_stage_editor() -> void:
	_load_editor(STAGE_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnStage)

func _open_enemy_editor() -> void:
	_load_editor(ENEMY_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnEnemy)

func _open_tower_editor() -> void:
	_load_editor(TOWER_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnTower)

func _open_robot_editor() -> void:
	_load_editor(ROBOT_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnRobot)

func _open_image_editor() -> void:
	_load_editor(IMAGE_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnImage)

func _load_editor(scene_path: String) -> void:
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

func _open_content_editor_from_child() -> void:
	_load_editor(MAP_EDITOR_SCENE)
	_set_active_button($MainLayout/Sidebar/Buttons/BtnMap)

func _set_active_button(active: Button) -> void:
	$MainLayout/Sidebar/Buttons/BtnMap.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnMap
	$MainLayout/Sidebar/Buttons/BtnStage.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnStage
	$MainLayout/Sidebar/Buttons/BtnEnemy.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnEnemy
	$MainLayout/Sidebar/Buttons/BtnTower.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnTower
	$MainLayout/Sidebar/Buttons/BtnRobot.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnRobot
	$MainLayout/Sidebar/Buttons/BtnImage.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnImage

func _quit() -> void:
	get_tree().quit()

extends Control

const MAP_EDITOR_SCENE := "res://editor/map_editor.tscn"
const STAGE_EDITOR_SCENE := "res://editor/stage_editor.tscn"
const ENEMY_EDITOR_SCENE := "res://editor/enemy_editor.tscn"
const TOWER_EDITOR_SCENE := "res://editor/tower_editor.tscn"
const IMAGE_EDITOR_SCENE := "res://editor/image_editor.tscn"

var current_editor: Node = null
var content_host: Control

func _ready() -> void:
	content_host = $MainLayout/Content
	$MainLayout/Sidebar/Buttons/BtnMap.pressed.connect(_open_map_editor)
	$MainLayout/Sidebar/Buttons/BtnStage.pressed.connect(_open_stage_editor)
	$MainLayout/Sidebar/Buttons/BtnEnemy.pressed.connect(_open_enemy_editor)
	$MainLayout/Sidebar/Buttons/BtnTower.pressed.connect(_open_tower_editor)
	$MainLayout/Sidebar/Buttons/BtnImage.pressed.connect(_open_image_editor)
	$MainLayout/Sidebar/Buttons/BtnQuit.pressed.connect(_quit)
	_open_map_editor()

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
	$MainLayout/Sidebar/Buttons/BtnImage.button_pressed = active == $MainLayout/Sidebar/Buttons/BtnImage

func _quit() -> void:
	get_tree().quit()

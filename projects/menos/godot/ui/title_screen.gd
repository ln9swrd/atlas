extends Control

const GAME_SCENE := "res://main.tscn"

@onready var start_button: Button = $CenterContainer/MainPanel/Content/Actions/StartCampaign
@onready var single_button: Button = $CenterContainer/MainPanel/Content/Actions/SinglePlay
@onready var map_select: OptionButton = $CenterContainer/MainPanel/Content/Actions/MapSelect
@onready var stage_select: OptionButton = $CenterContainer/MainPanel/Content/Actions/StageSelect
@onready var stage_info: Label = $CenterContainer/MainPanel/Content/StageInfo/Details
@onready var quit_button: Button = $CenterContainer/MainPanel/Content/Actions/Quit
@onready var settings_button: Button = $CenterContainer/MainPanel/Content/Settings
var transition_started := false
var campaign_start_disabled := false
var single_mode_selected := false

func _ready() -> void:
	set_process_input(true)
	start_button.pressed.connect(_on_start_campaign_pressed)
	start_button.disabled = campaign_start_disabled
	single_button.pressed.connect(_on_start_single_pressed)
	_populate_maps()
	map_select.item_selected.connect(_on_map_selected)
	stage_select.item_selected.connect(_on_stage_selected)
	map_select.visible = false
	stage_select.visible = false
	stage_info.visible = false
	if map_select.item_count > 0:
		map_select.select(0)
		_populate_missions_for_selected_map()
	quit_button.pressed.connect(_on_quit_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	_refresh_language()
	start_button.grab_focus()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("e8ede7"))
	var grid_spacing := float(ConfigRepository.get_editor_value("title_screen", "grid_spacing", 40.0))
	var grid_color_data: Array = ConfigRepository.get_editor_value("title_screen", "grid_color", [0.28, 0.43, 0.39, 0.07])
	var center_line_color_data: Array = ConfigRepository.get_editor_value("title_screen", "center_line_color", [0.12, 0.39, 0.37, 0.10])
	var center_arc_color_data: Array = ConfigRepository.get_editor_value("title_screen", "center_arc_color", [0.12, 0.39, 0.37, 0.08])
	var grid_color := Color(float(grid_color_data[0]), float(grid_color_data[1]), float(grid_color_data[2]), float(grid_color_data[3]))
	var center_line_color := Color(float(center_line_color_data[0]), float(center_line_color_data[1]), float(center_line_color_data[2]), float(center_line_color_data[3]))
	var center_arc_color := Color(float(center_arc_color_data[0]), float(center_arc_color_data[1]), float(center_arc_color_data[2]), float(center_arc_color_data[3]))
	for x in range(0, int(size.x) + 1, int(grid_spacing)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
	for y in range(0, int(size.y) + 1, int(grid_spacing)):
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
	var center_line_width := float(ConfigRepository.get_editor_value("title_screen", "center_line_width", 2.0))
	var center_arc_width := float(ConfigRepository.get_editor_value("title_screen", "center_arc_width", 1.0))
	var center_arc_radius_ratio := float(ConfigRepository.get_editor_value("title_screen", "center_arc_radius_ratio", 0.38))
	var center_arc_points := int(ConfigRepository.get_editor_value("title_screen", "center_arc_points", 72))
	draw_rect(Rect2(0, size.y * 0.5 - center_line_width * 0.5, size.x, center_line_width), center_line_color)
	draw_arc(size * 0.5, minf(size.x, size.y) * center_arc_radius_ratio, 0.0, TAU, center_arc_points, center_arc_color, center_arc_width)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		if get_viewport().gui_get_focus_owner() == map_select:
			map_select.show_popup()
		elif get_viewport().gui_get_focus_owner() == stage_select:
			stage_select.show_popup()
		else:
			_on_start_campaign_pressed()
		get_viewport().set_input_as_handled()

func _populate_maps() -> void:
	map_select.clear()
	for path in MapLoader.list_map_paths():
		var parsed := MapLoader.load_map_data(path)
		var map_id: String = path.get_file().get_basename()
		var map_name: String = str(parsed.get("name", map_id)) if parsed is Dictionary else map_id
		map_select.add_item(map_name)
		map_select.set_item_metadata(map_select.item_count - 1, path)

func _on_map_selected(_index: int) -> void:
	_populate_missions_for_selected_map()

func _populate_missions_for_selected_map() -> void:
	stage_select.clear()
	if map_select.selected < 0:
		return
	var selected_map := str(map_select.get_item_metadata(map_select.selected))
	for stage_id in StageManager.get_all_stage_ids():
		var stage_data := StageLoader.load_stage_data(str(stage_id))
		if stage_data.is_empty() or str(stage_data.get("map_file", "")) != selected_map:
			continue
		var mission_id := str(stage_data.get("mission_id", ""))
		var mission := MissionDefinitionLoader.load_definition(mission_id) if not mission_id.is_empty() else null
		var title: String = mission.title if mission != null and not mission.title.is_empty() else str(stage_data.get("name", stage_id))
		stage_select.add_item(title)
		stage_select.set_item_metadata(stage_select.item_count - 1, str(stage_id))
	if stage_select.item_count > 0:
		stage_select.select(0)
		_update_stage_info(0)
	else:
		stage_info.text = "이 맵에 연결된 미션이 없습니다."

func _on_stage_selected(index: int) -> void:
	_update_stage_info(index)

func _update_stage_info(index: int) -> void:
	if index < 0 or index >= stage_select.item_count:
		stage_info.text = ""
		return
	var stage_id := str(stage_select.get_item_metadata(index))
	var stage_data := StageLoader.load_stage_data(stage_id)
	if stage_data.is_empty():
		stage_info.text = stage_id
		return
	var encounters: Array = stage_data.get("encounters", [])
	var wave_count := 0
	for encounter in encounters:
		if encounter is Dictionary:
			var waves = encounter.get("waves", [])
			if waves is Array:
				wave_count += waves.size()
	var mission_id := str(stage_data.get("mission_id", ""))
	var mission := MissionDefinitionLoader.load_definition(mission_id) if not mission_id.is_empty() else null
	var mission_title := mission.title if mission != null and not mission.title.is_empty() else str(stage_data.get("name", stage_id))
	var mission_type := mission.primary_type if mission != null else "clear_encounters"
	var time_limit := mission.time_limit if mission != null else 0
	var limit_text := "제한시간 %d초" % time_limit if time_limit > 0 else "제한시간 없음"
	stage_info.text = "%s  /  %s  /  %s  /  %d ENCOUNTER  /  %d WAVE" % [stage_id.to_upper(), mission_title, mission_type, encounters.size(), wave_count]

func _on_start_single_pressed() -> void:
	if transition_started: return
	single_mode_selected = not single_mode_selected
	map_select.visible = single_mode_selected
	stage_select.visible = false
	stage_info.visible = single_mode_selected
	if single_mode_selected:
		start_button.text = tr("START SINGLE PLAY")
		start_button.disabled = map_select.item_count == 0 or stage_select.item_count == 0
		single_button.text = tr("SINGLE PLAY SELECTED")
	else:
		start_button.text = tr("START CAMPAIGN")
		start_button.disabled = campaign_start_disabled
		single_button.text = tr("SINGLE PLAY")
	if single_mode_selected:
		map_select.grab_focus()
	else:
		start_button.grab_focus()

func _on_start_campaign_pressed() -> void:
	if transition_started: return
	transition_started = true
	var mode := "single" if single_mode_selected else "campaign"
	if single_mode_selected and (map_select.selected < 0 or stage_select.item_count == 0):
		transition_started = false
		return
	var selected_stage := str(stage_select.get_item_metadata(0)) if single_mode_selected and stage_select.item_count > 0 else "stage_01"
	StageManager.begin_run(mode, selected_stage)
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		transition_started = false
		push_error("Could not open the MENOS game scene: %s" % GAME_SCENE)
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings_screen.tscn")

func _refresh_language() -> void:
	start_button.text = tr("START CAMPAIGN")
	single_button.text = tr("SINGLE PLAY")
	quit_button.text = tr("QUIT")
	settings_button.text = tr("SETTINGS")

func _on_quit_pressed() -> void:
	get_tree().quit()

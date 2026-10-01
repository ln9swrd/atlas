extends Control

const GAME_SCENE := "res://main.tscn"

@onready var start_button: Button = $CenterContainer/MainPanel/Content/Actions/StartCampaign
@onready var single_button: Button = $CenterContainer/MainPanel/Content/Actions/SinglePlay
@onready var stage_select: OptionButton = $CenterContainer/MainPanel/Content/Actions/StageSelect
@onready var stage_info: Label = $CenterContainer/MainPanel/Content/StageInfo/Details
@onready var quit_button: Button = $CenterContainer/MainPanel/Content/Actions/Quit
@onready var settings_button: Button = $CenterContainer/MainPanel/Content/Settings
var transition_started := false
var single_mode_selected := false

func _ready() -> void:
	set_process_input(true)
	start_button.pressed.connect(_on_start_campaign_pressed)
	single_button.pressed.connect(_on_start_single_pressed)
	for stage_id in StageManager.get_all_stage_ids():
		var stage_data := StageLoader.load_stage_data(str(stage_id))
		var stage_label := str(stage_data.get("name", stage_id)) if not stage_data.is_empty() else str(stage_id)
		stage_select.add_item(stage_label)
		stage_select.set_item_metadata(stage_select.item_count - 1, str(stage_id))
	stage_select.item_selected.connect(_on_stage_selected)
	stage_select.visible = false
	stage_info.visible = false
	if stage_select.item_count > 0:
		stage_select.select(0)
		_update_stage_info(0)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	_refresh_language()
	start_button.grab_focus()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("e8ede7"))
	var spacing := 40.0
	var grid_color := Color(0.28, 0.43, 0.39, 0.07)
	for x in range(0, int(size.x) + 1, int(spacing)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
	for y in range(0, int(size.y) + 1, int(spacing)):
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
	draw_rect(Rect2(0, size.y * 0.5 - 1.0, size.x, 2.0), Color(0.12, 0.39, 0.37, 0.10))
	draw_arc(size * 0.5, minf(size.x, size.y) * 0.38, 0.0, TAU, 72, Color(0.12, 0.39, 0.37, 0.08), 1.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		if get_viewport().gui_get_focus_owner() == stage_select:
			stage_select.show_popup()
		else:
			_on_start_campaign_pressed()
		get_viewport().set_input_as_handled()

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
	stage_info.text = "%s  /  %s  /  %d ENCOUNTER  /  %d WAVE" % [stage_id.to_upper(), str(stage_data.get("name", stage_id)), encounters.size(), wave_count]

func _on_start_single_pressed() -> void:
	if transition_started: return
	single_mode_selected = not single_mode_selected
	stage_select.visible = single_mode_selected
	stage_info.visible = single_mode_selected
	if single_mode_selected:
		start_button.text = SettingsManager.text("\uC2F1\uAE00 \uD50C\uB808\uC774 \uC2DC\uC791", "START SINGLE PLAY")
		single_button.text = SettingsManager.text("\uC2F1\uAE00 \uD50C\uB808\uC774 \uC120\uD0DD\uB428", "SINGLE PLAY SELECTED")
	else:
		start_button.text = SettingsManager.text("\uCEA0\uD398\uC778 \uC2DC\uC791", "START CAMPAIGN")
		single_button.text = SettingsManager.text("\uC2F1\uAE00 \uD50C\uB808\uC774", "SINGLE PLAY")
	if single_mode_selected:
		stage_select.grab_focus()
	else:
		start_button.grab_focus()

func _on_start_campaign_pressed() -> void:
	if transition_started: return
	transition_started = true
	var mode := "single" if single_mode_selected else "campaign"
	var selected_stage := str(stage_select.get_item_metadata(stage_select.selected)) if single_mode_selected and stage_select.selected >= 0 else "stage_01"
	StageManager.begin_run(mode, selected_stage)
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		transition_started = false
		push_error("Could not open the MENOS game scene: %s" % GAME_SCENE)
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings_screen.tscn")

func _refresh_language() -> void:
	start_button.text = SettingsManager.text("\uCEA0\uD398\uC778 \uC2DC\uC791", "START CAMPAIGN")
	single_button.text = SettingsManager.text("\uC2F1\uAE00 \uD50C\uB808\uC774", "SINGLE PLAY")
	quit_button.text = SettingsManager.text("\uC885\uB8CC", "QUIT")
	settings_button.text = SettingsManager.text("\uC124\uC815", "SETTINGS")

func _on_quit_pressed() -> void:
	get_tree().quit()

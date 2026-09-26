extends Control

const GAME_SCENE := "res://main.tscn"

@onready var start_button: Button = $CenterContainer/MainPanel/Content/Actions/StartCampaign
@onready var quit_button: Button = $CenterContainer/MainPanel/Content/Actions/Quit
var transition_started := false

func _ready() -> void:
	set_process_input(true)
	start_button.pressed.connect(_on_start_campaign_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("081318"))
	var spacing := 32.0
	var grid_color := Color(0.18, 0.38, 0.41, 0.18)
	for x in range(0, int(size.x) + 1, int(spacing)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
	for y in range(0, int(size.y) + 1, int(spacing)):
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
	draw_rect(Rect2(0, size.y * 0.5 - 1.0, size.x, 2.0), Color(0.35, 0.68, 0.67, 0.08))
	draw_arc(size * 0.5, minf(size.x, size.y) * 0.38, 0.0, TAU, 72, Color(0.35, 0.68, 0.67, 0.08), 1.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		_on_start_campaign_pressed()
		get_viewport().set_input_as_handled()

func _on_start_campaign_pressed() -> void:
	if transition_started:
		return
	transition_started = true
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		transition_started = false
		push_error("Could not open the MENOS campaign scene: %s" % GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

class_name AtlasPalette
extends Control

signal tile_selected(x: int, y: int)

const TEXTURE: Texture2D = preload("res://assets/menos/maps/ground4.png")

const COLS := 48
const ROWS := 32

var selected_x := 0
var selected_y := 0

func _ready() -> void:
	custom_minimum_size = Vector2(216, 144)
	queue_redraw()

func set_selected_cell(x: int, y: int) -> void:
	selected_x = clamp(x, 0, COLS - 1)
	selected_y = clamp(y, 0, ROWS - 1)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		if mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
			var cell_w := size.x / float(COLS)
			var cell_h := size.y / float(ROWS)
			var col := clampi(int(mb_event.position.x / cell_w), 0, COLS - 1)
			var row := clampi(int(mb_event.position.y / cell_h), 0, ROWS - 1)

			set_selected_cell(col, row)
			tile_selected.emit(col, row)

func _draw() -> void:
	if TEXTURE:
		draw_texture_rect(TEXTURE, Rect2(Vector2.ZERO, size), false)

	var cell_w := size.x / float(COLS)
	var cell_h := size.y / float(ROWS)

	# Draw Selected Tile Highlight Box
	var sel_rect := Rect2(selected_x * cell_w, selected_y * cell_h, maxf(cell_w, 3.0), maxf(cell_h, 3.0))
	draw_rect(sel_rect, Color("ffe066"), false, 2.0)
	draw_rect(sel_rect.grow(1.0), Color("000000"), false, 1.0)

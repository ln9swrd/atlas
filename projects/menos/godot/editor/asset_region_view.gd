extends Control

signal region_changed(rect: Rect2i)

var texture: Texture2D
var selected_region := Rect2i()
var _dragging := false
var _drag_start := Vector2.ZERO
var _drag_end := Vector2.ZERO

func _get_image_rect() -> Rect2:
	if texture == null:
		return Rect2()
	var image_size := Vector2(texture.get_size())
	var scale_factor := minf(size.x / image_size.x, size.y / image_size.y)
	var draw_size := image_size * maxf(scale_factor, 0.001)
	return Rect2((size - draw_size) * 0.5, draw_size)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("151d26"), true)
	if texture == null:
		draw_string(ThemeDB.fallback_font, Vector2(18, 30), "Choose a project image, then drag to select a region", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c2cbd4"))
		return
	var image_rect := _get_image_rect()
	draw_texture_rect(texture, image_rect, false)
	draw_rect(image_rect, Color("61717e"), false, 1.0)
	if selected_region.size.x > 0 and selected_region.size.y > 0:
		var pixel_size := Vector2(texture.get_size())
		var selected_rect := Rect2(image_rect.position + Vector2(selected_region.position) / pixel_size * image_rect.size, Vector2(selected_region.size) / pixel_size * image_rect.size)
		draw_rect(selected_rect, Color(0.15, 0.88, 0.78, 0.2), true)
		draw_rect(selected_rect, Color("38e0c3"), false, 2.0)
	if _dragging:
		var drag_rect := Rect2(_drag_start, _drag_end - _drag_start).abs().intersection(image_rect)
		draw_rect(drag_rect, Color(0.95, 0.75, 0.28, 0.2), true)
		draw_rect(drag_rect, Color("f2c14e"), false, 2.0)

func _gui_input(event: InputEvent) -> void:
	var image_rect := _get_image_rect()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and image_rect.has_point(event.position):
			_dragging = true
			_drag_start = event.position
			_drag_end = event.position
			accept_event()
			queue_redraw()
		elif not event.pressed and _dragging:
			_dragging = false
			_drag_end = event.position
			var drag_rect := Rect2(_drag_start, _drag_end - _drag_start).abs().intersection(image_rect)
			var pixel_size := Vector2(texture.get_size())
			var top_left := ((drag_rect.position - image_rect.position) / image_rect.size * pixel_size).floor()
			var bottom_right := ((drag_rect.end - image_rect.position) / image_rect.size * pixel_size).ceil()
			var rect := Rect2i(Vector2i(top_left), Vector2i(bottom_right - top_left))
			if rect.size.x > 0 and rect.size.y > 0:
				selected_region = rect
				region_changed.emit(rect)
			accept_event()
			queue_redraw()
	elif event is InputEventMouseMotion and _dragging:
		_drag_end = event.position
		queue_redraw()
		accept_event()

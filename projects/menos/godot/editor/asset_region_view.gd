extends Control

signal region_changed(rect: Rect2i)

var texture: Texture2D
var selected_region := Rect2i()
var _zoom := 1.0
var _pan_offset := Vector2.ZERO
var _dragging_region := false
var _drag_start := Vector2.ZERO
var _drag_end := Vector2.ZERO
var _panning := false
var _last_pan_position := Vector2.ZERO
var _editing_pixels := false
var _edit_image: Image
var _edit_texture: ImageTexture
var _brush_size_px := 12
var _last_pointer := Vector2(-1, -1)

func set_source_texture(value: Texture2D) -> void:
	texture = value
	_editing_pixels = false
	_edit_image = null
	_edit_texture = null
	selected_region = Rect2i()
	_zoom = 1.0
	_pan_offset = Vector2.ZERO
	queue_redraw()

func begin_image_edit(source_crop: Image, brush_size_px: int = 12) -> void:
	_edit_image = source_crop.duplicate()
	if not _edit_image.has_alpha():
		_edit_image.convert(Image.FORMAT_RGBA8)
	_edit_texture = ImageTexture.create_from_image(_edit_image)
	texture = _edit_texture
	selected_region = Rect2i()
	_brush_size_px = maxi(1, brush_size_px)
	_zoom = 1.0
	_pan_offset = Vector2.ZERO
	_editing_pixels = true
	queue_redraw()

func cancel_image_edit() -> void:
	_editing_pixels = false
	_edit_image = null
	_edit_texture = null
	queue_redraw()

func is_editing_pixels() -> bool:
	return _editing_pixels

func set_erase_brush_size(size_px: int) -> void:
	_brush_size_px = maxi(1, size_px)
	queue_redraw()

func get_edited_image() -> Image:
	if not _editing_pixels or _edit_image == null:
		return null
	return _edit_image.duplicate()

func _get_base_scale() -> float:
	if texture == null or size.x <= 0.0 or size.y <= 0.0:
		return 1.0
	var image_size := Vector2(texture.get_size())
	if image_size.x <= 0.0 or image_size.y <= 0.0:
		return 1.0
	return minf(size.x / image_size.x, size.y / image_size.y)

func _get_image_rect() -> Rect2:
	if texture == null:
		return Rect2()
	var draw_size := Vector2(texture.get_size()) * _get_base_scale() * _zoom
	return Rect2((size - draw_size) * 0.5 + _pan_offset, draw_size)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("151d26"), true)
	if texture == null:
		draw_string(ThemeDB.fallback_font, Vector2(18, 30), "Choose a project image, then drag to select a region", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c2cbd4"))
		return
	var image_rect := _get_image_rect()
	draw_texture_rect(texture, image_rect, false)
	draw_rect(image_rect, Color("61717e"), false, 1.0)
	if not _editing_pixels and selected_region.size.x > 0 and selected_region.size.y > 0:
		var pixel_size := Vector2(texture.get_size())
		var selected_rect := Rect2(image_rect.position + Vector2(selected_region.position) / pixel_size * image_rect.size, Vector2(selected_region.size) / pixel_size * image_rect.size)
		draw_rect(selected_rect, Color(0.15, 0.88, 0.78, 0.2), true)
		draw_rect(selected_rect, Color("38e0c3"), false, 2.0)
	if _dragging_region:
		var drag_rect := Rect2(_drag_start, _drag_end - _drag_start).abs().intersection(image_rect)
		draw_rect(drag_rect, Color(0.95, 0.75, 0.28, 0.2), true)
		draw_rect(drag_rect, Color("f2c14e"), false, 2.0)
	if _editing_pixels and image_rect.has_point(_last_pointer):
		var brush_rect := _brush_rect_at(_last_pointer, image_rect)
		draw_rect(brush_rect, Color(0.95, 0.3, 0.3, 0.25), true)
		draw_rect(brush_rect, Color("ff6b6b"), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(10, size.y - 10), "Zoom %.0f%% · wheel zoom · middle/right drag pan%s" % [_zoom * 100.0, " · left drag erases alpha" if _editing_pixels else " · left drag selects region"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("c2cbd4"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_event.pressed:
			_zoom_at(mouse_event.position, 1.2)
			accept_event()
			return
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_event.pressed:
			_zoom_at(mouse_event.position, 1.0 / 1.2)
			accept_event()
			return
		if mouse_event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			_panning = mouse_event.pressed
			_last_pan_position = mouse_event.position
			accept_event()
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed and _get_image_rect().has_point(mouse_event.position):
				_last_pointer = mouse_event.position
				if _editing_pixels:
					_erase_at(mouse_event.position)
				else:
					_dragging_region = true
					_drag_start = mouse_event.position
					_drag_end = mouse_event.position
				accept_event()
				queue_redraw()
			elif not mouse_event.pressed:
				if _editing_pixels:
					accept_event()
				elif _dragging_region:
					_dragging_region = false
					_drag_end = mouse_event.position
					_commit_region_drag()
					accept_event()
				queue_redraw()
			return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		_last_pointer = motion.position
		if _panning:
			_pan_offset += motion.position - _last_pan_position
			_last_pan_position = motion.position
			accept_event()
		elif _editing_pixels and motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_erase_at(motion.position)
			accept_event()
		elif _dragging_region:
			_drag_end = motion.position
			accept_event()
		queue_redraw()

func _zoom_at(view_position: Vector2, factor: float) -> void:
	if texture == null:
		return
	var old_rect := _get_image_rect()
	if not old_rect.has_point(view_position):
		return
	var image_fraction := (view_position - old_rect.position) / old_rect.size
	_zoom = clampf(_zoom * factor, 0.1, 16.0)
	var new_size := Vector2(texture.get_size()) * _get_base_scale() * _zoom
	var centered_position := (size - new_size) * 0.5
	_pan_offset = view_position - centered_position - image_fraction * new_size
	queue_redraw()

func _commit_region_drag() -> void:
	var image_rect := _get_image_rect()
	var drag_rect := Rect2(_drag_start, _drag_end - _drag_start).abs().intersection(image_rect)
	if drag_rect.size.x <= 0.0 or drag_rect.size.y <= 0.0 or texture == null:
		return
	var pixel_size := Vector2(texture.get_size())
	var top_left := ((drag_rect.position - image_rect.position) / image_rect.size * pixel_size).floor()
	var bottom_right := ((drag_rect.end - image_rect.position) / image_rect.size * pixel_size).ceil()
	var rect := Rect2i(Vector2i(top_left), Vector2i(bottom_right - top_left))
	if rect.size.x > 0 and rect.size.y > 0:
		selected_region = rect
		region_changed.emit(rect)

func _brush_rect_at(view_position: Vector2, image_rect: Rect2) -> Rect2:
	var image_size := Vector2(texture.get_size())
	var pixel := (view_position - image_rect.position) / image_rect.size * image_size
	var pixel_brush := float(_brush_size_px)
	var top_left := (pixel - Vector2(pixel_brush, pixel_brush) * 0.5) / image_size * image_rect.size + image_rect.position
	return Rect2(top_left, Vector2(pixel_brush, pixel_brush) / image_size * image_rect.size)

func _erase_at(view_position: Vector2) -> void:
	if _edit_image == null:
		return
	var image_rect := _get_image_rect()
	if not image_rect.has_point(view_position):
		return
	var image_size := Vector2i(_edit_image.get_width(), _edit_image.get_height())
	var pixel := Vector2i(((view_position - image_rect.position) / image_rect.size * Vector2(image_size)).floor())
	var start := pixel - Vector2i(int(floor(float(_brush_size_px) / 2.0)), int(floor(float(_brush_size_px) / 2.0)))
	for offset_y in range(_brush_size_px):
		for offset_x in range(_brush_size_px):
			var target := start + Vector2i(offset_x, offset_y)
			if target.x >= 0 and target.y >= 0 and target.x < image_size.x and target.y < image_size.y:
				_edit_image.set_pixel(target.x, target.y, Color(0, 0, 0, 0))
	_edit_texture.update(_edit_image)
	queue_redraw()

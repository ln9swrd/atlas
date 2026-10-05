class_name AssetRegionView
extends Control

const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")

signal region_changed(rect: Rect2i)
signal frame_selected(frame_index: int)

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
var _brush_size_px := int(ConfigRepository.get_editor_value("asset_region_view", "brush_size_px", 12))
var _last_pointer := Vector2(-1, -1)
var _clip_erase_to_region := false
var _edit_clip_rect := Rect2i()
var grid_columns := 1
var grid_rows := 1
var grid_frames := 1
var grid_frame_order := "row_major"
var grid_anchor := Vector2(0.5, 1.0)
var grid_frame_anchors: Array = []
var grid_frame_regions: Array = []
var frame_select_mode := false
var selected_frame_index := -1

func set_frame_select_mode(enabled: bool) -> void:
	frame_select_mode = enabled
	if not enabled:
		selected_frame_index = -1
	queue_redraw()

func set_selected_frame(frame_index: int) -> void:
	selected_frame_index = clampi(frame_index, 0, maxi(0, grid_frames - 1))
	queue_redraw()

func set_frame_anchors(frame_anchors: Array) -> void:
	grid_frame_anchors = frame_anchors.duplicate(true)
	queue_redraw()

func set_source_texture(value: Texture2D) -> void:
	texture = value
	_editing_pixels = false
	_edit_image = null
	_edit_texture = null
	_clip_erase_to_region = false
	_edit_clip_rect = Rect2i()
	selected_region = Rect2i()
	_zoom = 1.0
	_pan_offset = Vector2.ZERO
	queue_redraw()

func set_grid_metadata(columns: int, rows: int, frames: int, anchor: Vector2, frame_order: String = "row_major", frame_regions: Array = []) -> void:
	grid_columns = maxi(1, columns)
	grid_rows = maxi(1, rows)
	grid_frames = clampi(frames, 1, grid_columns * grid_rows)
	grid_frame_order = "column_major" if frame_order == "column_major" else "row_major"
	grid_anchor = Vector2(clampf(anchor.x, 0.0, 1.0), clampf(anchor.y, 0.0, 1.0))
	grid_frame_regions = frame_regions.duplicate(true)
	queue_redraw()

func clear_grid_metadata() -> void:
	grid_columns = 1
	grid_rows = 1
	grid_frames = 1
	grid_frame_order = "row_major"
	grid_anchor = Vector2(0.5, 1.0)
	grid_frame_regions.clear()
	queue_redraw()

func begin_image_edit(source_crop: Image, brush_size_px: int = -1) -> void:
	_clip_erase_to_region = false
	_edit_clip_rect = Rect2i()
	_edit_image = source_crop.duplicate()
	IMAGE_TEXTURE_LOADER.prepare_for_pixel_edit(_edit_image)
	_edit_texture = ImageTexture.create_from_image(_edit_image)
	texture = _edit_texture
	selected_region = Rect2i()
	_brush_size_px = maxi(1, brush_size_px if brush_size_px > 0 else int(ConfigRepository.get_editor_value("asset_region_view", "brush_size_px", 12)))
	_editing_pixels = true
	_fit_view_to_pixel_rect(Rect2i(0, 0, _edit_image.get_width(), _edit_image.get_height()))
	queue_redraw()

func begin_image_edit_clipped(full_source: Image, clip_rect: Rect2i, brush_size_px: int = -1) -> void:
	_clip_erase_to_region = true
	_edit_clip_rect = clip_rect
	_edit_image = full_source.duplicate()
	IMAGE_TEXTURE_LOADER.prepare_for_pixel_edit(_edit_image)
	_edit_texture = ImageTexture.create_from_image(_edit_image)
	texture = _edit_texture
	selected_region = clip_rect
	_brush_size_px = maxi(1, brush_size_px if brush_size_px > 0 else int(ConfigRepository.get_editor_value("asset_region_view", "brush_size_px", 12)))
	_editing_pixels = true
	_fit_view_to_pixel_rect(clip_rect)
	queue_redraw()

func cancel_image_edit() -> void:
	_editing_pixels = false
	_edit_image = null
	_edit_texture = null
	_clip_erase_to_region = false
	_edit_clip_rect = Rect2i()
	queue_redraw()

func is_editing_pixels() -> bool:
	return _editing_pixels

func set_erase_brush_size(size_px: int) -> void:
	_brush_size_px = maxi(1, size_px)
	queue_redraw()

func get_edited_image() -> Image:
	if not _editing_pixels or _edit_image == null:
		return null
	if _clip_erase_to_region and _edit_clip_rect.size.x > 0 and _edit_clip_rect.size.y > 0:
		return _edit_image.get_region(_edit_clip_rect)
	return _edit_image.duplicate()

func _pan_input_active() -> bool:
	return Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_ALT)

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

func _fit_view_to_pixel_rect(pixel_rect: Rect2i) -> void:
	if texture == null or pixel_rect.size.x <= 0 or pixel_rect.size.y <= 0:
		return
	var base := _get_base_scale()
	var margin := float(ConfigRepository.get_editor_value("asset_region_view", "fit_margin", 0.88))
	_zoom = 1.0
	_pan_offset = Vector2.ZERO
	var zoom_x := (size.x * margin) / (float(pixel_rect.size.x) * base)
	var zoom_y := (size.y * margin) / (float(pixel_rect.size.y) * base)
	_zoom = clampf(minf(zoom_x, zoom_y), 0.1, 16.0)
	_center_view_on_pixel(Vector2(pixel_rect.get_center()))

func _center_view_on_pixel(pixel: Vector2) -> void:
	if texture == null:
		return
	var image_size := Vector2(texture.get_size())
	var draw_size := image_size * _get_base_scale() * _zoom
	var centered := (size - draw_size) * 0.5
	var fraction := pixel / image_size
	var point := centered + fraction * draw_size
	_pan_offset = size * 0.5 - point

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("151d26"), true)
	if texture == null:
		draw_string(ThemeDB.fallback_font, Vector2(18, 30), "Choose a project image, then drag to select a region", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c2cbd4"))
		return
	var image_rect := _get_image_rect()
	draw_texture_rect(texture, image_rect, false)
	draw_rect(image_rect, Color("61717e"), false, 1.0)
	var highlight_rect := selected_region
	if _editing_pixels and _clip_erase_to_region:
		highlight_rect = _edit_clip_rect
	if highlight_rect.size.x > 0 and highlight_rect.size.y > 0:
		var pixel_size := Vector2(texture.get_size())
		var selected_rect := Rect2(image_rect.position + Vector2(highlight_rect.position) / pixel_size * image_rect.size, Vector2(highlight_rect.size) / pixel_size * image_rect.size)
		var fill := Color(0.95, 0.35, 0.35, 0.12) if _editing_pixels else Color(0.15, 0.88, 0.78, 0.2)
		var border := Color("ff6b6b") if _editing_pixels else Color("38e0c3")
		draw_rect(selected_rect, fill, true)
		draw_rect(selected_rect, border, false, 2.0)
		if not _editing_pixels:
			_draw_grid_overlay(selected_rect)
	if _dragging_region:
		var drag_rect := Rect2(_drag_start, _drag_end - _drag_start).abs().intersection(image_rect)
		draw_rect(drag_rect, Color(0.95, 0.75, 0.28, 0.2), true)
		draw_rect(drag_rect, Color("f2c14e"), false, 2.0)
	if _editing_pixels and image_rect.has_point(_last_pointer):
		var brush_rect := _brush_rect_at(_last_pointer, image_rect)
		draw_rect(brush_rect, Color(0.95, 0.3, 0.3, 0.25), true)
		draw_rect(brush_rect, Color("ff6b6b"), false, 1.0)
	var edit_hint := " · left drag erases alpha" if _editing_pixels else " · left drag selects region"
	var drag_status := ""
	if _dragging_region:
		var preview_region := _region_for_drag(_drag_start, _drag_end)
		drag_status = " · Selection %d × %d px" % [preview_region.size.x, preview_region.size.y]
	draw_string(ThemeDB.fallback_font, Vector2(10, size.y - 10), "Zoom %.0f%% · wheel zoom · Space/Alt/middle/right drag pan%s%s" % [_zoom * 100.0, edit_hint, drag_status], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("c2cbd4"))

func _frame_regions_valid() -> bool:
	if grid_frame_regions.size() != grid_frames:
		return false
	for values in grid_frame_regions:
		if not values is Array or values.size() < 4:
			return false
		for value in values.slice(0, 4):
			if not (value is int or value is float):
				return false
		if float(values[2]) <= 0.0 or float(values[3]) <= 0.0:
			return false
	return true

func _frame_rect_local(frame_index: int) -> Rect2:
	var index := clampi(frame_index, 0, maxi(0, grid_frames - 1))
	if _frame_regions_valid():
		var values: Array = grid_frame_regions[index]
		return Rect2(
			float(values[0]) - float(selected_region.position.x),
			float(values[1]) - float(selected_region.position.y),
			float(values[2]),
			float(values[3])
		)
	var column := index % grid_columns
	var row := index / grid_columns
	if grid_frame_order == "column_major":
		column = index / grid_rows
		row = index % grid_rows
	var left := floorf(float(selected_region.size.x) * float(column) / float(grid_columns))
	var right := floorf(float(selected_region.size.x) * float(column + 1) / float(grid_columns))
	var top := floorf(float(selected_region.size.y) * float(row) / float(grid_rows))
	var bottom := floorf(float(selected_region.size.y) * float(row + 1) / float(grid_rows))
	return Rect2(left, top, maxf(1.0, right - left), maxf(1.0, bottom - top))

func _frame_rect_to_view(local_rect: Rect2, selected_rect: Rect2) -> Rect2:
	if selected_region.size.x <= 0 or selected_region.size.y <= 0:
		return Rect2()
	var scale := selected_rect.size / Vector2(selected_region.size)
	return Rect2(
		selected_rect.position + local_rect.position * scale,
		local_rect.size * scale
	)

func _draw_grid_overlay(selected_rect: Rect2) -> void:
	if grid_frames <= 1:
		var anchor_point := selected_rect.position + selected_rect.size * grid_anchor
		draw_circle(anchor_point, 4.0, Color("ffd166"))
		draw_line(anchor_point - Vector2(8, 0), anchor_point + Vector2(8, 0), Color("ffd166"), 1.0)
		draw_line(anchor_point - Vector2(0, 8), anchor_point + Vector2(0, 8), Color("ffd166"), 1.0)
		return
	for frame_index in range(grid_frames):
		var cell_rect := _frame_rect_to_view(_frame_rect_local(frame_index), selected_rect)
		var cell_border := Color(0.3, 0.85, 1.0, 0.35) if frame_index == 0 else Color(0.9, 0.9, 0.9, 0.18)
		if frame_select_mode and frame_index == selected_frame_index:
			cell_border = Color("ff6b6b")
			draw_rect(cell_rect.grow(-2.0), Color(1.0, 0.35, 0.35, 0.08), true)
		draw_rect(cell_rect, cell_border, false, 3.0 if frame_select_mode and frame_index == selected_frame_index else 2.0)
		var anchor := grid_anchor
		if frame_index < grid_frame_anchors.size():
			var values: Variant = grid_frame_anchors[frame_index]
			if values is Array and values.size() >= 2:
				anchor = Vector2(clampf(float(values[0]), 0.0, 1.0), clampf(float(values[1]), 0.0, 1.0))
		var anchor_point := cell_rect.position + cell_rect.size * anchor
		var anchor_radius := 5.0 if frame_select_mode and frame_index == selected_frame_index else 3.0
		draw_circle(anchor_point, anchor_radius, Color("ffd166"))
		draw_line(anchor_point - Vector2(6, 0), anchor_point + Vector2(6, 0), Color("ffd166"), 1.0)
		draw_line(anchor_point - Vector2(0, 6), anchor_point + Vector2(0, 6), Color("ffd166"), 1.0)

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
			if mouse_event.pressed and frame_select_mode and not _editing_pixels and _get_image_rect().has_point(mouse_event.position):
				var region_rect := selected_region
				if region_rect.size.x > 0 and region_rect.size.y > 0 and grid_frames > 1:
					var pixel_size := Vector2(texture.get_size())
					var selected_rect := Rect2(_get_image_rect().position + Vector2(region_rect.position) / pixel_size * _get_image_rect().size, Vector2(region_rect.size) / pixel_size * _get_image_rect().size)
					if selected_rect.has_point(mouse_event.position):
						var selected_local := (mouse_event.position - selected_rect.position) / selected_rect.size * Vector2(region_rect.size)
						for frame_index in range(grid_frames):
							if _frame_rect_local(frame_index).has_point(selected_local):
								selected_frame_index = frame_index
								frame_selected.emit(frame_index)
								accept_event()
								queue_redraw()
								return
			if mouse_event.pressed and _get_image_rect().has_point(mouse_event.position):
				_last_pointer = mouse_event.position
				if _pan_input_active():
					_panning = true
					_last_pan_position = mouse_event.position
				elif _editing_pixels:
					_erase_at(mouse_event.position)
				else:
					_dragging_region = true
					_drag_start = mouse_event.position
					_drag_end = mouse_event.position
				accept_event()
				queue_redraw()
			elif not mouse_event.pressed:
				if _panning and not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
					_panning = false
				if _editing_pixels:
					accept_event()
				elif _dragging_region:
					_dragging_region = false
					_drag_end = _clamp_to_image(mouse_event.position)
					_commit_region_drag()
					accept_event()
				queue_redraw()
			return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		_last_pointer = motion.position
		var pan_active := _panning or (_pan_input_active() and bool(motion.button_mask & MOUSE_BUTTON_MASK_LEFT))
		if pan_active:
			_pan_offset += motion.position - _last_pan_position
			_last_pan_position = motion.position
			accept_event()
		elif _editing_pixels and motion.button_mask & MOUSE_BUTTON_MASK_LEFT and not _pan_input_active():
			_erase_at(motion.position)
			accept_event()
		elif _dragging_region:
			_drag_end = _clamp_to_image(motion.position)
			accept_event()
		queue_redraw()

func _input(event: InputEvent) -> void:
	if not _dragging_region or not event is InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or mouse_event.pressed:
		return
	var local_position := get_global_transform_with_canvas().affine_inverse() * mouse_event.position
	_drag_end = _clamp_to_image(local_position)
	_dragging_region = false
	_commit_region_drag()
	queue_redraw()
	get_viewport().set_input_as_handled()

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
	var rect := _trim_region_to_visible_pixels(_region_for_drag(_drag_start, _drag_end))
	if rect.size.x > 0 and rect.size.y > 0:
		selected_region = rect
		region_changed.emit(rect)

func _clamp_to_image(view_position: Vector2) -> Vector2:
	var image_rect := _get_image_rect()
	return Vector2(
		clampf(view_position.x, image_rect.position.x, image_rect.end.x),
		clampf(view_position.y, image_rect.position.y, image_rect.end.y)
	)

func _region_for_drag(start: Vector2, finish: Vector2) -> Rect2i:
	if texture == null:
		return Rect2i()
	var image_rect := _get_image_rect()
	var drag_rect := Rect2(start, finish - start).abs().intersection(image_rect)
	if drag_rect.size.x <= 0.0 or drag_rect.size.y <= 0.0:
		return Rect2i()
	var pixel_size := Vector2(texture.get_size())
	var top_left := ((drag_rect.position - image_rect.position) / image_rect.size * pixel_size).floor()
	var bottom_right := ((drag_rect.end - image_rect.position) / image_rect.size * pixel_size).ceil()
	return Rect2i(Vector2i(top_left), Vector2i(bottom_right - top_left))

func _trim_region_to_visible_pixels(region: Rect2i) -> Rect2i:
	if texture == null or region.size.x <= 0 or region.size.y <= 0:
		return Rect2i()
	var image := texture.get_image()
	if image == null or image.is_empty() or image.detect_alpha() == Image.ALPHA_NONE:
		return region
	var region_end := region.end.clamp(Vector2i.ZERO, Vector2i(image.get_width(), image.get_height()))
	var region_start := region.position.clamp(Vector2i.ZERO, Vector2i(image.get_width(), image.get_height()))
	var min_x := region_end.x
	var min_y := region_end.y
	var max_x := region_start.x - 1
	var max_y := region_start.y - 1
	for y in range(region_start.y, region_end.y):
		for x in range(region_start.x, region_end.x):
			if image.get_pixel(x, y).a > 0.0:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

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
			if target.x < 0 or target.y < 0 or target.x >= image_size.x or target.y >= image_size.y:
				continue
			if _clip_erase_to_region and not _edit_clip_rect.has_point(target):
				continue
			_edit_image.set_pixel(target.x, target.y, Color(0, 0, 0, 0))
	_edit_texture.update(_edit_image)
	queue_redraw()

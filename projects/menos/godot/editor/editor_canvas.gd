class_name EditorCanvas
extends Node2D

signal object_selected(info: Dictionary)
signal map_data_changed()
signal placement_resize_failed(message: String)
signal placement_rejected(message: String)

const TILESET: TileSet = preload("res://assets/menos/maps/northbridge_tileset.tres")
const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")
const MAX_UNDO_HISTORY := 100

var map_data: Dictionary = {}
var selected_object: Dictionary = {}

var editor_mode := "ASSET"
var edit_mode := "SELECT" # SELECT, PAINT, ERASE
var active_layer := "Ground" # Ground, Vegetation, RoadComposition
var gameplay_tool := "SELECT"
var selected_tile_source_id := 0
var selected_tile_atlas_coords := Vector2i.ZERO
var last_pointer_local := Vector2(-1, -1)
var eraser_preview_cell := Vector2i.ZERO
var eraser_preview_visible := false
var selected_catalog_asset: Dictionary = {}
var catalog_assets_by_id: Dictionary = {}
var catalog_texture_cache: Dictionary = {}
var catalog_alpha_cache: Dictionary = {}
var eraser_size := 1

func _map_tiles_size() -> Vector2i:
	var value: Variant = map_data.get("map_tiles", [36, 24])
	if value is Vector2i:
		return value
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i(36, 24)

func _map_origin() -> Vector2:
	var value: Variant = map_data.get("map_origin", [0, 58])
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2(0, 58)

func _map_pixel_size() -> Vector2:
	var value: Variant = map_data.get("map_pixel_size", [1152, 768])
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2(1152, 768)

var camera_zoom := 1.0
var camera_offset := Vector2.ZERO
var is_panning := false
var is_painting_drag := false
var is_moving_selection := false
var is_resizing_gameplay_area := false
var is_creating_gameplay_area := false
var is_resizing_placement := false
var operation_changed := false
var operation_start_world := Vector2.ZERO
var operation_start_position := Vector2.ZERO
var operation_start_size := Vector2.ZERO
var gameplay_area_drag_end := Vector2.ZERO
var resize_preview_footprint := Vector2i.ONE
var resize_start_footprint := Vector2i.ONE
var resize_start_world := Vector2.ZERO
var pan_start_pos := Vector2.ZERO
var undo_history: Array[Dictionary] = []
var edit_stroke_snapshot: Dictionary = {}
var edit_stroke_active := false
var edit_stroke_changed := false

func _ready() -> void:
	queue_redraw()

func set_map_data(data: Dictionary) -> void:
	map_data = data.duplicate(true)
	undo_history.clear()
	_fit_map_to_viewport.call_deferred()
	edit_stroke_snapshot.clear()
	edit_stroke_active = false
	edit_stroke_changed = false
	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	queue_redraw()

func set_map_size_preview(new_size: Vector2i) -> void:
	var safe_size := Vector2i(maxi(1, new_size.x), maxi(1, new_size.y))
	map_data["map_tiles"] = [safe_size.x, safe_size.y]
	map_data["map_pixel_size"] = [safe_size.x * 32, safe_size.y * 32]
	_fit_map_to_viewport()
	queue_redraw()

func set_editor_mode(mode: String) -> void:
	editor_mode = "GAMEPLAY" if mode == "GAMEPLAY" else "ASSET"
	gameplay_tool = "SELECT"
	edit_mode = "SELECT"
	is_moving_selection = false
	is_resizing_gameplay_area = false
	is_creating_gameplay_area = false
	select_object({})

func set_gameplay_tool(tool: String) -> void:
	editor_mode = "GAMEPLAY"
	gameplay_tool = tool
	edit_mode = "SELECT"
	selected_catalog_asset.clear()
	is_moving_selection = false
	is_resizing_gameplay_area = false
	is_creating_gameplay_area = false
	select_object({})

func set_edit_mode(mode: String) -> void:
	edit_mode = mode
	select_object({})
	_update_eraser_preview(last_pointer_local)

func set_active_layer(layer_name: String) -> void:
	active_layer = layer_name

func _fit_map_to_viewport() -> void:
	var viewport_control := get_parent() as Control
	if viewport_control == null:
		return
	var view_size := viewport_control.size
	var map_size := _map_pixel_size()
	if view_size.x <= 1.0 or view_size.y <= 1.0 or map_size.x <= 1.0 or map_size.y <= 1.0:
		return
	var margin := 48.0
	var available := Vector2(maxf(1.0, view_size.x - margin), maxf(1.0, view_size.y - margin))
	camera_zoom = clampf(minf(available.x / map_size.x, available.y / map_size.y), 0.25, 2.0)
	var origin := _map_origin()
	var map_center := origin + map_size * 0.5
	camera_offset = view_size * 0.5 - map_center * camera_zoom
	queue_redraw()

func set_eraser_size(size_in_tiles: int) -> void:
	eraser_size = clampi(size_in_tiles, 1, 10)
	queue_redraw()

func set_selected_tile(source_id: int, atlas_coords: Vector2i) -> void:
	selected_catalog_asset.clear()
	selected_tile_source_id = source_id
	selected_tile_atlas_coords = atlas_coords
	edit_mode = "PAINT"
	select_object({})
	queue_redraw()

func set_catalog_assets(entries: Array[Dictionary]) -> void:
	catalog_assets_by_id.clear()
	catalog_texture_cache.clear()
	catalog_alpha_cache.clear()
	for entry in entries:
		var asset_id := str(entry.get("asset_id", ""))
		if not asset_id.is_empty():
			catalog_assets_by_id[asset_id] = entry.duplicate(true)
	queue_redraw()

func set_catalog_asset(entry: Dictionary) -> void:
	selected_catalog_asset = entry.duplicate(true)
	editor_mode = "ASSET"
	select_object({})
	queue_redraw()

func get_catalog_texture(asset_id: String) -> Texture2D:
	var entry: Dictionary = catalog_assets_by_id.get(asset_id, {})
	if entry.is_empty():
		return null
	var source_path := str(entry.get("source_path", ""))
	if catalog_texture_cache.has(source_path):
		return catalog_texture_cache[source_path]
	var loaded: Texture2D = IMAGE_TEXTURE_LOADER.load_texture(source_path)
	if loaded != null:
		catalog_texture_cache[source_path] = loaded
		return loaded
	return null

func _catalog_asset_has_transparency(asset: Dictionary) -> bool:
	var asset_id := str(asset.get("asset_id", ""))
	var rect := catalog_source_rect(asset)
	var cache_key := "%s:%s:%s" % [asset_id, str(rect.position), str(rect.size)]
	if catalog_alpha_cache.has(cache_key):
		return bool(catalog_alpha_cache[cache_key])
	var texture := get_catalog_texture(asset_id)
	if texture == null:
		catalog_alpha_cache[cache_key] = false
		return false
	var image := texture.get_image()
	if image == null or image.is_empty():
		catalog_alpha_cache[cache_key] = false
		return false
	var image_rect := Rect2i(Vector2i(rect.position), Vector2i(rect.size)).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	var has_transparency := image_rect.size.x > 0 and image_rect.size.y > 0 and image.get_region(image_rect).detect_alpha() != Image.ALPHA_NONE
	catalog_alpha_cache[cache_key] = has_transparency
	return has_transparency

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.ctrl_pressed and not key_event.shift_pressed and key_event.keycode == KEY_Z:
			if _has_text_input_focus():
				return
			if edit_stroke_active:
				_finish_edit_stroke()
			if not undo_history.is_empty():
				_undo_last_edit()
				get_viewport().set_input_as_handled()
				if is_painting_drag and edit_mode in ["PAINT", "ERASE"]:
					_begin_edit_stroke()
			return
		if key_event.pressed and not key_event.echo and key_event.keycode in [KEY_DELETE, KEY_BACKSPACE]:
			if _has_text_input_focus():
				return
			if str(selected_object.get("type", "")) == "Goal":
				placement_rejected.emit("Base HQ is required by the runtime and cannot be deleted.")
			elif not delete_selected_editor_object():
				return
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		var local_position := viewport_to_canvas_position(mb_event.position)
		last_pointer_local = local_position
		var inside_canvas := pointer_is_inside_canvas(local_position)

		if mb_event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			if mb_event.pressed and inside_canvas:
				is_panning = true
				pan_start_pos = local_position
				_update_eraser_preview(local_position)
				get_viewport().set_input_as_handled()
			elif not mb_event.pressed and is_panning:
				is_panning = false
				_update_eraser_preview(local_position)
				get_viewport().set_input_as_handled()
		elif mb_event.button_index == MOUSE_BUTTON_LEFT:
			if not mb_event.pressed:
				if not (is_creating_gameplay_area or is_resizing_gameplay_area or is_moving_selection or is_resizing_placement or is_painting_drag):
					return
				if is_creating_gameplay_area:
					var end_world := (local_position - camera_offset) / camera_zoom
					create_gameplay_area(gameplay_tool.to_lower(), operation_start_world, end_world)
					is_creating_gameplay_area = false
					queue_redraw()
					get_viewport().set_input_as_handled()
					return
				if is_resizing_gameplay_area:
					var end_world := (local_position - camera_offset) / camera_zoom
					var final_size := _preview_gameplay_area_size(end_world)
					is_resizing_gameplay_area = false
					update_selected_gameplay_area_size(final_size)
					queue_redraw()
					get_viewport().set_input_as_handled()
					return
				if is_moving_selection:
					is_moving_selection = false
					if operation_changed:
						_mark_map_data_changed()
						_finish_edit_stroke()
						object_selected.emit(selected_object)
						queue_redraw()
						operation_changed = false
					else:
						_finish_edit_stroke()
						object_selected.emit(selected_object)
					get_viewport().set_input_as_handled()
					return
				if is_resizing_placement:
					var resize_world_pos := (local_position - camera_offset) / camera_zoom
					var footprint := _resize_footprint_for_drag(resize_world_pos)
					is_resizing_placement = false
					if footprint != resize_start_footprint and not resize_selected_catalog_placement(footprint.x, footprint.y):
						placement_resize_failed.emit("Resize failed: target bounds are outside the map or overlap another tile.")
					queue_redraw()
					get_viewport().set_input_as_handled()
					return
				if is_painting_drag:
					_finish_edit_stroke()
					is_painting_drag = false
					get_viewport().set_input_as_handled()
				return
			if not inside_canvas:
				return
			var world_pos: Vector2 = (local_position - camera_offset) / camera_zoom
			_update_eraser_preview(local_position)
			if editor_mode == "GAMEPLAY":
				if _is_gameplay_area_tool(gameplay_tool):
					operation_start_world = world_pos
					gameplay_area_drag_end = world_pos
					is_creating_gameplay_area = true
					queue_redraw()
					get_viewport().set_input_as_handled()
					return
				if _is_gameplay_point_tool(gameplay_tool):
					create_gameplay_point(gameplay_tool.to_lower(), world_pos)
					get_viewport().set_input_as_handled()
					return
				pick_object_at(world_pos)
				if _selected_gameplay_area_handle_contains(world_pos):
					is_resizing_gameplay_area = true
					operation_start_world = world_pos
					operation_start_size = _selected_gameplay_area_rect().size
					get_viewport().set_input_as_handled()
					return
				if _selected_gameplay_contains(world_pos):
					_begin_selected_move(world_pos)
				get_viewport().set_input_as_handled()
				return
			if edit_mode == "SELECT":
				pick_object_at(world_pos)
				if _selected_resize_handle_contains(world_pos):
					is_resizing_placement = true
					resize_start_world = world_pos
					var selected_footprint: Array = selected_object.get("footprint", [1, 1])
					resize_start_footprint = Vector2i(int(selected_footprint[0]), int(selected_footprint[1]))
					resize_preview_footprint = resize_start_footprint
					get_viewport().set_input_as_handled()
					return
				if _selected_catalog_placement_rect().has_point(world_pos):
					_begin_selected_move(world_pos)
				get_viewport().set_input_as_handled()
				return
			is_painting_drag = edit_mode in ["PAINT", "ERASE"]
			if is_painting_drag:
				_begin_edit_stroke()
			handle_canvas_click(world_pos)
			get_viewport().set_input_as_handled()
			return
		elif not inside_canvas:
			return
		elif mb_event.button_index == MOUSE_BUTTON_WHEEL_UP and mb_event.pressed:
			camera_zoom = minf(3.0, camera_zoom + 0.1)
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif mb_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb_event.pressed:
			camera_zoom = maxf(0.4, camera_zoom - 0.1)
			queue_redraw()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion:
		var mm_event := event as InputEventMouseMotion
		var local_position := viewport_to_canvas_position(mm_event.position)
		last_pointer_local = local_position
		_update_eraser_preview(local_position)
		if is_creating_gameplay_area:
			gameplay_area_drag_end = (local_position - camera_offset) / camera_zoom
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_resizing_gameplay_area:
			var world_pos := (local_position - camera_offset) / camera_zoom
			selected_object["size"] = _preview_gameplay_area_size(world_pos)
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_moving_selection:
			if pointer_is_inside_canvas(local_position):
				var world_pos := (local_position - camera_offset) / camera_zoom
				operation_changed = _apply_selected_move(world_pos) or operation_changed
				queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_resizing_placement:
			var world_pos := (local_position - camera_offset) / camera_zoom
			resize_preview_footprint = _resize_footprint_for_drag(world_pos)
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_panning:
			camera_offset += local_position - pan_start_pos
			pan_start_pos = local_position
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif is_painting_drag and edit_mode in ["PAINT", "ERASE"]:
			if pointer_is_inside_canvas(local_position):
				var world_pos: Vector2 = (local_position - camera_offset) / camera_zoom
				handle_canvas_click(world_pos)
			get_viewport().set_input_as_handled()
		elif edit_mode == "PAINT" and not selected_catalog_asset.is_empty():
			queue_redraw()
			get_viewport().set_input_as_handled()

func _has_text_input_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner is LineEdit or focus_owner is TextEdit

func _begin_edit_stroke() -> void:
	edit_stroke_snapshot = map_data.duplicate(true)
	edit_stroke_active = true
	edit_stroke_changed = false

func _finish_edit_stroke() -> void:
	if edit_stroke_active and edit_stroke_changed:
		undo_history.append(edit_stroke_snapshot)
		if undo_history.size() > MAX_UNDO_HISTORY:
			undo_history.pop_front()
	edit_stroke_snapshot = {}
	edit_stroke_active = false
	edit_stroke_changed = false

func _mark_map_data_changed() -> void:
	if edit_stroke_active:
		edit_stroke_changed = true
	map_data_changed.emit()
	queue_redraw()

func _undo_last_edit() -> void:
	map_data = undo_history.pop_back().duplicate(true)
	selected_object.clear()
	object_selected.emit({})
	map_data_changed.emit()
	queue_redraw()

func viewport_to_canvas_position(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position

func pointer_is_inside_canvas(local_position: Vector2) -> bool:
	var canvas_container := get_parent() as Control
	return canvas_container != null and Rect2(Vector2.ZERO, canvas_container.size).has_point(local_position)

func _update_eraser_preview(local_position: Vector2) -> void:
	var was_visible := eraser_preview_visible
	var old_cell := eraser_preview_cell
	eraser_preview_visible = edit_mode == "ERASE" and not is_panning and pointer_is_inside_canvas(local_position)
	if eraser_preview_visible:
		var world_pos := (local_position - camera_offset) / camera_zoom
		eraser_preview_cell = get_cell_coords(world_pos)
		var map_tiles: Vector2i = _map_tiles_size()
		eraser_preview_visible = eraser_preview_cell.x >= 0 and eraser_preview_cell.y >= 0 and eraser_preview_cell.x < map_tiles.x and eraser_preview_cell.y < map_tiles.y
	if was_visible != eraser_preview_visible or (eraser_preview_visible and old_cell != eraser_preview_cell):
		queue_redraw()

func _eraser_preview_rect() -> Rect2:
	var half_size := int(floor(float(eraser_size) / 2.0))
	var start_cell := eraser_preview_cell - Vector2i(half_size, half_size)
	var origin: Vector2 = _map_origin()
	return Rect2(origin + Vector2(start_cell) * 32.0, Vector2.ONE * float(eraser_size * 32))

func _selected_catalog_placement_rect() -> Rect2:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type not in ["Catalog Tile", "Catalog Object", "Catalog Tile Overlay"]:
		return Rect2()
	var footprint_values: Variant = selected_object.get("footprint", [1, 1])
	if not footprint_values is Array or footprint_values.size() < 2:
		return Rect2()
	var selected_position := object_position(selected_object)
	var footprint := Vector2i(maxi(1, int(footprint_values[0])), maxi(1, int(footprint_values[1])))
	return Rect2(selected_position, Vector2(footprint) * 32.0)

func _resize_handle_rect(placement_rect: Rect2) -> Rect2:
	var handle_size := 12.0 / camera_zoom
	return Rect2(placement_rect.end - Vector2.ONE * handle_size * 0.5, Vector2.ONE * handle_size)

func _selected_resize_handle_contains(world_pos: Vector2) -> bool:
	var placement_rect := _selected_catalog_placement_rect()
	return placement_rect.size.x > 0.0 and placement_rect.size.y > 0.0 and _resize_handle_rect(placement_rect).has_point(world_pos)

func _selected_gameplay_area_rect() -> Rect2:
	if str(selected_object.get("type", "")) != "Gameplay Area":
		return Rect2()
	return Rect2(selected_object.get("position", Vector2.ZERO), selected_object.get("size", Vector2.ZERO))

func _selected_gameplay_area_handle_contains(world_pos: Vector2) -> bool:
	var area_rect := _selected_gameplay_area_rect()
	return area_rect.size.x > 0.0 and area_rect.size.y > 0.0 and _resize_handle_rect(area_rect).has_point(world_pos)

func _selected_gameplay_contains(world_pos: Vector2) -> bool:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type == "Gameplay Area":
		return _selected_gameplay_area_rect().has_point(world_pos)
	if selection_type in ["Gameplay Point", "Goal", "Spawn", "Tower Slot", "Robot Spot"]:
		return _gameplay_point_hit_contains(selection_type, Vector2(selected_object.get("position", Vector2.ZERO)), world_pos)
	return false

func _gameplay_point_hit_contains(element_type: String, hit_position: Vector2, point: Vector2) -> bool:
	if element_type == "Goal":
		return Rect2(hit_position - Vector2(36.0, 24.0), Vector2(72.0, 48.0)).has_point(point)
	var hit_radius := 14.0
	match element_type:
		"Spawn":
			hit_radius = 30.0
		"Tower Slot":
			hit_radius = 30.0
		"Robot Spot":
			hit_radius = 35.0
	return hit_position.distance_to(point) <= hit_radius

func _preview_gameplay_area_size(world_pos: Vector2) -> Vector2:
	var delta := world_pos - operation_start_world
	var map_pixel_size_value: Variant = map_data.get("map_pixel_size", [1152, 768])
	var map_pixel_size: Vector2 = map_pixel_size_value if map_pixel_size_value is Vector2 else Vector2(float(map_pixel_size_value[0]), float(map_pixel_size_value[1])) if map_pixel_size_value is Array and map_pixel_size_value.size() >= 2 else Vector2(1152, 768)
	var origin_value: Variant = map_data.get("map_origin", [0, 58])
	var origin: Vector2 = origin_value if origin_value is Vector2 else Vector2(float(origin_value[0]), float(origin_value[1])) if origin_value is Array and origin_value.size() >= 2 else Vector2(0, 58)
	var area_position := Vector2(selected_object.get("position", Vector2.ZERO))
	var max_size := map_pixel_size - (area_position - origin)
	return Vector2(
		clampf(roundf((operation_start_size.x + delta.x) / 32.0) * 32.0, 32.0, max_size.x),
		clampf(roundf((operation_start_size.y + delta.y) / 32.0) * 32.0, 32.0, max_size.y)
	)

func _is_gameplay_area_tool(tool: String) -> bool:
	return tool in ["SPAWN_AREA", "TOWER_PLACEMENT_AREA", "GOAL_AREA", "OBSTACLE_AREA", "MOVEMENT_AREA", "BLOCKED_AREA"]

func _is_gameplay_point_tool(tool: String) -> bool:
	return tool in ["TOWER_PLACEMENT_POINT", "ROBOT_POSITION_POINT"]

func _begin_selected_move(world_pos: Vector2) -> void:
	operation_start_world = world_pos
	operation_start_position = Vector2(selected_object.get("position", Vector2.ZERO))
	operation_changed = false
	_begin_edit_stroke()
	is_moving_selection = true

func _move_catalog_tile_to(target_position: Vector2) -> bool:
	var layer_name := str(selected_object.get("layer", active_layer))
	var anchor_value: Variant = selected_object.get("cell", Vector2i.ZERO)
	if not anchor_value is Vector2i or not map_data.has("tiles") or not map_data["tiles"].has(layer_name):
		return false
	var old_anchor: Vector2i = anchor_value
	var origin: Vector2 = _map_origin()
	var new_anchor := get_cell_coords(target_position)
	if new_anchor == old_anchor:
		return false
	var footprint_values: Array = selected_object.get("footprint", [1, 1])
	var footprint := Vector2i(int(footprint_values[0]), int(footprint_values[1]))
	var map_tiles: Vector2i = _map_tiles_size()
	if new_anchor.x < 0 or new_anchor.y < 0 or new_anchor.x + footprint.x > map_tiles.x or new_anchor.y + footprint.y > map_tiles.y:
		return false
	var layer_tiles: Dictionary = map_data["tiles"][layer_name]
	var asset_id := str(selected_object.get("id", ""))
	var old_keys: Array[String] = []
	var values_by_offset: Dictionary = {}
	for key in layer_tiles.keys():
		var coordinates := str(key).split(",")
		if coordinates.size() < 2:
			continue
		var cell := Vector2i(coordinates[0].to_int(), coordinates[1].to_int())
		var tile_info: Variant = layer_tiles[key]
		if tile_info is Dictionary and str(tile_info.get("asset_id", "")) == asset_id and _catalog_tile_anchor(tile_info, cell) == old_anchor:
			old_keys.append(str(key))
			values_by_offset["%d,%d" % [cell.x - old_anchor.x, cell.y - old_anchor.y]] = tile_info.duplicate(true)
	if old_keys.is_empty():
		return false
	var old_key_lookup: Dictionary = {}
	for key in old_keys:
		old_key_lookup[key] = true
	for y in range(footprint.y):
		for x in range(footprint.x):
			var target_key := "%d,%d" % [new_anchor.x + x, new_anchor.y + y]
			if layer_tiles.has(target_key) and not old_key_lookup.has(target_key):
				return false
	for key in old_keys:
		layer_tiles.erase(key)
	for y in range(footprint.y):
		for x in range(footprint.x):
			var offset_key := "%d,%d" % [x, y]
			var tile_info: Dictionary = values_by_offset.get(offset_key, {"asset_id": asset_id})
			tile_info = tile_info.duplicate(true)
			tile_info["anchor"] = [new_anchor.x, new_anchor.y]
			if footprint != Vector2i.ONE:
				tile_info["footprint_tiles"] = [footprint.x, footprint.y]
			layer_tiles["%d,%d" % [new_anchor.x + x, new_anchor.y + y]] = tile_info
	map_data["tiles"][layer_name] = layer_tiles
	selected_object["cell"] = new_anchor
	selected_object["position"] = origin + Vector2(new_anchor) * 32.0
	return true

func _apply_selected_move(world_pos: Vector2) -> bool:
	var target_position := operation_start_position + (world_pos - operation_start_world)
	var selection_type := str(selected_object.get("type", ""))
	if selection_type == "Catalog Tile":
		return _move_catalog_tile_to(target_position)
	var map_origin_value: Variant = map_data.get("map_origin", [0, 58])
	var map_origin: Vector2 = map_origin_value if map_origin_value is Vector2 else Vector2(float(map_origin_value[0]), float(map_origin_value[1])) if map_origin_value is Array and map_origin_value.size() >= 2 else Vector2(0, 58)
	var map_pixel_size_value: Variant = map_data.get("map_pixel_size", [1152, 768])
	var map_pixel_size: Vector2 = map_pixel_size_value if map_pixel_size_value is Vector2 else Vector2(float(map_pixel_size_value[0]), float(map_pixel_size_value[1])) if map_pixel_size_value is Array and map_pixel_size_value.size() >= 2 else Vector2(1152, 768)
	var bounds := Rect2(map_origin, map_pixel_size)
	if selection_type == "Gameplay Area":
		var area_index := int(selected_object.get("element_index", -1))
		var areas: Array = map_data.get("gameplay_areas", [])
		if area_index < 0 or area_index >= areas.size() or not areas[area_index] is Dictionary:
			return false
		var area: Dictionary = areas[area_index].duplicate(true)
		var area_size := Vector2(selected_object.get("size", Vector2(32, 32)))
		target_position.x = clampf(target_position.x, bounds.position.x, bounds.end.x - area_size.x)
		target_position.y = clampf(target_position.y, bounds.position.y, bounds.end.y - area_size.y)
		area["position"] = [target_position.x, target_position.y]
		areas[area_index] = area
		map_data["gameplay_areas"] = areas
	elif selection_type == "Gameplay Point":
		var point_index := int(selected_object.get("element_index", -1))
		var points: Array = map_data.get("gameplay_points", [])
		if point_index < 0 or point_index >= points.size() or not points[point_index] is Dictionary:
			return false
		target_position.x = clampf(target_position.x, bounds.position.x, bounds.end.x)
		target_position.y = clampf(target_position.y, bounds.position.y, bounds.end.y)
		var point: Dictionary = points[point_index].duplicate(true)
		point["position"] = [target_position.x, target_position.y]
		points[point_index] = point
		map_data["gameplay_points"] = points
	elif selection_type in ["Goal", "Spawn", "Tower Slot", "Robot Spot"]:
		target_position.x = clampf(target_position.x, bounds.position.x, bounds.end.x)
		target_position.y = clampf(target_position.y, bounds.position.y, bounds.end.y)
		var legacy_field := str(selected_object.get("legacy_field", ""))
		if legacy_field == "base":
			map_data["base"] = target_position
		else:
			var legacy_points: Dictionary = map_data.get(legacy_field, {})
			var legacy_id := str(selected_object.get("id", ""))
			if not legacy_points.has(legacy_id):
				return false
			var legacy_value: Variant = legacy_points[legacy_id]
			if selection_type == "Tower Slot" and legacy_value is Dictionary:
				var tower_slot_data: Dictionary = legacy_value.duplicate(true)
				tower_slot_data["position"] = target_position
				legacy_points[legacy_id] = tower_slot_data
			else:
				legacy_points[legacy_id] = target_position
			map_data[legacy_field] = legacy_points
	elif selection_type in ["Catalog Object", "Catalog Tile Overlay"]:
		var object_index := int(selected_object.get("object_index", -1))
		var objects: Array = map_data.get("objects", [])
		if object_index < 0 or object_index >= objects.size() or not objects[object_index] is Dictionary:
			return false
		var footprint_values: Array = selected_object.get("footprint", [1, 1])
		var footprint_size := Vector2(float(footprint_values[0]), float(footprint_values[1])) * 32.0
		target_position.x = clampf(target_position.x, bounds.position.x, bounds.end.x - footprint_size.x)
		target_position.y = clampf(target_position.y, bounds.position.y, bounds.end.y - footprint_size.y)
		var object_data: Dictionary = objects[object_index].duplicate(true)
		object_data["position"] = [target_position.x, target_position.y]
		objects[object_index] = object_data
		map_data["objects"] = objects
	else:
		return false
	selected_object["position"] = target_position
	return target_position != operation_start_position

func _resize_footprint_for_drag(world_pos: Vector2) -> Vector2i:
	var delta_in_cells := (world_pos - resize_start_world) / 32.0
	return Vector2i(
		clampi(resize_start_footprint.x + roundi(delta_in_cells.x), 1, 128),
		clampi(resize_start_footprint.y + roundi(delta_in_cells.y), 1, 128)
	)

func handle_canvas_click(world_pos: Vector2) -> void:
	if edit_mode == "SELECT":
		pick_object_at(world_pos)
	elif edit_mode == "PAINT":
		paint_tile_at(world_pos)
	elif edit_mode == "ERASE":
		erase_tile_at(world_pos)

func get_cell_coords(world_pos: Vector2) -> Vector2i:
	var origin: Vector2 = _map_origin()
	var cell_x := int(floor((world_pos.x - origin.x) / 32.0))
	var cell_y := int(floor((world_pos.y - origin.y) / 32.0))
	return Vector2i(cell_x, cell_y)

func paint_tile_at(world_pos: Vector2) -> void:
	var map_tiles: Vector2i = _map_tiles_size()
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	if not selected_catalog_asset.is_empty():
		if str(selected_catalog_asset.get("kind", "tile")) == "object":
			place_catalog_object(cell)
		elif _catalog_asset_has_transparency(selected_catalog_asset):
			place_catalog_tile_overlay(cell)
		else:
			paint_catalog_tile(cell)
		return

	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	if not map_data["tiles"].has(active_layer):
		map_data["tiles"][active_layer] = {}

	var key := "%d,%d" % [cell.x, cell.y]
	var tile_info := [selected_tile_source_id, selected_tile_atlas_coords.x, selected_tile_atlas_coords.y]
	var layer_tiles: Dictionary = map_data["tiles"][active_layer]
	if layer_tiles.has(key):
		var existing_tile: Variant = layer_tiles[key]
		if existing_tile is Array and existing_tile == tile_info:
			return
		placement_rejected.emit("Placement blocked: target cell is occupied. Erase it first or choose an empty cell.")
		return
	layer_tiles[key] = tile_info
	_mark_map_data_changed()

func paint_catalog_tile(cell: Vector2i) -> void:
	var footprint := catalog_asset_footprint(selected_catalog_asset)
	var map_tiles: Vector2i = _map_tiles_size()
	if cell.x + footprint.x > map_tiles.x or cell.y + footprint.y > map_tiles.y:
		return
	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	if not map_data["tiles"].has(active_layer):
		map_data["tiles"][active_layer] = {}
	var layer_tiles: Dictionary = map_data["tiles"][active_layer]
	var asset_id := str(selected_catalog_asset.get("asset_id", ""))
	var anchor_key := "%d,%d" % [cell.x, cell.y]
	var existing_anchor: Variant = layer_tiles.get(anchor_key)
	if existing_anchor is Dictionary and str(existing_anchor.get("asset_id", "")) == asset_id and _catalog_tile_anchor(existing_anchor, cell) == cell and _catalog_tile_footprint(existing_anchor) == footprint:
		_select_catalog_tile(asset_id, cell, footprint)
		return
	for offset_y in range(footprint.y):
		for offset_x in range(footprint.x):
			var occupied_cell := cell + Vector2i(offset_x, offset_y)
			if layer_tiles.has("%d,%d" % [occupied_cell.x, occupied_cell.y]):
				placement_rejected.emit("Placement blocked: target area is occupied. Erase or delete the existing placement first.")
				return
	for offset_y in range(footprint.y):
		for offset_x in range(footprint.x):
			var occupied_cell := cell + Vector2i(offset_x, offset_y)
			var tile_info := {"asset_id": asset_id}
			if footprint != Vector2i.ONE:
				tile_info["anchor"] = [cell.x, cell.y]
				tile_info["footprint_tiles"] = [footprint.x, footprint.y]
			layer_tiles["%d,%d" % [occupied_cell.x, occupied_cell.y]] = tile_info
	_mark_map_data_changed()
	_select_catalog_tile(asset_id, cell, footprint)

func _select_catalog_tile(asset_id: String, anchor: Vector2i, footprint: Vector2i) -> void:
	var origin: Vector2 = _map_origin()
	select_object({
		"type": "Catalog Tile",
		"id": asset_id,
		"position": origin + Vector2(anchor) * 32.0,
		"layer": active_layer,
		"cell": anchor,
		"footprint": [footprint.x, footprint.y]
	})

func place_catalog_tile_overlay(cell: Vector2i) -> void:
	var footprint := catalog_asset_footprint(selected_catalog_asset)
	var map_tiles: Vector2i = _map_tiles_size()
	if cell.x + footprint.x > map_tiles.x or cell.y + footprint.y > map_tiles.y:
		return
	if not map_data.has("objects"):
		map_data["objects"] = []
	var asset_id := str(selected_catalog_asset.get("asset_id", ""))
	var origin: Vector2 = _map_origin()
	var tile_position := origin + Vector2(cell) * 32.0
	var objects: Array = map_data["objects"]
	for index in range(objects.size()):
		var object_data: Dictionary = objects[index]
		if str(object_data.get("asset_id", "")) == asset_id and str(object_data.get("placement_layer", "")) == active_layer and object_position(object_data) == tile_position:
			select_object({
				"type": "Catalog Tile Overlay",
				"id": asset_id,
				"position": tile_position,
				"object_index": index,
				"layer": active_layer,
				"footprint": [footprint.x, footprint.y]
			})
			return
	objects.append({
		"asset_id": asset_id,
		"position": [tile_position.x, tile_position.y],
		"footprint_tiles": [footprint.x, footprint.y],
		"placement_layer": active_layer
	})
	map_data["objects"] = objects
	_mark_map_data_changed()
	select_object({
		"type": "Catalog Tile Overlay",
		"id": asset_id,
		"position": tile_position,
		"object_index": objects.size() - 1,
		"layer": active_layer,
		"footprint": [footprint.x, footprint.y]
	})

func _catalog_tile_anchor(tile_info: Dictionary, cell: Vector2i) -> Vector2i:
	var anchor_values: Variant = tile_info.get("anchor", [])
	if anchor_values is Array and anchor_values.size() >= 2:
		return Vector2i(int(anchor_values[0]), int(anchor_values[1]))
	return cell

func _catalog_tile_footprint(tile_info: Dictionary) -> Vector2i:
	var asset_id := str(tile_info.get("asset_id", ""))
	var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
	return catalog_asset_footprint(asset, tile_info)


func catalog_asset_footprint(asset: Dictionary, placement_data: Dictionary = {}) -> Vector2i:
	var override_values: Variant = placement_data.get("footprint_override", [])
	if override_values is Array and override_values.size() >= 2:
		return Vector2i(maxi(1, int(override_values[0])), maxi(1, int(override_values[1])))
	var asset_id := str(asset.get("asset_id", ""))
	var defaults: Variant = map_data.get("asset_footprint_defaults", {})
	if defaults is Dictionary:
		var default_values: Variant = defaults.get(asset_id, [])
		if default_values is Array and default_values.size() >= 2:
			return Vector2i(maxi(1, int(default_values[0])), maxi(1, int(default_values[1])))
	var rect_values: Variant = asset.get("source_rect_px", [])
	if rect_values is Array and rect_values.size() >= 4:
		var width_px := float(rect_values[2])
		var height_px := float(rect_values[3])
		if width_px > 0.0 and height_px > 0.0:
			return Vector2i(maxi(1, ceili(width_px / 32.0)), maxi(1, ceili(height_px / 32.0)))
	var values: Variant = asset.get("footprint_tiles", placement_data.get("footprint_tiles", []))
	if values is Array and values.size() >= 2:
		return Vector2i(maxi(1, int(values[0])), maxi(1, int(values[1])))
	return Vector2i.ONE

func _tile_placement_contains(tile_info: Dictionary, tile_cell: Vector2i, target_cell: Vector2i) -> bool:
	var anchor := _catalog_tile_anchor(tile_info, tile_cell)
	var footprint := _catalog_tile_footprint(tile_info)
	return target_cell.x >= anchor.x and target_cell.y >= anchor.y and target_cell.x < anchor.x + footprint.x and target_cell.y < anchor.y + footprint.y

func _remove_catalog_tile_at(layer_tiles: Dictionary, target_cell: Vector2i) -> bool:
	var target_key := "%d,%d" % [target_cell.x, target_cell.y]
	var matched_anchor := Vector2i.ZERO
	var found_catalog_placement := false
	for key in layer_tiles.keys():
		var parts := str(key).split(",")
		if parts.size() < 2:
			continue
		var tile_cell := Vector2i(parts[0].to_int(), parts[1].to_int())
		var tile_info: Variant = layer_tiles[key]
		if tile_info is Dictionary and tile_info.has("asset_id") and _tile_placement_contains(tile_info, tile_cell, target_cell):
			matched_anchor = _catalog_tile_anchor(tile_info, tile_cell)
			found_catalog_placement = true
			break
	if not found_catalog_placement:
		if layer_tiles.has(target_key):
			layer_tiles.erase(target_key)
			return true
		return false
	var anchor_key := "%d,%d" % [matched_anchor.x, matched_anchor.y]
	var anchor_value: Variant = layer_tiles.get(anchor_key)
	if not anchor_value is Dictionary or not anchor_value.has("anchor"):
		if layer_tiles.has(anchor_key):
			layer_tiles.erase(anchor_key)
			return true
		return false
	var keys_to_remove: Array = []
	for key in layer_tiles.keys():
		var value: Variant = layer_tiles[key]
		if value is Dictionary and value.get("anchor", []) == [matched_anchor.x, matched_anchor.y]:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		layer_tiles.erase(key)
	return not keys_to_remove.is_empty()

func place_catalog_object(cell: Vector2i) -> void:
	var footprint := catalog_asset_footprint(selected_catalog_asset)
	var width := footprint.x
	var height := footprint.y
	var map_tiles: Vector2i = _map_tiles_size()
	if cell.x + width > map_tiles.x or cell.y + height > map_tiles.y:
		return
	if not map_data.has("objects"):
		map_data["objects"] = []
	var origin: Vector2 = _map_origin()
	var object_pixel_pos := origin + Vector2(cell.x * 32, cell.y * 32)
	map_data["objects"].append({
		"asset_id": str(selected_catalog_asset.get("asset_id", "")),
		"position": [object_pixel_pos.x, object_pixel_pos.y],
		"footprint_tiles": [width, height]
	})
	_mark_map_data_changed()
	select_object({
		"type": "Catalog Object",
		"id": str(selected_catalog_asset.get("asset_id", "")),
		"position": object_pixel_pos,
		"object_index": map_data["objects"].size() - 1,
		"footprint": [width, height]
	})

func resize_selected_catalog_placement(width_tiles: int, height_tiles: int) -> bool:
	var footprint := Vector2i(maxi(1, width_tiles), maxi(1, height_tiles))
	var map_tiles: Vector2i = _map_tiles_size()
	var selection_type := str(selected_object.get("type", ""))
	var asset_id := str(selected_object.get("id", ""))
	if asset_id.is_empty():
		return false
	if selection_type in ["Catalog Object", "Catalog Tile Overlay"]:
		var objects: Array = map_data.get("objects", [])
		var object_index := int(selected_object.get("object_index", -1))
		if object_index < 0 or object_index >= objects.size():
			return false
		var object_data: Dictionary = objects[object_index].duplicate(true)
		var cell := get_cell_coords(object_position(object_data))
		if cell.x < 0 or cell.y < 0 or cell.x + footprint.x > map_tiles.x or cell.y + footprint.y > map_tiles.y:
			return false
		_begin_edit_stroke()
		object_data["footprint_override"] = [footprint.x, footprint.y]
		objects[object_index] = object_data
		map_data["objects"] = objects
	elif selection_type == "Catalog Tile":
		var layer_name := str(selected_object.get("layer", active_layer))
		var anchor_value: Variant = selected_object.get("cell", Vector2i.ZERO)
		if not anchor_value is Vector2i or not map_data.has("tiles"):
			return false
		var anchor: Vector2i = anchor_value
		if anchor.x < 0 or anchor.y < 0 or anchor.x + footprint.x > map_tiles.x or anchor.y + footprint.y > map_tiles.y:
			return false
		var tiles: Dictionary = map_data["tiles"]
		if not tiles.has(layer_name):
			return false
		var layer_tiles: Dictionary = tiles[layer_name]
		var placement_keys: Array[String] = []
		for key in layer_tiles.keys():
			var coordinates := str(key).split(",")
			if coordinates.size() < 2:
				continue
			var cell := Vector2i(coordinates[0].to_int(), coordinates[1].to_int())
			var tile_info: Variant = layer_tiles[key]
			if tile_info is Dictionary and str(tile_info.get("asset_id", "")) == asset_id and _catalog_tile_anchor(tile_info, cell) == anchor:
				placement_keys.append(str(key))
		if placement_keys.is_empty():
			return false
		var existing_keys: Dictionary = {}
		for key in placement_keys:
			existing_keys[key] = true
		for y in range(footprint.y):
			for x in range(footprint.x):
				var key := "%d,%d" % [anchor.x + x, anchor.y + y]
				if layer_tiles.has(key) and not existing_keys.has(key):
					return false
		_begin_edit_stroke()
		for key in placement_keys:
			layer_tiles.erase(key)
		for y in range(footprint.y):
			for x in range(footprint.x):
				var cell := anchor + Vector2i(x, y)
				var key := "%d,%d" % [cell.x, cell.y]
				layer_tiles[key] = {
					"asset_id": asset_id,
					"anchor": [anchor.x, anchor.y],
					"footprint_override": [footprint.x, footprint.y]
				}
		tiles[layer_name] = layer_tiles
		map_data["tiles"] = tiles
	else:
		return false
	_set_asset_footprint_default(asset_id, footprint)
	_mark_map_data_changed()
	_finish_edit_stroke()
	var updated_selection := selected_object.duplicate(true)
	updated_selection["footprint"] = [footprint.x, footprint.y]
	select_object(updated_selection)
	return true

func _set_asset_footprint_default(asset_id: String, footprint: Vector2i) -> void:
	var defaults: Dictionary = map_data.get("asset_footprint_defaults", {})
	defaults[asset_id] = [footprint.x, footprint.y]
	map_data["asset_footprint_defaults"] = defaults

func delete_selected_catalog_placement() -> bool:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type in ["Catalog Object", "Catalog Tile Overlay"]:
		var objects: Array = map_data.get("objects", [])
		var object_index := int(selected_object.get("object_index", -1))
		if object_index < 0 or object_index >= objects.size():
			return false
		_begin_edit_stroke()
		objects.remove_at(object_index)
		map_data["objects"] = objects
	elif selection_type == "Catalog Tile":
		var layer_name := str(selected_object.get("layer", active_layer))
		var anchor_value: Variant = selected_object.get("cell", Vector2i.ZERO)
		if not anchor_value is Vector2i or not map_data.has("tiles") or not map_data["tiles"].has(layer_name):
			return false
		var anchor: Vector2i = anchor_value
		var asset_id := str(selected_object.get("id", ""))
		var layer_tiles: Dictionary = map_data["tiles"][layer_name]
		var placement_keys: Array[String] = []
		for key in layer_tiles.keys():
			var coordinates := str(key).split(",")
			if coordinates.size() < 2:
				continue
			var cell := Vector2i(coordinates[0].to_int(), coordinates[1].to_int())
			var tile_info: Variant = layer_tiles[key]
			if tile_info is Dictionary and str(tile_info.get("asset_id", "")) == asset_id and _catalog_tile_anchor(tile_info, cell) == anchor:
				placement_keys.append(str(key))
		if placement_keys.is_empty():
			return false
		_begin_edit_stroke()
		for key in placement_keys:
			layer_tiles.erase(key)
		var tiles: Dictionary = map_data["tiles"]
		tiles[layer_name] = layer_tiles
		map_data["tiles"] = tiles
	else:
		return false
	_mark_map_data_changed()
	_finish_edit_stroke()
	select_object({})
	return true

func create_gameplay_area(element_type: String, start_world: Vector2, end_world: Vector2) -> bool:
	var map_tiles: Vector2i = _map_tiles_size()
	var start_cell := get_cell_coords(start_world)
	var end_cell := get_cell_coords(end_world)
	start_cell.x = clampi(start_cell.x, 0, map_tiles.x - 1)
	start_cell.y = clampi(start_cell.y, 0, map_tiles.y - 1)
	end_cell.x = clampi(end_cell.x, 0, map_tiles.x - 1)
	end_cell.y = clampi(end_cell.y, 0, map_tiles.y - 1)
	var first_cell := Vector2i(mini(start_cell.x, end_cell.x), mini(start_cell.y, end_cell.y))
	var last_cell := Vector2i(maxi(start_cell.x, end_cell.x), maxi(start_cell.y, end_cell.y))
	var origin: Vector2 = _map_origin()
	var area_position := origin + Vector2(first_cell) * 32.0
	var area_size := Vector2(last_cell - first_cell + Vector2i.ONE) * 32.0
	var element_id := _new_gameplay_id(element_type)
	var areas: Array = map_data.get("gameplay_areas", [])
	_begin_edit_stroke()
	areas.append({
		"id": element_id,
		"type": element_type,
		"name": _gameplay_type_label(element_type),
		"position": [area_position.x, area_position.y],
		"size": [area_size.x, area_size.y],
		"enabled": true
	})
	map_data["gameplay_areas"] = areas
	_mark_map_data_changed()
	_finish_edit_stroke()
	_select_gameplay_area(areas.size() - 1)
	return true

func create_gameplay_point(element_type: String, world_pos: Vector2) -> bool:
	var map_tiles: Vector2i = _map_tiles_size()
	var cell := get_cell_coords(world_pos)
	if cell.x < 0 or cell.y < 0 or cell.x >= map_tiles.x or cell.y >= map_tiles.y:
		return false
	var origin: Vector2 = _map_origin()
	var point_position := origin + Vector2(cell) * 32.0 + Vector2.ONE * 16.0
	var element_id := _new_gameplay_id(element_type)
	var points: Array = map_data.get("gameplay_points", [])
	_begin_edit_stroke()
	points.append({
		"id": element_id,
		"type": element_type,
		"name": _gameplay_type_label(element_type),
		"position": [point_position.x, point_position.y],
		"area_id": "",
		"enabled": true
	})
	map_data["gameplay_points"] = points
	_mark_map_data_changed()
	_finish_edit_stroke()
	_select_gameplay_point(points.size() - 1)
	return true

func _new_gameplay_id(element_type: String) -> String:
	var base_id := "gameplay.%s.%d" % [element_type, Time.get_ticks_usec()]
	var candidate_id := base_id
	var suffix := 1
	while _gameplay_id_exists(candidate_id):
		candidate_id = "%s.%d" % [base_id, suffix]
		suffix += 1
	return candidate_id

func _gameplay_type_label(element_type: String) -> String:
	var words := element_type.trim_prefix("gameplay_").replace("_", " ").split(" ")
	for index in range(words.size()):
		words[index] = str(words[index]).capitalize()
	return " ".join(words)

func _select_gameplay_area(index: int) -> void:
	var areas: Array = map_data.get("gameplay_areas", [])
	if index < 0 or index >= areas.size() or not areas[index] is Dictionary:
		return
	var area: Dictionary = areas[index]
	var pos := object_position(area)
	var size_values: Variant = area.get("size", [32.0, 32.0])
	var area_size := Vector2(float(size_values[0]), float(size_values[1])) if size_values is Array and size_values.size() >= 2 else Vector2(32.0, 32.0)
	select_object({
		"type": "Gameplay Area",
		"id": str(area.get("id", "")),
		"element_type": str(area.get("type", "")),
		"element_index": index,
		"position": pos,
		"size": area_size,
		"enabled": bool(area.get("enabled", true)),
		"name": str(area.get("name", ""))
	})

func _select_gameplay_point(index: int) -> void:
	var points: Array = map_data.get("gameplay_points", [])
	if index < 0 or index >= points.size() or not points[index] is Dictionary:
		return
	var point: Dictionary = points[index]
	select_object({
		"type": "Gameplay Point",
		"id": str(point.get("id", "")),
		"element_type": str(point.get("type", "")),
		"element_index": index,
		"position": object_position(point),
		"area_id": str(point.get("area_id", "")),
		"enabled": bool(point.get("enabled", true)),
		"name": str(point.get("name", ""))
	})

func update_selected_gameplay_properties(element_id: String, element_name: String, enabled: bool, area_id: String = "") -> bool:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type == "Goal":
		return element_id.strip_edges() == "base_hq" and enabled
	if selection_type in ["Spawn", "Tower Slot", "Robot Spot"]:
		var legacy_field := str(selected_object.get("legacy_field", ""))
		var legacy_points: Dictionary = map_data.get(legacy_field, {})
		var legacy_old_id := str(selected_object.get("id", ""))
		var new_id := element_id.strip_edges()
		if not enabled or new_id.is_empty() or not legacy_points.has(legacy_old_id):
			return false
		if new_id != legacy_old_id and legacy_points.has(new_id):
			return false
		_begin_edit_stroke()
		var point_position: Vector2 = legacy_points[legacy_old_id]
		legacy_points.erase(legacy_old_id)
		legacy_points[new_id] = point_position
		map_data[legacy_field] = legacy_points
		selected_object["id"] = new_id
		_mark_map_data_changed()
		_finish_edit_stroke()
		select_object(selected_object.duplicate(true))
		return true
	var index := int(selected_object.get("element_index", -1))
	var key := "gameplay_areas" if selection_type == "Gameplay Area" else "gameplay_points"
	if selection_type not in ["Gameplay Area", "Gameplay Point"]:
		return false
	var elements: Array = map_data.get(key, [])
	if index < 0 or index >= elements.size() or not elements[index] is Dictionary:
		return false
	var previous_element_id := str(elements[index].get("id", ""))
	if element_id.strip_edges().is_empty() or _gameplay_id_exists(element_id.strip_edges(), selection_type, index):
		return false
	if selection_type == "Gameplay Point" and not area_id.is_empty() and not _gameplay_area_exists(area_id):
		return false
	var updated: Dictionary = elements[index].duplicate(true)
	updated["id"] = element_id.strip_edges()
	updated["name"] = element_name.strip_edges() if not element_name.strip_edges().is_empty() else _gameplay_type_label(str(updated.get("type", "")))
	updated["enabled"] = enabled
	if selection_type == "Gameplay Point":
		updated["area_id"] = area_id.strip_edges()
	_begin_edit_stroke()
	elements[index] = updated
	map_data[key] = elements
	if selection_type == "Gameplay Area" and previous_element_id != str(updated["id"]):
		var points: Array = map_data.get("gameplay_points", [])
		for point_index in range(points.size()):
			if points[point_index] is Dictionary and str(points[point_index].get("area_id", "")) == previous_element_id:
				var point: Dictionary = points[point_index].duplicate(true)
				point["area_id"] = str(updated["id"])
				points[point_index] = point
		map_data["gameplay_points"] = points
	_mark_map_data_changed()
	_finish_edit_stroke()
	if selection_type == "Gameplay Area":
		_select_gameplay_area(index)
	else:
		_select_gameplay_point(index)
	return true

func update_selected_gameplay_area_size(new_size: Vector2) -> bool:
	if str(selected_object.get("type", "")) != "Gameplay Area":
		return false
	var index := int(selected_object.get("element_index", -1))
	var areas: Array = map_data.get("gameplay_areas", [])
	if index < 0 or index >= areas.size() or not areas[index] is Dictionary:
		return false
	var area: Dictionary = areas[index].duplicate(true)
	var map_pixel_size: Vector2 = _map_pixel_size()
	var area_position := object_position(area)
	var bounded_size := Vector2(
		clampf(new_size.x, 32.0, map_pixel_size.x - (area_position.x - float(_map_origin().x))),
		clampf(new_size.y, 32.0, map_pixel_size.y - (area_position.y - float(_map_origin().y)))
	)
	area["size"] = [bounded_size.x, bounded_size.y]
	_begin_edit_stroke()
	areas[index] = area
	map_data["gameplay_areas"] = areas
	_mark_map_data_changed()
	_finish_edit_stroke()
	_select_gameplay_area(index)
	return true

func update_selected_gameplay_position(new_position: Vector2) -> bool:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type not in ["Gameplay Area", "Gameplay Point", "Goal", "Spawn", "Tower Slot", "Robot Spot"]:
		return false
	var map_origin: Vector2 = _map_origin()
	var map_pixel_size: Vector2 = _map_pixel_size()
	var bounds := Rect2(map_origin, map_pixel_size)
	var bounded_position := new_position
	if selection_type == "Gameplay Area":
		var area_size := Vector2(selected_object.get("size", Vector2(32, 32)))
		bounded_position.x = clampf(bounded_position.x, bounds.position.x, bounds.end.x - area_size.x)
		bounded_position.y = clampf(bounded_position.y, bounds.position.y, bounds.end.y - area_size.y)
	else:
		bounded_position.x = clampf(bounded_position.x, bounds.position.x, bounds.end.x)
		bounded_position.y = clampf(bounded_position.y, bounds.position.y, bounds.end.y)
	if bounded_position == Vector2(selected_object.get("position", Vector2.ZERO)):
		return false
	_begin_edit_stroke()
	if selection_type in ["Gameplay Area", "Gameplay Point"]:
		var index := int(selected_object.get("element_index", -1))
		var key := "gameplay_areas" if selection_type == "Gameplay Area" else "gameplay_points"
		var elements: Array = map_data.get(key, [])
		if index < 0 or index >= elements.size() or not elements[index] is Dictionary:
			_finish_edit_stroke()
			return false
		var element: Dictionary = elements[index].duplicate(true)
		element["position"] = [bounded_position.x, bounded_position.y]
		elements[index] = element
		map_data[key] = elements
	elif selection_type == "Goal":
		map_data["base"] = bounded_position
	else:
		var legacy_field := str(selected_object.get("legacy_field", ""))
		var legacy_points: Dictionary = map_data.get(legacy_field, {})
		var legacy_id := str(selected_object.get("id", ""))
		if not legacy_points.has(legacy_id):
			_finish_edit_stroke()
			return false
		legacy_points[legacy_id] = bounded_position
		map_data[legacy_field] = legacy_points
	_mark_map_data_changed()
	_finish_edit_stroke()
	var updated_selection := selected_object.duplicate(true)
	updated_selection["position"] = bounded_position
	select_object(updated_selection)
	return true

func _gameplay_id_exists(element_id: String, selection_type: String = "", except_index: int = -1) -> bool:
	for key in ["gameplay_areas", "gameplay_points"]:
		var elements: Array = map_data.get(key, [])
		for index in range(elements.size()):
			if key == ("gameplay_areas" if selection_type == "Gameplay Area" else "gameplay_points") and index == except_index:
				continue
			if elements[index] is Dictionary and str(elements[index].get("id", "")) == element_id:
				return true
	return false

func _gameplay_area_exists(area_id: String) -> bool:
	for area in map_data.get("gameplay_areas", []):
		if area is Dictionary and str(area.get("id", "")) == area_id:
			return true
	return false

func delete_selected_editor_object() -> bool:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type in ["Catalog Tile", "Catalog Object", "Catalog Tile Overlay"]:
		return delete_selected_catalog_placement()
	if selection_type == "Gameplay Area":
		var area_index := int(selected_object.get("element_index", -1))
		var areas: Array = map_data.get("gameplay_areas", [])
		if area_index < 0 or area_index >= areas.size():
			return false
		var removed_id := str(areas[area_index].get("id", ""))
		_begin_edit_stroke()
		areas.remove_at(area_index)
		map_data["gameplay_areas"] = areas
		var points: Array = map_data.get("gameplay_points", [])
		for index in range(points.size()):
			if points[index] is Dictionary and str(points[index].get("area_id", "")) == removed_id:
				var point: Dictionary = points[index].duplicate(true)
				point["area_id"] = ""
				points[index] = point
		map_data["gameplay_points"] = points
	elif selection_type == "Gameplay Point":
		var point_index := int(selected_object.get("element_index", -1))
		var points: Array = map_data.get("gameplay_points", [])
		if point_index < 0 or point_index >= points.size():
			return false
		_begin_edit_stroke()
		points.remove_at(point_index)
		map_data["gameplay_points"] = points
	elif selection_type in ["Spawn", "Tower Slot", "Robot Spot"]:
		var legacy_field := str(selected_object.get("legacy_field", ""))
		var legacy_points: Dictionary = map_data.get(legacy_field, {})
		var legacy_id := str(selected_object.get("id", ""))
		if not legacy_points.has(legacy_id):
			return false
		_begin_edit_stroke()
		legacy_points.erase(legacy_id)
		map_data[legacy_field] = legacy_points
	else:
		return false
	_mark_map_data_changed()
	_finish_edit_stroke()
	select_object({})
	return true

func erase_tile_at(world_pos: Vector2) -> void:
	var map_tiles: Vector2i = _map_tiles_size()
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	var half_size := int(floor(float(eraser_size) / 2.0))
	var start_cell := cell - Vector2i(half_size, half_size)
	var origin: Vector2 = _map_origin()
	var erase_rect := Rect2(origin + Vector2(start_cell) * 32.0, Vector2.ONE * float(eraser_size * 32))
	var changed := false
	var objects: Array = map_data.get("objects", [])
	for index in range(objects.size() - 1, -1, -1):
		var object_data: Dictionary = objects[index]
		var asset_id := str(object_data.get("asset_id", ""))
		var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
		var footprint := catalog_asset_footprint(asset, object_data)
		var object_rect := Rect2(object_position(object_data), Vector2(footprint) * 32.0)
		if erase_rect.intersects(object_rect):
			objects.remove_at(index)
			changed = true
	if changed:
		map_data["objects"] = objects
	if not map_data.has("tiles"):
		if changed:
			_mark_map_data_changed()
		return
	var tiles: Dictionary = map_data["tiles"]
	for layer_name in tiles.keys():
		var layer_tiles: Dictionary = tiles[layer_name]
		var layer_changed := false
		for offset_y in range(eraser_size):
			for offset_x in range(eraser_size):
				var target_cell := start_cell + Vector2i(offset_x, offset_y)
				if target_cell.x < 0 or target_cell.x >= map_tiles.x or target_cell.y < 0 or target_cell.y >= map_tiles.y:
					continue
				var target_key := "%d,%d" % [target_cell.x, target_cell.y]
				if not layer_tiles.has(target_key):
					continue
				var tile_info: Variant = layer_tiles[target_key]
				if tile_info is Dictionary and tile_info.has("asset_id"):
					layer_changed = _remove_catalog_tile_at(layer_tiles, target_cell) or layer_changed
				else:
					layer_tiles.erase(target_key)
					layer_changed = true
		changed = layer_changed or changed
	if changed:
		map_data["tiles"] = tiles
	if changed:
		_mark_map_data_changed()

func object_position(object_data: Dictionary) -> Vector2:
	var raw_position: Variant = object_data.get("position", [0.0, 0.0])
	if raw_position is Vector2:
		return raw_position
	if raw_position is Array and raw_position.size() >= 2:
		return Vector2(float(raw_position[0]), float(raw_position[1]))
	return Vector2.ZERO

func pick_object_at(point: Vector2) -> void:
	if editor_mode == "GAMEPLAY" and _pick_gameplay_element_at(point):
		return
	if _pick_visual_asset_at(point):
		return
	if editor_mode != "GAMEPLAY" and _pick_gameplay_element_at(point):
		return
	select_object({})

func _pick_visual_asset_at(point: Vector2) -> bool:
	var objects: Array = map_data.get("objects", [])
	for object_index in range(objects.size() - 1, -1, -1):
		var object_data: Dictionary = objects[object_index]
		var asset_id := str(object_data.get("asset_id", ""))
		var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
		var footprint := catalog_asset_footprint(asset, object_data)
		var object_rect := Rect2(object_position(object_data), Vector2(footprint) * 32.0)
		if object_rect.has_point(point):
			var placement_type := "Catalog Tile Overlay" if object_data.has("placement_layer") else "Catalog Object"
			select_object({"type": placement_type, "id": asset_id, "position": object_position(object_data), "object_index": object_index, "layer": str(object_data.get("placement_layer", "")), "footprint": [footprint.x, footprint.y]})
			return true
	if _pick_catalog_tile_at(point):
		return true
	return false


func _pick_gameplay_element_at(point: Vector2) -> bool:
	var points: Array = map_data.get("gameplay_points", [])
	for index in range(points.size() - 1, -1, -1):
		if not points[index] is Dictionary:
			continue
		var gameplay_point: Dictionary = points[index]
		if object_position(gameplay_point).distance_to(point) <= 14.0:
			_select_gameplay_point(index)
			return true
	var areas: Array = map_data.get("gameplay_areas", [])
	for index in range(areas.size() - 1, -1, -1):
		if not areas[index] is Dictionary:
			continue
		var area: Dictionary = areas[index]
		var size_values: Variant = area.get("size", [32.0, 32.0])
		if not size_values is Array or size_values.size() < 2:
			continue
		var area_rect := Rect2(object_position(area), Vector2(float(size_values[0]), float(size_values[1])))
		if area_rect.has_point(point):
			_select_gameplay_area(index)
			return true
	if map_data.has("base"):
		var base_pos: Vector2 = map_data["base"]
		if _gameplay_point_hit_contains("Goal", base_pos, point):
			select_object({"type": "Goal", "id": "base_hq", "position": base_pos, "legacy_field": "base"})
			return true

	if map_data.has("lanes"):
		for key in map_data["lanes"]:
			var spawn_pos: Vector2 = map_data["lanes"][key]
			if _gameplay_point_hit_contains("Spawn", spawn_pos, point):
				select_object({"type": "Spawn", "id": str(key), "position": spawn_pos, "legacy_field": "lanes"})
				return true

	if map_data.has("slots"):
		for key in map_data["slots"]:
			var slot_data: Variant = map_data["slots"][key]
			var slot_pos := _slot_position(slot_data)
			if _gameplay_point_hit_contains("Tower Slot", slot_pos, point):
				select_object({"type": "Tower Slot", "id": str(key), "position": slot_pos, "legacy_field": "slots"})
				return true

	if map_data.has("robot_spots"):
		for key in map_data["robot_spots"]:
			var spot_pos: Vector2 = map_data["robot_spots"][key]
			if _gameplay_point_hit_contains("Robot Spot", spot_pos, point):
				select_object({"type": "Robot Spot", "id": str(key), "position": spot_pos, "legacy_field": "robot_spots"})
				return true
	return false

func _pick_catalog_tile_at(point: Vector2) -> bool:
	if not map_data.has("tiles") or not map_data["tiles"].has(active_layer):
		return false
	var layer_tiles: Dictionary = map_data["tiles"][active_layer]
	var cell := get_cell_coords(point)
	for key in layer_tiles.keys():
		var coordinates := str(key).split(",")
		if coordinates.size() < 2:
			continue
		var tile_cell := Vector2i(coordinates[0].to_int(), coordinates[1].to_int())
		var tile_info: Variant = layer_tiles[key]
		if not tile_info is Dictionary or not tile_info.has("asset_id"):
			continue
		if not _tile_placement_contains(tile_info, tile_cell, cell):
			continue
		var anchor := _catalog_tile_anchor(tile_info, tile_cell)
		var footprint := _catalog_tile_footprint(tile_info)
		_select_catalog_tile(str(tile_info.get("asset_id", "")), anchor, footprint)
		return true
	return false

func select_object(info: Dictionary) -> void:
	selected_object = info
	object_selected.emit(info)
	queue_redraw()

func _slot_position(slot_data: Variant) -> Vector2:
	if slot_data is Dictionary:
		var position: Variant = slot_data.get("position", Vector2.INF)
		if position is Vector2:
			return position
		if position is Array and position.size() >= 2:
			return Vector2(float(position[0]), float(position[1]))
	elif slot_data is Vector2:
		return slot_data
	elif slot_data is Array and slot_data.size() >= 2:
		return Vector2(float(slot_data[0]), float(slot_data[1]))
	return Vector2.INF

func _draw() -> void:
	draw_set_transform(camera_offset, 0.0, Vector2(camera_zoom, camera_zoom))

	var map_tiles: Vector2i = _map_tiles_size()
	var origin: Vector2 = _map_origin()
	var pixel_size: Vector2 = _map_pixel_size()

	# Canvas Background
	draw_rect(Rect2(origin - Vector2(20, 20), pixel_size + Vector2(40, 40)), Color("0b1519"))
	draw_rect(Rect2(origin, pixel_size), Color("12272e"))

	# Render Tiles from map_data["tiles"]
	if map_data.has("tiles"):
		var layers: Dictionary = map_data["tiles"]
		for layer_name in ["Ground", "RoadComposition", "Vegetation"]:
			if not layers.has(layer_name):
				continue
			var layer_tiles: Dictionary = layers[layer_name]
			for key in layer_tiles:
				var parts := str(key).split(",")
				if parts.size() < 2:
					continue
				var cx := parts[0].to_int()
				var cy := parts[1].to_int()
				var dest_pos := origin + Vector2(cx * 32, cy * 32)
				var tile_val: Variant = layer_tiles[key]
				if tile_val is Dictionary:
					var cell := Vector2i(cx, cy)
					var anchor := _catalog_tile_anchor(tile_val, cell)
					if anchor != cell:
						continue
					draw_catalog_tile(dest_pos, str(tile_val.get("asset_id", "")), _catalog_tile_footprint(tile_val))
					continue
				if not tile_val is Array or tile_val.size() < 3:
					continue
				var source_id := int(tile_val[0])
				var atlas_x := int(tile_val[1])
				var atlas_y := int(tile_val[2])
				draw_tile_cell(dest_pos, source_id, Vector2i(atlas_x, atlas_y), layer_name)

	for object_data in map_data.get("objects", []):
		if not object_data is Dictionary:
			continue
		var asset_id := str(object_data.get("asset_id", ""))
		var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
		var texture := get_catalog_texture(asset_id)
		if asset.is_empty() or texture == null:
			continue
		var footprint := catalog_asset_footprint(asset, object_data)
		var destination := Rect2(object_position(object_data), Vector2(footprint) * 32.0)
		draw_texture_rect_region(texture, destination, catalog_source_rect(asset))

	# Grid Lines (32x32)
	var grid_color := Color("7ed6ce", 0.25)
	for x in range(map_tiles.x + 1):
		var x_pos := origin.x + float(x * 32)
		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, origin.y + pixel_size.y), grid_color, 1.0)
	for y in range(map_tiles.y + 1):
		var y_pos := origin.y + float(y * 32)
		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + pixel_size.x, y_pos), grid_color, 1.0)

	# Grid Header & Mode Info
	draw_rect(Rect2(origin, pixel_size), Color("7ed6ce"), false, 2.0)
	var mode_str := "MODE: " + edit_mode + " (Layer: " + active_layer + ")"
	draw_string(ThemeDB.fallback_font, origin + Vector2(12, -8), mode_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d7fff7"))

	# Render Goal Base HQ
	if map_data.has("base"):
		var base_pos: Vector2 = map_data["base"]
		draw_rect(Rect2(base_pos - Vector2(36, 24), Vector2(72, 48)), Color("1c4852", 0.85))
		draw_rect(Rect2(base_pos - Vector2(36, 24), Vector2(72, 48)), Color("7ed6ce"), false, 2.0)
		draw_string(ThemeDB.fallback_font, base_pos + Vector2(-28, 6), "BASE HQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("7ed6ce"))

	# Render Spawn Points
	if map_data.has("lanes"):
		for key in map_data["lanes"]:
			var pos: Vector2 = map_data["lanes"][key]
			draw_circle(pos, 16.0, Color("ef7068", 0.7))
			draw_arc(pos, 18.0, 0, TAU, 16, Color("ef7068"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-24, 32), "SPAWN: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ef7068"))

	# Render Tower Slots
	if map_data.has("slots"):
		for key in map_data["slots"]:
			var pos := _slot_position(map_data["slots"][key])
			draw_circle(pos, 14.0, Color("f0a35a", 0.6))
			draw_arc(pos, 16.0, 0, TAU, 16, Color("f0a35a"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-16, 28), "SLOT: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("f0a35a"))

	# Render Robot Spots
	if map_data.has("robot_spots"):
		for key in map_data["robot_spots"]:
			var pos: Vector2 = map_data["robot_spots"][key]
			draw_circle(pos, 18.0, Color("7ed6ce", 0.4))
			draw_arc(pos, 20.0, 0, TAU, 16, Color("7ed6ce"), 2.0)
			draw_string(ThemeDB.fallback_font, pos + Vector2(-24, 34), "SPOT: " + str(key), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("7ed6ce"))

	_draw_gameplay_elements()

	# Render Catalog Placement Preview
	if edit_mode == "PAINT" and not selected_catalog_asset.is_empty() and pointer_is_inside_canvas(last_pointer_local):
		var preview_world := (last_pointer_local - camera_offset) / camera_zoom
		var preview_cell := get_cell_coords(preview_world)
		var preview_origin: Vector2 = _map_origin()
		var preview_position := preview_origin + Vector2(preview_cell) * 32.0
		var preview_footprint := catalog_asset_footprint(selected_catalog_asset)
		var preview_rect := Rect2(preview_position, Vector2(preview_footprint) * 32.0)
		var preview_texture := get_catalog_texture(str(selected_catalog_asset.get("asset_id", "")))
		if preview_texture != null:
			draw_texture_rect_region(preview_texture, preview_rect, catalog_source_rect(selected_catalog_asset), Color(1.0, 1.0, 1.0, 0.55))
		else:
			draw_rect(preview_rect, Color(0.4, 0.25, 0.32, 0.55), true)
		draw_rect(preview_rect, Color("7ed6ce"), false, 2.0 / camera_zoom)

	# Render Selected Object Highlight
	if not selected_object.is_empty() and selected_object.has("position"):
		var sel_pos: Vector2 = selected_object["position"]
		draw_arc(sel_pos, 28.0, 0, TAU, 24, Color("ffe066"), 3.0)
		draw_string(ThemeDB.fallback_font, sel_pos + Vector2(-30, -32), "[SELECTED]", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffe066"))
	var placement_rect := _selected_catalog_placement_rect()
	if placement_rect.size.x > 0.0 and placement_rect.size.y > 0.0:
		if is_resizing_placement:
			placement_rect.size = Vector2(resize_preview_footprint) * 32.0
		draw_rect(placement_rect, Color("ffe066"), false, 2.0 / camera_zoom)
		var handle_rect := _resize_handle_rect(placement_rect)
		draw_rect(handle_rect, Color("ffe066"), true)
		draw_rect(handle_rect, Color("20242b"), false, 1.0 / camera_zoom)
	if eraser_preview_visible:
		var preview_rect := _eraser_preview_rect()
		draw_rect(preview_rect, Color(0.96, 0.35, 0.3, 0.2), true)
		draw_rect(preview_rect, Color("ff6b61"), false, 2.0 / camera_zoom)
		var label_size := maxi(10, roundi(12.0 / camera_zoom))
		draw_string(ThemeDB.fallback_font, preview_rect.position + Vector2(5, label_size + 4), "%d × %d" % [eraser_size, eraser_size], HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, Color("fff3ed"))

func _draw_gameplay_elements() -> void:
	var type_colors := {
		"spawn_area": Color("ef7068"),
		"tower_placement_area": Color("f0a35a"),
		"goal_area": Color("7ed6ce"),
		"obstacle_area": Color("b7836f"),
		"movement_area": Color("7ea6ef"),
		"blocked_area": Color("a27eef"),
		"tower_placement_point": Color("f0a35a"),
		"robot_position_point": Color("7ed6ce")
	}
	var areas: Array = map_data.get("gameplay_areas", [])
	for index in range(areas.size()):
		if not areas[index] is Dictionary:
			continue
		var area: Dictionary = areas[index]
		var size_values: Variant = area.get("size", [32.0, 32.0])
		if not size_values is Array or size_values.size() < 2:
			continue
		var area_rect := Rect2(object_position(area), Vector2(float(size_values[0]), float(size_values[1])))
		var element_type := str(area.get("type", ""))
		var color: Color = type_colors.get(element_type, Color("d3d9df"))
		var enabled := bool(area.get("enabled", true))
		color.a = 0.72 if enabled else 0.28
		draw_rect(area_rect, Color(color, 0.13 if enabled else 0.05), true)
		draw_rect(area_rect, color, false, 2.0 / camera_zoom)
		draw_string(ThemeDB.fallback_font, area_rect.position + Vector2(5, 16), str(area.get("name", _gameplay_type_label(element_type))), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
		if str(selected_object.get("type", "")) == "Gameplay Area" and int(selected_object.get("element_index", -1)) == index:
			var selected_rect := area_rect
			if is_resizing_gameplay_area:
				selected_rect.size = Vector2(selected_object.get("size", area_rect.size))
			draw_rect(selected_rect, Color("ffe066"), false, 3.0 / camera_zoom)
			draw_rect(_resize_handle_rect(selected_rect), Color("ffe066"), true)
	if is_creating_gameplay_area:
		var start_cell := get_cell_coords(operation_start_world)
		var end_cell := get_cell_coords(gameplay_area_drag_end)
		var first_cell := Vector2i(mini(start_cell.x, end_cell.x), mini(start_cell.y, end_cell.y))
		var last_cell := Vector2i(maxi(start_cell.x, end_cell.x), maxi(start_cell.y, end_cell.y))
		var origin: Vector2 = _map_origin()
		var preview_rect := Rect2(origin + Vector2(first_cell) * 32.0, Vector2(last_cell - first_cell + Vector2i.ONE) * 32.0)
		draw_rect(preview_rect, Color("ffe066", 0.18), true)
		draw_rect(preview_rect, Color("ffe066"), false, 2.0 / camera_zoom)
	var points: Array = map_data.get("gameplay_points", [])
	for index in range(points.size()):
		if not points[index] is Dictionary:
			continue
		var gameplay_point: Dictionary = points[index]
		var pos := object_position(gameplay_point)
		var element_type := str(gameplay_point.get("type", ""))
		var color: Color = type_colors.get(element_type, Color("d3d9df"))
		color.a = 0.9 if bool(gameplay_point.get("enabled", true)) else 0.35
		draw_circle(pos, 8.0 / camera_zoom, color)
		draw_arc(pos, 10.0 / camera_zoom, 0, TAU, 16, color, 2.0 / camera_zoom)
		draw_string(ThemeDB.fallback_font, pos + Vector2(10, 4), str(gameplay_point.get("name", _gameplay_type_label(element_type))), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
		if str(selected_object.get("type", "")) == "Gameplay Point" and int(selected_object.get("element_index", -1)) == index:
			draw_arc(pos, 14.0 / camera_zoom, 0, TAU, 20, Color("ffe066"), 3.0 / camera_zoom)

func draw_tile_cell(dest_pos: Vector2, source_id: int, atlas_coords: Vector2i, _layer_name: String) -> void:
	var rect := Rect2(dest_pos, Vector2(32, 32))
	if TILESET and TILESET.has_source(source_id):
		var source := TILESET.get_source(source_id) as TileSetAtlasSource
		if source:
			var texture := source.texture
			if texture:
				var src_rect := Rect2(atlas_coords.x * 32, atlas_coords.y * 32, 32, 32)
				draw_texture_rect_region(texture, rect, src_rect)
				return

	# Fallback colored rect if texture region is unavailable
	var col := Color("3a7d44") if source_id == 0 else (Color("5a6275") if source_id == 3 else Color("2b9e66"))
	draw_rect(rect, col)

func draw_catalog_tile(dest_pos: Vector2, asset_id: String, footprint: Vector2i = Vector2i.ONE) -> void:
	var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
	var texture := get_catalog_texture(asset_id)
	if asset.is_empty() or texture == null:
		draw_rect(Rect2(dest_pos, Vector2(footprint.x * 32, footprint.y * 32)), Color("693d52"))
		return
	draw_texture_rect_region(texture, Rect2(dest_pos, Vector2(footprint.x * 32, footprint.y * 32)), catalog_source_rect(asset))

func catalog_source_rect(asset: Dictionary) -> Rect2:
	var values: Variant = asset.get("source_rect_px", [0, 0, 32, 32])
	if not values is Array or values.size() < 4:
		return Rect2(0, 0, 32, 32)
	var rect_values: Array = values
	return Rect2(float(rect_values[0]), float(rect_values[1]), float(rect_values[2]), float(rect_values[3]))

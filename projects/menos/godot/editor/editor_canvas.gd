class_name EditorCanvas
extends Node2D

signal object_selected(info: Dictionary)
signal map_data_changed()
signal placement_resize_failed(message: String)

const TILESET: TileSet = preload("res://assets/menos/maps/northbridge_tileset.tres")
const IMAGE_TEXTURE_LOADER := preload("res://editor/image_texture_loader.gd")
const MAX_UNDO_HISTORY := 100

var map_data: Dictionary = {}
var selected_object: Dictionary = {}

var edit_mode := "SELECT" # SELECT, PAINT, ERASE
var active_layer := "Ground" # Ground, Vegetation, RoadComposition
var selected_tile_source_id := 0
var selected_tile_atlas_coords := Vector2i.ZERO
var selected_catalog_asset: Dictionary = {}
var catalog_assets_by_id: Dictionary = {}
var catalog_texture_cache: Dictionary = {}
var eraser_size := 1

var camera_zoom := 1.0
var camera_offset := Vector2.ZERO
var is_panning := false
var is_painting_drag := false
var is_resizing_placement := false
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
	edit_stroke_snapshot.clear()
	edit_stroke_active = false
	edit_stroke_changed = false
	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	queue_redraw()

func set_edit_mode(mode: String) -> void:
	edit_mode = mode
	select_object({})
	queue_redraw()

func set_active_layer(layer_name: String) -> void:
	active_layer = layer_name
	queue_redraw()

func set_eraser_size(size_in_tiles: int) -> void:
	eraser_size = clampi(size_in_tiles, 1, 10)

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
	for entry in entries:
		var asset_id := str(entry.get("asset_id", ""))
		if not asset_id.is_empty():
			catalog_assets_by_id[asset_id] = entry.duplicate(true)
	queue_redraw()

func set_catalog_asset(entry: Dictionary) -> void:
	selected_catalog_asset = entry.duplicate(true)
	edit_mode = "PAINT"
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

	if event is InputEventMouseButton:
		var mb_event := event as InputEventMouseButton
		var local_position := viewport_to_canvas_position(mb_event.position)
		var inside_canvas := pointer_is_inside_canvas(local_position)

		if mb_event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT]:
			if mb_event.pressed and inside_canvas:
				is_panning = true
				pan_start_pos = local_position
				get_viewport().set_input_as_handled()
			elif not mb_event.pressed and is_panning:
				is_panning = false
				get_viewport().set_input_as_handled()
		elif mb_event.button_index == MOUSE_BUTTON_LEFT:
			if not mb_event.pressed:
				if is_resizing_placement:
					var world_pos := (local_position - camera_offset) / camera_zoom
					var footprint := _resize_footprint_for_drag(world_pos)
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
			if _selected_resize_handle_contains(world_pos):
				is_resizing_placement = true
				resize_start_world = world_pos
				var selected_footprint: Array = selected_object.get("footprint", [1, 1])
				resize_start_footprint = Vector2i(int(selected_footprint[0]), int(selected_footprint[1]))
				resize_preview_footprint = resize_start_footprint
				get_viewport().set_input_as_handled()
				return
			is_painting_drag = true
			if edit_mode in ["PAINT", "ERASE"]:
				_begin_edit_stroke()
			handle_canvas_click(world_pos)
			get_viewport().set_input_as_handled()
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
		if is_resizing_placement:
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

func _selected_catalog_placement_rect() -> Rect2:
	var selection_type := str(selected_object.get("type", ""))
	if selection_type not in ["Catalog Tile", "Catalog Object"]:
		return Rect2()
	var footprint_values: Variant = selected_object.get("footprint", [1, 1])
	if not footprint_values is Array or footprint_values.size() < 2:
		return Rect2()
	var position := object_position(selected_object)
	var footprint := Vector2i(maxi(1, int(footprint_values[0])), maxi(1, int(footprint_values[1])))
	return Rect2(position, Vector2(footprint) * 32.0)

func _resize_handle_rect(placement_rect: Rect2) -> Rect2:
	var handle_size := 12.0 / camera_zoom
	return Rect2(placement_rect.end - Vector2.ONE * handle_size * 0.5, Vector2.ONE * handle_size)

func _selected_resize_handle_contains(world_pos: Vector2) -> bool:
	var placement_rect := _selected_catalog_placement_rect()
	return placement_rect.size.x > 0.0 and placement_rect.size.y > 0.0 and _resize_handle_rect(placement_rect).has_point(world_pos)

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
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var cell_x := int(floor((world_pos.x - origin.x) / 32.0))
	var cell_y := int(floor((world_pos.y - origin.y) / 32.0))
	return Vector2i(cell_x, cell_y)

func paint_tile_at(world_pos: Vector2) -> void:
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	if not selected_catalog_asset.is_empty():
		if str(selected_catalog_asset.get("kind", "tile")) == "object":
			place_catalog_object(cell)
		else:
			paint_catalog_tile(cell)
		return

	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	if not map_data["tiles"].has(active_layer):
		map_data["tiles"][active_layer] = {}

	var key := "%d,%d" % [cell.x, cell.y]
	var tile_info := [selected_tile_source_id, selected_tile_atlas_coords.x, selected_tile_atlas_coords.y]

	if map_data["tiles"][active_layer].get(key) != tile_info:
		map_data["tiles"][active_layer][key] = tile_info
		_mark_map_data_changed()

func paint_catalog_tile(cell: Vector2i) -> void:
	var footprint := catalog_asset_footprint(selected_catalog_asset)
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	if cell.x + footprint.x > map_tiles.x or cell.y + footprint.y > map_tiles.y:
		return
	if not map_data.has("tiles"):
		map_data["tiles"] = {}
	if not map_data["tiles"].has(active_layer):
		map_data["tiles"][active_layer] = {}
	var layer_tiles: Dictionary = map_data["tiles"][active_layer]
	var asset_id := str(selected_catalog_asset.get("asset_id", ""))
	if footprint == Vector2i.ONE and layer_tiles.get("%d,%d" % [cell.x, cell.y]) == {"asset_id": asset_id}:
		_select_catalog_tile(asset_id, cell, footprint)
		return
	var changed := false
	for offset_y in range(footprint.y):
		for offset_x in range(footprint.x):
			changed = _remove_catalog_tile_at(layer_tiles, cell + Vector2i(offset_x, offset_y)) or changed
	for offset_y in range(footprint.y):
		for offset_x in range(footprint.x):
			var occupied_cell := cell + Vector2i(offset_x, offset_y)
			var tile_info := {"asset_id": asset_id}
			if footprint != Vector2i.ONE:
				tile_info["anchor"] = [cell.x, cell.y]
				tile_info["footprint_tiles"] = [footprint.x, footprint.y]
			layer_tiles["%d,%d" % [occupied_cell.x, occupied_cell.y]] = tile_info
			changed = true
	if changed:
		_mark_map_data_changed()
		_select_catalog_tile(asset_id, cell, footprint)

func _select_catalog_tile(asset_id: String, anchor: Vector2i, footprint: Vector2i) -> void:
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	select_object({
		"type": "Catalog Tile",
		"id": asset_id,
		"position": origin + Vector2(anchor) * 32.0,
		"layer": active_layer,
		"cell": anchor,
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
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	if cell.x + width > map_tiles.x or cell.y + height > map_tiles.y:
		return
	if not map_data.has("objects"):
		map_data["objects"] = []
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var position := origin + Vector2(cell.x * 32, cell.y * 32)
	map_data["objects"].append({
		"asset_id": str(selected_catalog_asset.get("asset_id", "")),
		"position": [position.x, position.y],
		"footprint_tiles": [width, height]
	})
	_mark_map_data_changed()
	select_object({
		"type": "Catalog Object",
		"id": str(selected_catalog_asset.get("asset_id", "")),
		"position": position,
		"object_index": map_data["objects"].size() - 1,
		"footprint": [width, height]
	})

func resize_selected_catalog_placement(width_tiles: int, height_tiles: int) -> bool:
	var footprint := Vector2i(maxi(1, width_tiles), maxi(1, height_tiles))
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var selection_type := str(selected_object.get("type", ""))
	var asset_id := str(selected_object.get("id", ""))
	if asset_id.is_empty():
		return false
	if selection_type == "Catalog Object":
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

func erase_tile_at(world_pos: Vector2) -> void:
	if erase_catalog_object_at(world_pos):
		return
	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var cell := get_cell_coords(world_pos)

	if cell.x < 0 or cell.x >= map_tiles.x or cell.y < 0 or cell.y >= map_tiles.y:
		return

	if not map_data.has("tiles") or not map_data["tiles"].has(active_layer):
		return

	var half_size := int(floor(float(eraser_size) / 2.0))
	var start_cell := cell - Vector2i(half_size, half_size)
	var layer_tiles: Dictionary = map_data["tiles"][active_layer]
	var changed := false
	for offset_y in range(eraser_size):
		for offset_x in range(eraser_size):
			var target_cell := start_cell + Vector2i(offset_x, offset_y)
			if target_cell.x < 0 or target_cell.x >= map_tiles.x or target_cell.y < 0 or target_cell.y >= map_tiles.y:
				continue
			changed = _remove_catalog_tile_at(layer_tiles, target_cell) or changed
	if changed:
		_mark_map_data_changed()

func erase_catalog_object_at(world_pos: Vector2) -> bool:
	var objects: Array = map_data.get("objects", [])
	for index in range(objects.size() - 1, -1, -1):
		var object_data: Dictionary = objects[index]
		var position := object_position(object_data)
		var asset_id := str(object_data.get("asset_id", ""))
		var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
		var footprint := catalog_asset_footprint(asset, object_data)
		var object_rect := Rect2(position, Vector2(footprint) * 32.0)
		if object_rect.has_point(world_pos):
			objects.remove_at(index)
			map_data["objects"] = objects
			_mark_map_data_changed()
			return true
	return false

func object_position(object_data: Dictionary) -> Vector2:
	var raw_position: Variant = object_data.get("position", [0.0, 0.0])
	if raw_position is Vector2:
		return raw_position
	if raw_position is Array and raw_position.size() >= 2:
		return Vector2(float(raw_position[0]), float(raw_position[1]))
	return Vector2.ZERO

func pick_object_at(point: Vector2) -> void:
	var objects: Array = map_data.get("objects", [])
	for object_index in range(objects.size() - 1, -1, -1):
		var object_data: Dictionary = objects[object_index]
		var asset_id := str(object_data.get("asset_id", ""))
		var asset: Dictionary = catalog_assets_by_id.get(asset_id, {})
		var footprint := catalog_asset_footprint(asset, object_data)
		var object_rect := Rect2(object_position(object_data), Vector2(footprint) * 32.0)
		if object_rect.has_point(point):
			select_object({"type": "Catalog Object", "id": asset_id, "position": object_position(object_data), "object_index": object_index, "footprint": [footprint.x, footprint.y]})
			return
	if _pick_catalog_tile_at(point):
		return

	# Check Goal
	if map_data.has("base"):
		var base_pos: Vector2 = map_data["base"]
		if point.distance_to(base_pos) < 40.0:
			select_object({"type": "Goal", "id": "base_hq", "position": base_pos})
			return

	# Check Spawns
	if map_data.has("lanes"):
		for key in map_data["lanes"]:
			var spawn_pos: Vector2 = map_data["lanes"][key]
			if point.distance_to(spawn_pos) < 30.0:
				select_object({"type": "Spawn", "id": str(key), "position": spawn_pos})
				return

	# Check Tower Slots
	if map_data.has("slots"):
		for key in map_data["slots"]:
			var slot_pos: Vector2 = map_data["slots"][key]
			if point.distance_to(slot_pos) < 30.0:
				select_object({"type": "Tower Slot", "id": str(key), "position": slot_pos})
				return

	# Check Robot Spots
	if map_data.has("robot_spots"):
		for key in map_data["robot_spots"]:
			var spot_pos: Vector2 = map_data["robot_spots"][key]
			if point.distance_to(spot_pos) < 35.0:
				select_object({"type": "Robot Spot", "id": str(key), "position": spot_pos})
				return

	select_object({})

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

func _draw() -> void:
	draw_set_transform(camera_offset, 0.0, Vector2(camera_zoom, camera_zoom))

	var map_tiles: Vector2i = map_data.get("map_tiles", Vector2i(36, 24))
	var origin: Vector2 = map_data.get("map_origin", Vector2(0, 58))
	var pixel_size: Vector2 = map_data.get("map_pixel_size", Vector2(1152, 768))

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
			var pos: Vector2 = map_data["slots"][key]
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
	var values: Array = asset.get("source_rect_px", [0, 0, 32, 32])
	if values.size() < 4:
		return Rect2(0, 0, 32, 32)
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))

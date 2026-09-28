extends Control
const REGION_VIEW_SCRIPT := preload("res://editor/asset_region_view.gd")
const LOADER := preload("res://editor/image_texture_loader.gd")
const IMAGE_STATE := preload("res://editor/image_editor_state.gd")
const EDITED_DIR := "res://content/editor/edited_assets"

var entries: Array[Dictionary] = []
var list: ItemList
var source_list: ItemList
var view: AssetRegionView
var status: Label
var current_index := -1
var current_path := ""
var current_image: Image
var source_index := -1
var source_path := ""
var source_image: Image
var editing := false

func _ready() -> void:
	_build_ui()
	_scan_connected_images()
	if not IMAGE_STATE.selected_path.is_empty():
		_select_path(IMAGE_STATE.selected_path)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title := Label.new()
	title.text = "이미지 에디터"
	title.add_theme_font_size_override("font_size", 22)
	root.add_child(title)
	var intro := Label.new()
	intro.text = "Connected images. Edit a copy, then reconnect the selected reference."
	root.add_child(intro)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 300
	body.add_child(left)
	var list_title := Label.new()
	list_title.text = "연결된 이미지"
	left.add_child(list_title)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.item_selected.connect(_select_entry)
	left.add_child(list)
	var source_panel := VBoxContainer.new()
	source_panel.custom_minimum_size.x = 280
	body.add_child(source_panel)
	var source_title := Label.new()
	source_title.text = "참조 이미지 카탈로그"
	source_panel.add_child(source_title)
	source_list = ItemList.new()
	source_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	source_list.item_selected.connect(_select_source_entry)
	source_panel.add_child(source_list)
	var source_help := Label.new()
	source_help.text = "다른 이미지의 전체 또는 선택 영역을 현재 이미지로 교체합니다."
	source_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source_panel.add_child(source_help)
	var source_full := Button.new()
	source_full.text = "전체 이미지로 교체"
	source_full.pressed.connect(_replace_from_source_full)
	source_panel.add_child(source_full)
	var source_region := Button.new()
	source_region.text = "선택 영역으로 교체"
	source_region.pressed.connect(_replace_from_source_region)
	source_panel.add_child(source_region)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	view = REGION_VIEW_SCRIPT.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(view)
	var tools := HBoxContainer.new()
	right.add_child(tools)
	_add_button(tools, "알파 삭제", _start_erase)
	_add_button(tools, "자르기", _crop_selection)
	_add_button(tools, "좌우 반전", _flip_h)
	_add_button(tools, "상하 반전", _flip_v)
	_add_button(tools, "시계 방향 회전", _rotate_cw)
	_add_button(tools, "반시계 방향 회전", _rotate_ccw)
	_add_button(tools, "투명 영역 제거", _trim_alpha)
	_add_button(tools, "저장 + 연결 변경", _save_reconnect)
	var resize_row := HBoxContainer.new()
	right.add_child(resize_row)
	var resize_label := Label.new()
	resize_label.text = "크기 변경"
	resize_row.add_child(resize_label)
	var width_spin := SpinBox.new()
	width_spin.name = "WidthSpin"
	width_spin.min_value = 1
	width_spin.max_value = 4096
	width_spin.step = 1
	resize_row.add_child(width_spin)
	var height_spin := SpinBox.new()
	height_spin.name = "HeightSpin"
	height_spin.min_value = 1
	height_spin.max_value = 4096
	height_spin.step = 1
	resize_row.add_child(height_spin)
	var resize_btn := Button.new()
	resize_btn.text = "크기 적용"
	resize_btn.pressed.connect(func(): _resize_image(int(width_spin.value), int(height_spin.value)))
	resize_row.add_child(resize_btn)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status)

func _add_button(parent: HBoxContainer, text_value: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text_value
	b.pressed.connect(callback)
	parent.add_child(b)

func _scan_connected_images() -> void:
	entries.clear()
	var seen := {}
	_scan_json_images("res://content/enemies/enemies.json", "ENEMY", "sprite_anim", seen)
	_scan_json_images("res://content/towers/towers.json", "TOWER", "sprite_anim", seen)
	_scan_catalog(seen)
	_scan_main_preloads(seen)
	list.clear()
	source_list.clear()
	for entry in entries:
		var icon: Texture2D = load(str(entry.path)) as Texture2D
		var label_text := "%s | %s" % [entry.label, entry.path]
		list.add_item(label_text, icon)
		source_list.add_item(label_text, icon)
	status.text = "%d connected images found." % entries.size()

func _scan_json_images(path: String, kind: String, field: String, seen: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var image_path := str(data[key].get(field, ""))
		if image_path.is_empty() or seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "%s / %s" % [kind, str(data[key].get("name", key))], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field})

func _scan_catalog(seen: Dictionary) -> void:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if not asset is Dictionary: continue
		var image_path := str(asset.get("source_path", ""))
		if image_path.is_empty() or seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "CATALOG / %s" % str(asset.get("display_name", asset.get("asset_id", "Asset"))), "path": image_path, "owner": path, "owner_kind": "catalog", "owner_key": str(asset.get("asset_id", "")), "field": "source_path"})
func _scan_main_preloads(seen: Dictionary) -> void:
	var path := "res://main.gd"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var source_text := file.get_as_text()
	file.close()
	var regex := RegEx.new()
	regex.compile('preload\\("([^"]+\\.(?:png|jpg|jpeg|webp))"\\)')
	var matches: Array = regex.search_all(source_text)
	for match_data in matches:
		var image_path := str(match_data.get_string(1))
		if seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "RUNTIME / %s" % image_path.get_file(), "path": image_path, "owner": path, "owner_kind": "main", "owner_key": image_path, "field": "preload"})

func _select_path(path: String) -> void:
	for index in range(entries.size()):
		if str(entries[index].path) == path:
			list.select(index)
			_select_entry(index)
			return

func _select_entry(index: int) -> void:
	if editing: return
	current_index = index
	current_path = str(entries[index].path)
	IMAGE_STATE.open_image(current_path)
	current_image = LOADER.load_image(current_path)
	if current_image == null:
		status.text = "Could not load: %s" % current_path
		return
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	status.text = "대상: %s — %d × %d px" % [current_path, current_image.get_width(), current_image.get_height()]

func _select_source_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= entries.size(): return
	source_index = index
	source_path = str(entries[index].path)
	if source_path == current_path:
		status.text = "대상과 다른 이미지를 참조 이미지로 선택하세요."
		return
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "참조 이미지를 불러올 수 없습니다: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "참조: %s — 전체 또는 드래그 선택 영역을 사용하세요." % source_path

func _replace_from_source_full() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "먼저 다른 참조 이미지를 선택하세요."
		return
	current_image = source_image.duplicate()
	_refresh_view()
	status.text = "참조 이미지 전체를 대상으로 교체했습니다. 저장 + 연결 변경을 눌러 적용하세요."

func _replace_from_source_region() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "먼저 다른 참조 이미지를 선택하세요."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "참조 이미지에서 교체할 영역을 드래그로 선택하세요."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = source_image.get_region(rect)
	_refresh_view()
	status.text = "참조 영역 %d × %d px로 대상을 교체했습니다. 저장 + 연결 변경을 눌러 적용하세요." % [rect.size.x, rect.size.y]

func _resize_image(width_px: int, height_px: int) -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.resize(maxi(1, width_px), maxi(1, height_px), Image.INTERPOLATE_LANCZOS)
	_refresh_view()

func _require_image() -> bool:
	if current_image == null or current_image.is_empty():
		status.text = "Select a connected image first."
		return false
	return true

func _refresh_view() -> void:
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	status.text = "%s — %d × %d px" % [current_path, current_image.get_width(), current_image.get_height()]
func _start_erase() -> void:
	if not _require_image(): return
	view.begin_image_edit(current_image, 12)
	editing = true
	status.text = "Erase mode active. Drag over pixels, then save."

func _finish_erase() -> void:
	if not editing: return
	var edited := view.get_edited_image()
	if edited == null: return
	current_image = edited
	view.cancel_image_edit()
	editing = false
	_refresh_view()

func _crop_selection() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Drag-select a region first."
		return
	rect = rect.intersection(Rect2i(0, 0, current_image.get_width(), current_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = current_image.get_region(rect)
	_refresh_view()

func _flip_h() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.flip_x()
	_refresh_view()

func _flip_v() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.flip_y()
	_refresh_view()

func _rotate_cw() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.rotate_90(CLOCKWISE)
	_refresh_view()
func _rotate_ccw() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	current_image.rotate_90(COUNTERCLOCKWISE)
	_refresh_view()

func _trim_alpha() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var rect := _visible_bounds(current_image)
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "Image has no visible pixels."
		return
	current_image = current_image.get_region(rect)
	_refresh_view()

func _visible_bounds(image: Image) -> Rect2i:
	var w := image.get_width()
	var h := image.get_height()
	var min_x := w
	var min_y := h
	var max_x := -1
	var max_y := -1
	for y in range(h):
		for x in range(w):
			if image.get_pixel(x, y).a > 0.0:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < 0: return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _save_reconnect() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	var dir := ProjectSettings.globalize_path(EDITED_DIR)
	var err := DirAccess.make_dir_recursive_absolute(dir)
	if err != OK:
		status.text = "Could not create edited asset directory."
		return
	var name := current_path.get_file().get_basename().to_snake_case()
	var output := "%s/%s_edit_%d.png" % [EDITED_DIR, name, Time.get_ticks_usec()]
	err = current_image.save_png(ProjectSettings.globalize_path(output))
	if err != OK:
		status.text = "PNG save failed: %d" % err
		return
	if not _reconnect_entry(output):
		status.text = "Saved edit, but reconnect failed: %s" % output
		return
	current_path = output
	_refresh_view()
	status.text = "Saved edited image and reconnected the selected reference."
func _reconnect_entry(new_path: String) -> bool:
	if current_index < 0 or current_index >= entries.size(): return false
	var entry: Dictionary = entries[current_index]
	var owner_kind := str(entry.owner_kind)
	if owner_kind == "json":
		return _replace_json_value(str(entry.owner), str(entry.owner_key), str(entry.field), new_path)
	if owner_kind == "catalog":
		return _replace_catalog_value(str(entry.owner_key), new_path)
	if owner_kind == "main":
		return _replace_main_path(str(entry.owner_key), new_path)
	return false

func _replace_json_value(path: String, key: String, field: String, new_path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(key): return false
	data[key][field] = new_path
	return _write_json(path, data)

func _replace_catalog_value(asset_id: String, new_path: String) -> bool:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return false
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			asset["source_path"] = new_path
			asset["source_rect_px"] = [0, 0, current_image.get_width(), current_image.get_height()]
			return _write_json(path, data)
	return false

func _replace_main_path(old_path: String, new_path: String) -> bool:
	var file := FileAccess.open("res://main.gd", FileAccess.READ)
	if file == null: return false
	var text := file.get_as_text()
	file.close()
	if not text.contains(old_path): return false
	text = text.replace(old_path, new_path)
	var out := FileAccess.open(ProjectSettings.globalize_path("res://main.gd"), FileAccess.WRITE)
	if out == null: return false
	out.store_string(text)
	out.close()
	return true

func _write_json(path: String, data: Variant) -> bool:
	var out := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	if out == null: return false
	out.store_string(JSON.stringify(data, "\t"))
	out.close()
	return true

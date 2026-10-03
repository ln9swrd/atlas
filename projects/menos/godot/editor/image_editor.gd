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
var catalog_target_index := -1
var current_path := ""
var current_image: Image
var source_index := -1
var source_path := ""
var source_image: Image
var source_dialog: FileDialog
var target_dialog: FileDialog
var source_thumbnail_cache: Dictionary = {}
var target_thumbnail_cache: Dictionary = {}
var editing := false
var usage_label: Label

signal request_content_editor
signal request_previous_editor

func _request_content_editor() -> void:
	request_content_editor.emit()

func _request_previous_editor() -> void:
	request_previous_editor.emit()

func _ready() -> void:
	_build_ui()
	_scan_connected_images()
	if not IMAGE_STATE.selected_path.is_empty():
		_select_path(IMAGE_STATE.selected_path)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title_row := HBoxContainer.new()
	root.add_child(title_row)
	var title := Label.new()
	title.text = "이미지 에디터"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title_row.add_child(title)
	var previous_button := Button.new()
	previous_button.text = "이전 화면"
	previous_button.pressed.connect(_request_previous_editor)
	title_row.add_child(previous_button)
	var content_button := Button.new()
	content_button.text = "콘텐츠 에디터"
	content_button.pressed.connect(_request_content_editor)
	title_row.add_child(content_button)
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
	var clear_selection := Button.new()
	clear_selection.text = "선택 이미지 해제"
	clear_selection.pressed.connect(_clear_image_selection)
	left.add_child(clear_selection)
	var open_target_button := Button.new()
	open_target_button.text = "다른 이미지 열기 (편집 대상)"
	open_target_button.pressed.connect(_open_target_dialog)
	left.add_child(open_target_button)
	var reconnect_target_button := Button.new()
	reconnect_target_button.text = "현재 이미지로 선택 카탈로그 교체"
	reconnect_target_button.pressed.connect(_reconnect_current_to_selected_entry)
	left.add_child(reconnect_target_button)
	var new_catalog_button := Button.new()
	new_catalog_button.text = "현재 이미지를 새 Asset Catalog로 등록"
	new_catalog_button.pressed.connect(_add_current_image_to_asset_catalog)
	left.add_child(new_catalog_button)
	var audit_button := Button.new()
	audit_button.text = "이미지 참조 점검"
	audit_button.pressed.connect(_audit_image_references)
	left.add_child(audit_button)
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
	var source_open := Button.new()
	source_open.text = "다른 이미지 열기"
	source_open.pressed.connect(_open_source_dialog)
	source_panel.add_child(source_open)
	var source_region := Button.new()
	source_region.text = "선택 영역으로 교체"
	source_region.pressed.connect(_replace_from_source_region)
	source_panel.add_child(source_region)
	var normalize := Button.new()
	normalize.name = "NormalizeUnitButton"
	normalize.text = "유닛 크기로 맞춰 교체"
	normalize.pressed.connect(_replace_source_region_as_unit)
	source_panel.add_child(normalize)
	var source_reference := Button.new()
	source_reference.text = "선택 영역을 참조 이미지로 설정"
	source_reference.pressed.connect(_apply_source_region_reference)
	source_panel.add_child(source_reference)
	source_dialog = FileDialog.new()
	source_dialog.title = "참조 이미지 열기"
	source_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	source_dialog.access = FileDialog.ACCESS_RESOURCES
	source_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; 이미지"])
	source_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	source_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_source_thumbnail"))
	source_dialog.current_dir = "res://"
	source_dialog.file_selected.connect(_on_source_file_selected)
	add_child(source_dialog)
	target_dialog = FileDialog.new()
	target_dialog.title = "편집 대상 이미지 열기"
	target_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	target_dialog.access = FileDialog.ACCESS_RESOURCES
	target_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; 이미지"])
	target_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	target_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_target_thumbnail"))
	target_dialog.current_dir = "res://"
	target_dialog.file_selected.connect(_on_target_file_selected)
	add_child(target_dialog)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	usage_label = Label.new()
	usage_label.text = "용도: 선택된 이미지 없음"
	usage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage_label.add_theme_font_size_override("font_size", 16)
	right.add_child(usage_label)
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
	_scan_json_images("res://content/towers/towers.json", "타워", "sprite_anim", "방어 시설 이미지", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "유닛", "visuals.sprite", "플레이어 유닛 이미지", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "유닛", "visuals.default_image", "유닛 Profile Image", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "유닛", "projectile_anim", "유닛 탄환 이미지", seen)
	_scan_json_images("res://content/enemies/enemies.json", "적 유닛", "sprite_anim", "적 유닛 이미지", seen)
	_scan_json_images("res://content/enemies/enemies.json", "적 유닛", "projectile_anim", "적 유닛 탄환 이미지", seen)
	_scan_allied_animations(seen)
	_scan_robot_images(seen)
	_scan_catalog(seen)
	_scan_main_preloads(seen)
	list.clear()
	source_list.clear()
	for entry in entries:
		var icon: Texture2D = load(str(entry.path)) as Texture2D
		var label_text := "[%s] %s | %s" % [str(entry.get("usage", "용도 미지정")), entry.label, entry.path]
		list.add_item(label_text, icon)
		source_list.add_item(label_text, icon)
	status.text = "%d connected images found." % entries.size()

func _audit_image_references() -> void:
	var missing: Array[String] = []
	var invalid: Array[String] = []
	for entry in entries:
		var image_path := str(entry.get("path", ""))
		if image_path.is_empty():
			continue
		if not ResourceLoader.exists(image_path):
			missing.append("%s | %s" % [str(entry.get("label", "이미지")), image_path])
			continue
		var texture := load(image_path) as Texture2D
		if texture == null:
			invalid.append("%s | %s" % [str(entry.get("label", "이미지")), image_path])
	var report := "이미지 참조 점검 결과\n\n전체 참조: %d\n누락: %d\n로드 실패: %d" % [entries.size(), missing.size(), invalid.size()]
	if not missing.is_empty():
		report += "\n\n[누락된 이미지]\n" + "\n".join(missing)
	if not invalid.is_empty():
		report += "\n\n[로드 실패 이미지]\n" + "\n".join(invalid)
	if missing.is_empty() and invalid.is_empty():
		report += "\n\n모든 연결 이미지 참조가 정상입니다."
	var dialog := AcceptDialog.new()
	dialog.title = "이미지 참조 점검"
	dialog.dialog_text = report
	dialog.ok_button_text = "닫기"
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(760, 520))

func _scan_json_images(path: String, kind: String, field: String, usage: String, seen: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var value: Variant = data[key]
		for part in field.split("."):
			if value is Dictionary:
				value = value.get(part, "")
			else:
				value = ""
		var image_path := str(value)
		if image_path.is_empty() or seen.has(image_path): continue
		seen[image_path] = true
		entries.append({"label": "%s / %s" % [kind, str(data[key].get("name", key))], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage})

func _scan_allied_animations(seen: Dictionary) -> void:
	var path := "res://content/allied_units/allied_units.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var visuals: Dictionary = data[key].get("visuals", {})
		if not visuals is Dictionary: continue
		var animations: Dictionary = visuals.get("animations", {})
		if not animations is Dictionary: continue
		for animation_name in animations:
			var image_path := str(animations[animation_name])
			if image_path.is_empty() or seen.has(image_path): continue
			seen[image_path] = true
			entries.append({"label": "아군 유닛 / %s / %s" % [str(data[key].get("name", key)), str(animation_name)], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "visuals.animations." + str(animation_name), "usage": "아군 유닛 %s 애니메이션" % str(animation_name)})

func _scan_robot_images(seen: Dictionary) -> void:
	var path := "res://content/robots/robots.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return
	for key in data:
		if not data[key] is Dictionary: continue
		var robot_name := str(data[key].get("name", key))
		for field in ["sprite_idle", "sprite_attack", "sprite_move", "sprite_skill", "default_image", "projectile_anim"]:
			var image_path := str(data[key].get(field, ""))
			if image_path.is_empty() or seen.has(image_path): continue
			seen[image_path] = true
			var usage := "로봇 대기 이미지"
			match field:
				"sprite_attack": usage = "로봇 공격 이미지"
				"default_image": usage = "로봇 Profile Image"
				"sprite_move": usage = "로봇 이동 이미지"
				"sprite_skill": usage = "로봇 스킬 이미지"
				"projectile_anim": usage = "로봇 투사체 이미지"
			entries.append({"label": "로봇 / %s" % robot_name, "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage})
		var animations: Dictionary = data[key].get("animations", {})
		if animations is Dictionary:
			for animation_name in animations:
				var animation_path := str(animations[animation_name])
				if animation_path.is_empty() or seen.has(animation_path): continue
				seen[animation_path] = true
				entries.append({"label": "로봇 / %s / %s" % [robot_name, str(animation_name)], "path": animation_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "animations." + str(animation_name), "usage": "로봇 %s 애니메이션" % str(animation_name)})

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
		entries.append({"label": "카탈로그 / %s" % str(asset.get("display_name", asset.get("asset_id", "Asset"))), "path": image_path, "owner": path, "owner_kind": "catalog", "owner_key": str(asset.get("asset_id", "")), "field": "source_path", "usage": "%s / %s" % [str(asset.get("group", "카탈로그")), str(asset.get("kind", "asset"))]})
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
		entries.append({"label": "런타임 / %s" % image_path.get_file(), "path": image_path, "owner": path, "owner_kind": "main", "owner_key": image_path, "field": "preload", "usage": "게임 런타임 이미지"})

func _select_path(path: String) -> void:
	for index in range(entries.size()):
		if str(entries[index].path) == path:
			list.select(index)
			_select_entry(index)
			return

func _clear_image_selection() -> void:
	if editing:
		_finish_erase()
	current_index = -1
	current_path = ""
	current_image = null
	source_index = -1
	source_path = ""
	source_image = null
	list.deselect_all()
	source_list.deselect_all()
	IMAGE_STATE.selected_path = ""
	usage_label.text = "용도: 선택된 이미지 없음"
	view.set_source_texture(null)
	status.text = "이미지 선택을 해제했습니다."

func _select_entry(index: int) -> void:
	if editing: return
	catalog_target_index = index
	current_index = index
	current_path = str(entries[index].path)
	IMAGE_STATE.open_image(current_path)
	current_image = LOADER.load_image(current_path)
	if current_image == null:
		usage_label.text = "용도: %s" % str(entries[index].get("usage", "용도 미지정"))
		status.text = "Could not load: %s" % current_path
		return
	usage_label.text = "용도: %s" % str(entries[index].get("usage", "용도 미지정"))
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	status.text = "대상: %s — %d × %d px" % [current_path, current_image.get_width(), current_image.get_height()]

func _open_target_dialog() -> void:
	if target_dialog == null:
		return
	target_thumbnail_cache.clear()
	target_dialog.invalidate()
	target_dialog.popup_centered(Vector2i(1000, 700))

func _get_target_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = target_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		target_thumbnail_cache[path] = loaded
	return loaded

func _on_target_file_selected(path: String) -> void:
	if editing:
		_finish_erase()
	var loaded := LOADER.load_image(path)
	if loaded == null:
		status.text = "편집 대상 이미지를 불러올 수 없습니다: %s" % path
		return
	current_index = -1
	current_path = path
	current_image = loaded
	IMAGE_STATE.open_image(path)
	list.deselect_all()
	usage_label.text = "용도: 새 편집 대상 이미지"
	_refresh_view()
	status.text = "새 편집 대상: %s — 편집 후 기존 카탈로그를 선택해 교체할 수 있습니다." % path

func _save_current_image_copy() -> String:
	if not _require_image():
		return ""
	var dir := ProjectSettings.globalize_path(EDITED_DIR)
	var err := DirAccess.make_dir_recursive_absolute(dir)
	if err != OK:
		return ""
	var name := current_path.get_file().get_basename().to_snake_case()
	if name.is_empty():
		name = "image"
	var output := "%s/%s_edit_%d.png" % [EDITED_DIR, name, Time.get_ticks_usec()]
	err = current_image.save_png(ProjectSettings.globalize_path(output))
	return output if err == OK else ""

func _reconnect_current_to_selected_entry() -> void:
	if not _require_image():
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "왼쪽 연결 목록에서 교체할 카탈로그 항목을 먼저 선택하세요."
		return
	if str(entries[catalog_target_index].get("path", "")) == current_path:
		status.text = "다른 이미지를 편집 대상으로 열어 주세요."
		return
	if source_path == current_path:
		source_path = ""
		source_image = null
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "편집 이미지를 저장하지 못해 카탈로그를 교체할 수 없습니다."
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "왼쪽 연결 목록에서 교체할 카탈로그 항목을 먼저 선택하세요."
		return
	if not _replace_entry_reference(entries[catalog_target_index], output):
		status.text = "이미지는 저장했지만 선택 카탈로그 참조 교체에 실패했습니다: %s" % output
		return
	current_path = output
	IMAGE_STATE.open_image(output)
	_refresh_view()
	_scan_connected_images()
	_select_path(output)
	status.text = "선택 카탈로그 참조를 새 이미지로 교체했습니다: %s" % output

func _replace_entry_reference(entry: Dictionary, new_path: String) -> bool:
	var owner_kind := str(entry.get("owner_kind", ""))
	if owner_kind == "json":
		return _replace_json_value(str(entry.get("owner", "")), str(entry.get("owner_key", "")), str(entry.get("field", "")), new_path)
	if owner_kind == "catalog":
		return _replace_catalog_value(str(entry.get("owner_key", "")), new_path)
	if owner_kind == "main":
		return _replace_main_path(str(entry.get("owner_key", "")), new_path)
	return false

func _add_current_image_to_asset_catalog() -> void:
	if not _require_image():
		return
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "새 카탈로그용 PNG를 저장하지 못했습니다."
		return
	var catalog_path := "res://content/editor/asset_catalog.json"
	var data: Variant = {}
	if FileAccess.file_exists(catalog_path):
		var file := FileAccess.open(catalog_path, FileAccess.READ)
		if file != null:
			data = JSON.parse_string(file.get_as_text())
			file.close()
	if not data is Dictionary:
		data = {}
	var assets: Array = data.get("assets", []) if data.get("assets", []) is Array else []
	var base_id := "asset.image." + current_path.get_file().get_basename().to_snake_case()
	if base_id == "asset.image.":
		base_id = "asset.image.generated"
	var asset_id := base_id
	var suffix := 1
	while _catalog_asset_id_exists(assets, asset_id):
		asset_id = "%s.%02d" % [base_id, suffix]
		suffix += 1
	var display_name := current_path.get_file().get_basename().replace("_", " ").capitalize()
	var width := current_image.get_width()
	var height := current_image.get_height()
	assets.append({
		"asset_id": asset_id,
		"kind": "object",
		"group": "Other",
		"display_name": display_name,
		"source_path": output,
		"source_rect_px": [0, 0, width, height],
		"footprint_tiles": [maxi(1, ceili(float(width) / 32.0)), maxi(1, ceili(float(height) / 32.0))]
	})
	data["schema_version"] = int(data.get("schema_version", 1))
	data["assets"] = assets
	if not _write_json(catalog_path, data):
		status.text = "PNG는 저장했지만 Asset Catalog 저장에 실패했습니다: %s" % output
		return
	_scan_connected_images()
	_select_path(output)
	status.text = "새 Asset Catalog 항목을 등록했습니다: %s" % asset_id

func _catalog_asset_id_exists(assets: Array, asset_id: String) -> bool:
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			return true
	return false

func _get_source_thumbnail(path: String) -> Texture2D:
	var cached: Texture2D = source_thumbnail_cache.get(path) as Texture2D
	if cached != null:
		return cached
	var loaded := load(path) as Texture2D
	if loaded != null:
		source_thumbnail_cache[path] = loaded
	return loaded

func _open_source_dialog() -> void:
	source_thumbnail_cache.clear()
	if source_dialog != null:
		source_dialog.popup_centered(Vector2i(1000, 700))

func _on_source_file_selected(path: String) -> void:
	if path == current_path:
		status.text = "대상과 다른 이미지를 참조 이미지로 선택하세요."
		return
	source_path = path
	source_index = -1
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "참조 이미지를 불러올 수 없습니다: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "참조: %s — 드래그로 영역을 선택하세요." % source_path

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

func _apply_source_region_reference() -> void:
	if not _require_image(): return
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "먼저 다른 참조 이미지를 열거나 선택하세요."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "참조 이미지에서 영역을 드래그로 선택하세요."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	if not _save_source_reference(source_path, rect):
		status.text = "참조 이미지 설정을 저장하지 못했습니다."
		return
	status.text = "참조 이미지로 설정했습니다: %s [%d, %d, %d, %d]" % [source_path, rect.position.x, rect.position.y, rect.size.x, rect.size.y]

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

func _replace_source_region_as_unit() -> void:
	if not _require_image(): return
	if current_index < 0 or current_index >= entries.size():
		status.text = "먼저 유닛 또는 타워 이미지를 선택하세요."
		return
	var entry: Dictionary = entries[current_index]
	var owner_path := str(entry.get("owner", ""))
	var owner_key := str(entry.get("owner_key", ""))
	if str(entry.get("owner_kind", "")) != "json" or (owner_path != "res://content/towers/towers.json" and owner_path != "res://content/allied_units/allied_units.json"):
		status.text = "유닛 또는 타워에 연결된 이미지에서 사용할 수 있습니다."
		return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "먼저 다른 참조 이미지를 선택하세요."
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "참조 이미지에서 유닛으로 사용할 영역을 드래그로 선택하세요."
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	var region := source_image.get_region(rect)
	var frame_size := Vector2i(60, 90)
	var frame_count := 4
	var unit_label := "타워"
	if owner_path == "res://content/allied_units/allied_units.json":
		var sizes := {"basic": Vector2i(60, 90), "light": Vector2i(60, 90), "ranged": Vector2i(60, 90), "heavy": Vector2i(72, 96), "support": Vector2i(72, 96)}
		frame_size = sizes.get(owner_key, Vector2i(60, 90))
		frame_count = 8
		unit_label = "유닛"
	var frame := Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	frame.fill(Color(0, 0, 0, 0))
	var scale := minf(float(frame_size.x) / float(region.get_width()), float(frame_size.y) / float(region.get_height()))
	var fitted_w := maxi(1, roundi(region.get_width() * scale))
	var fitted_h := maxi(1, roundi(region.get_height() * scale))
	region.resize(fitted_w, fitted_h, Image.INTERPOLATE_LANCZOS)
	var dest := Rect2i((frame_size.x - fitted_w) / 2, frame_size.y - fitted_h, fitted_w, fitted_h)
	frame.blit_rect(region, Rect2i(0, 0, fitted_w, fitted_h), dest.position)
	var sheet := Image.create(frame_size.x * frame_count, frame_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	for frame_index in frame_count:
		sheet.blit_rect(frame, Rect2i(0, 0, frame_size.x, frame_size.y), Vector2i(frame_index * frame_size.x, 0))
	current_image = sheet
	_refresh_view()
	status.text = "%s용 %d프레임 %d × %d px로 정규화했습니다. 저장 + 연결 변경을 눌러 적용하세요." % [unit_label, frame_count, sheet.get_width(), sheet.get_height()]

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
func _save_source_reference(path: String, rect: Rect2i) -> bool:
	if current_index < 0 or current_index >= entries.size(): return false
	var entry: Dictionary = entries[current_index]
	var owner_kind := str(entry.owner_kind)
	if owner_kind == "json":
		return _replace_json_reference(str(entry.owner), str(entry.owner_key), str(entry.field), path, rect)
	if owner_kind == "catalog":
		return _replace_catalog_reference(str(entry.owner_key), path, rect)
	return false

func _replace_json_reference(path: String, key: String, field: String, source_path_value: String, rect: Rect2i) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary or not data.has(key): return false
	_set_nested_value(data[key], field, source_path_value)
	_set_nested_value(data[key], _field_suffix(field, "_rect"), [rect.position.x, rect.position.y, rect.size.x, rect.size.y])
	return _write_json(path, data)

func _field_suffix(field: String, suffix: String) -> String:
	var parts := field.split(".")
	parts[parts.size() - 1] = str(parts[parts.size() - 1]) + suffix
	return ".".join(parts)

func _set_nested_value(root: Dictionary, field: String, value: Variant) -> void:
	var parts := field.split(".")
	var target := root
	for i in range(parts.size() - 1):
		var part := str(parts[i])
		if not target.has(part) or not target[part] is Dictionary:
			target[part] = {}
		target = target[part]
	target[str(parts[parts.size() - 1])] = value

func _erase_nested_value(root: Dictionary, field: String) -> void:
	var parts := field.split(".")
	var target := root
	for i in range(parts.size() - 1):
		var part := str(parts[i])
		if not target.has(part) or not target[part] is Dictionary:
			return
		target = target[part]
	target.erase(str(parts[parts.size() - 1]))

func _replace_catalog_reference(asset_id: String, source_path_value: String, rect: Rect2i) -> bool:
	var path := "res://content/editor/asset_catalog.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary: return false
	var assets: Array = data.get("assets", [])
	for asset in assets:
		if asset is Dictionary and str(asset.get("asset_id", "")) == asset_id:
			asset["source_path"] = source_path_value
			asset["source_rect_px"] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
			return _write_json(path, data)
	return false

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
	_set_nested_value(data[key], field, new_path)
	# 저장 + 연결 변경으로 새 편집 PNG에 연결할 때는 이전 참조 영역을 제거한다.
	# 새 PNG 자체가 교체 결과물이므로 전체 이미지를 사용해야 한다.
	_erase_nested_value(data[key], _field_suffix(field, "_rect"))
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

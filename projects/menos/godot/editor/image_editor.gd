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
var filter_option: OptionButton
var search_edit: LineEdit
var filtered_indices: Array[int] = []

signal request_content_editor
signal request_previous_editor

func _request_content_editor() -> void:
	request_content_editor.emit()

func _request_previous_editor() -> void:
	IMAGE_STATE.cancel_selection()
	request_previous_editor.emit()

func _use_selected_asset() -> void:
	if current_path.is_empty():
		status.text = "?????Asset???믪눘? ?醫뤾문??뤾쉭??"
		return
	if not IMAGE_STATE.selection_pending:
		status.text = "?袁⑹삺 Editor?癒?퐣 Asset ?醫뤾문???遺욧퍕???怨밴묶揶쎛 ?袁⑤뻸??덈뼄."
		return
	IMAGE_STATE.apply_selection(current_path)
	request_previous_editor.emit()

func _ready() -> void:
	_build_ui()
	_scan_connected_images()
	if IMAGE_STATE.selection_pending and not IMAGE_STATE.selection_asset_id.is_empty():
		_select_asset_id(IMAGE_STATE.selection_asset_id)
	elif not IMAGE_STATE.selected_path.is_empty():
		_select_path(IMAGE_STATE.selected_path)

func _select_asset_id(asset_id: String) -> void:
	if asset_id.is_empty():
		return
	for visible_index in range(filtered_indices.size()):
		var entry_index := filtered_indices[visible_index]
		var entry: Dictionary = entries[entry_index]
		if str(entry.get("owner_kind", "")) == "visual_asset" and str(entry.get("owner_key", "")) == asset_id:
			list.select(visible_index)
			_select_entry(visible_index)
			return
	# Keep the current source-path fallback if the requested Visual Asset is unavailable.
	_select_path(IMAGE_STATE.selected_path)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var title_row := HBoxContainer.new()
	root.add_child(title_row)
	var title := Label.new()
	title.text = "Catalog Editor"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title_row.add_child(title)
	var previous_button := Button.new()
	previous_button.text = "이전 에디터"
	previous_button.pressed.connect(_request_previous_editor)
	title_row.add_child(previous_button)
	previous_button.visible = false
	var content_button := Button.new()
	content_button.text = "Content Editor"
	content_button.pressed.connect(_request_content_editor)
	title_row.add_child(content_button)
	content_button.visible = false
	var intro := Label.new()
	intro.text = "Choose a Source Image, then drag to select a region or register it as a Visual Asset."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(intro)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var left := VBoxContainer.new()
	# Catalog browser: keep thumbnail cells uniform so very large source images do not dominate the list.
	left.custom_minimum_size.x = 420
	body.add_child(left)
	var list_title := Label.new()
	list_title.text = "Catalog Editor"
	left.add_child(list_title)
	var search_row := HBoxContainer.new()
	left.add_child(search_row)
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "Search image / project / category"
	search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_edit.text_changed.connect(func(_text: String): _refresh_entry_list())
	search_row.add_child(search_edit)
	filter_option = OptionButton.new()
	for filter_name in ["All", "Catalog", "Map", "Unit", "Robot", "Tower", "Enemy", "Runtime"]:
		filter_option.add_item(filter_name)
	filter_option.select(1)
	filter_option.item_selected.connect(func(_index: int): _refresh_entry_list())
	search_row.add_child(filter_option)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Use a fixed thumbnail box and grid so large/small source images have equal visual weight.
	list.icon_mode = ItemList.ICON_MODE_TOP
	list.fixed_icon_size = Vector2i(140, 100)
	list.fixed_column_width = 190
	list.max_text_lines = 2
	list.item_selected.connect(_select_entry)
	left.add_child(list)
	var clear_selection := Button.new()
	clear_selection.text = "선택 해제"
	clear_selection.pressed.connect(_clear_image_selection)
	left.add_child(clear_selection)
	var use_selected_button := Button.new()
	use_selected_button.text = "Use Selected Asset"
	use_selected_button.pressed.connect(_use_selected_asset)
	left.add_child(use_selected_button)
	var open_target_button := Button.new()
	open_target_button.text = "소스 이미지 열기"
	open_target_button.pressed.connect(_open_target_dialog)
	left.add_child(open_target_button)
	var reconnect_target_button := Button.new()
	reconnect_target_button.text = "Reconnect to Previous Editor"
	reconnect_target_button.pressed.connect(_reconnect_current_to_selected_entry)
	left.add_child(reconnect_target_button)
	reconnect_target_button.visible = false
	var new_catalog_button := Button.new()
	new_catalog_button.text = "선택 영역을 Visual Asset으로 등록"
	new_catalog_button.pressed.connect(_create_visual_asset_from_selection)
	left.add_child(new_catalog_button)
	var full_catalog_button := Button.new()
	full_catalog_button.text = "?袁⑷퍥 ???筌왖??Visual Asset??곗쨮 ?源낆쨯"
	full_catalog_button.pressed.connect(_create_visual_asset_from_full_image)
	left.add_child(full_catalog_button)
	full_catalog_button.visible = false
	var audit_button := Button.new()
	audit_button.text = "이미지 참조 검사"
	audit_button.pressed.connect(_audit_image_references)
	left.add_child(audit_button)
	audit_button.visible = false
	var source_panel := VBoxContainer.new()
	source_panel.custom_minimum_size.x = 280
	body.add_child(source_panel)
	source_panel.visible = false
	var source_title := Label.new()
	source_title.text = "소스 이미지"
	source_panel.add_child(source_title)
	source_list = ItemList.new()
	source_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	source_list.item_selected.connect(_select_source_entry)
	source_panel.add_child(source_list)
	var source_help := Label.new()
	source_help.text = "??긱걹?癒?퐣 ?醫뤾문??Asset????삘뀲 Source???ⓥ뫀???袁⑷퍥 ?癒?뮉 ?醫뤾문 ?怨몃열????쑨???대Ŋ猿??몃빍??"
	source_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source_panel.add_child(source_help)
	var source_full := Button.new()
	source_full.text = "Use Full Source"
	source_full.pressed.connect(_replace_from_source_full)
	source_panel.add_child(source_full)
	var source_open := Button.new()
	source_open.text = "소스 이미지 열기"
	source_open.pressed.connect(_open_source_dialog)
	source_panel.add_child(source_open)
	var source_region := Button.new()
	source_region.text = "Use Selected Region"
	source_region.pressed.connect(_replace_from_source_region)
	source_panel.add_child(source_region)
	var normalize := Button.new()
	normalize.name = "NormalizeUnitButton"
	normalize.text = "Normalize Selection"
	normalize.pressed.connect(_replace_source_region_as_unit)
	source_panel.add_child(normalize)
	var source_reference := Button.new()
	source_reference.text = "선택 영역을 소스 참조로 적용"
	source_reference.pressed.connect(_apply_source_region_reference)
	source_panel.add_child(source_reference)
	source_dialog = FileDialog.new()
	source_dialog.title = "소스 이미지 선택"
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
	target_dialog.title = "대상 이미지 선택"
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
	usage_label.text = "?醫뤾문??Asset ??곸벉"
	usage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage_label.add_theme_font_size_override("font_size", 16)
	right.add_child(usage_label)
	view = REGION_VIEW_SCRIPT.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(view)
	var tools := HBoxContainer.new()
	right.add_child(tools)
	tools.visible = false
	_add_button(tools, "Erase", _start_erase)
	_add_button(tools, "Crop Selection", _crop_selection)
	_add_button(tools, "Flip Horizontal", _flip_h)
	_add_button(tools, "Flip Vertical", _flip_v)
	_add_button(tools, "시계 방향 회전", _rotate_cw)
	_add_button(tools, "반시계 방향 회전", _rotate_ccw)
	_add_button(tools, "알파 영역 자르기", _trim_alpha)
	_add_button(tools, "Save + Reconnect", _save_reconnect)
	var resize_row := HBoxContainer.new()
	right.add_child(resize_row)
	resize_row.visible = false
	var resize_label := Label.new()
	resize_label.text = "크기"
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
	_refresh_entry_list()

func _add_button(parent: HBoxContainer, text_value: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text_value
	b.pressed.connect(callback)
	parent.add_child(b)

func _scan_connected_images() -> void:
	entries.clear()
	var seen := {}
	_scan_json_images("res://content/towers/towers.json", "towers", "sprite_anim", "Tower sprite animation", "Tower", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?醫딅뻺", "visuals.sprite", "???쟿??곷선 ?醫딅뻺 ???筌왖", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?醫딅뻺", "visuals.default_image", "?醫딅뻺 Profile Image", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?醫딅뻺", "projectile_anim", "?醫딅뻺 ?袁れ넎 ???筌왖", "Unit", seen)
	_scan_json_images("res://content/enemies/enemies.json", "???醫딅뻺", "sprite_anim", "???醫딅뻺 ???筌왖", "Enemy", seen)
	_scan_json_images("res://content/enemies/enemies.json", "???醫딅뻺", "projectile_anim", "???醫딅뻺 ?袁れ넎 ???筌왖", "Enemy", seen)
	_scan_allied_animations(seen)
	_scan_robot_images(seen)
	_scan_catalog(seen)
	_scan_visual_assets(seen)
	_scan_main_preloads(seen)
	list.clear()
	source_list.clear()
	_refresh_entry_list()
	var catalog_count := 0
	for entry in entries:
		if str(entry.get("owner_kind", "")) == "visual_asset":
			catalog_count += 1
	status.text = "%d개의 Visual Asset이 등록되어 있습니다." % catalog_count

func _refresh_entry_list() -> void:
	if list == null or source_list == null:
		return
	filtered_indices.clear()
	list.clear()
	source_list.clear()
	var query := search_edit.text.strip_edges().to_lower() if search_edit else ""
	var filter_name := filter_option.get_item_text(filter_option.selected) if filter_option and filter_option.selected >= 0 else "All"
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var category := str(entry.get("category", "Other"))
		var is_catalog_entry := str(entry.get("owner_kind", "")) == "visual_asset"
		if filter_name == "Catalog" and not is_catalog_entry:
			continue
		if filter_name != "All" and filter_name != "Catalog" and category != filter_name:
			continue
		if not query.is_empty():
			var haystack := (str(entry.get("label", "")) + " " + str(entry.get("path", "")) + " " + str(entry.get("usage", "")) + " " + str(entry.get("owner", ""))).to_lower()
			if not haystack.contains(query):
				continue
		filtered_indices.append(index)
		var icon: Texture2D = _get_catalog_thumbnail(entry) if is_catalog_entry else load(str(entry.get("path", ""))) as Texture2D
		var display_category := "燁삳??롦에?볥젃" if is_catalog_entry else category
		var label_text := "[%s] %s" % [display_category, str(entry.get("label", "Asset"))]
		list.add_item(label_text, icon)
		list.set_item_metadata(list.item_count - 1, index)
		source_list.add_item(label_text, icon)
		source_list.set_item_metadata(source_list.item_count - 1, index)

func _get_catalog_thumbnail(entry: Dictionary) -> Texture2D:
	var source_path := str(entry.get("path", ""))
	var source_texture := load(source_path) as Texture2D
	if source_texture == null:
		return null
	var rect := _entry_region(entry)
	if rect.size.x <= 0 or rect.size.y <= 0:
		return source_texture
	var source_size := Vector2i(source_texture.get_width(), source_texture.get_height())
	var clipped := rect.intersection(Rect2i(Vector2i.ZERO, source_size))
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return source_texture
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = Rect2(clipped)
	return atlas

func _audit_image_references() -> void:
	var missing: Array[String] = []
	var invalid: Array[String] = []
	for entry in entries:
		var image_path := str(entry.get("path", ""))
		if image_path.is_empty():
			continue
		if not ResourceLoader.exists(image_path):
			missing.append("%s | %s" % [str(entry.get("label", "???筌왖")), image_path])
			continue
		var texture := load(image_path) as Texture2D
		if texture == null:
			invalid.append("%s | %s" % [str(entry.get("label", "???筌왖")), image_path])
	var report := "???筌왖 筌〓챷???癒? 野껉퀗??n\n?袁⑷퍥 筌〓챷?? %d\n?袁⑥뵭: %d\n嚥≪뮆諭???쎈솭: %d" % [entries.size(), missing.size(), invalid.size()]
	if not missing.is_empty():
		report += "\n\n[?袁⑥뵭?????筌왖]\n" + "\n".join(missing)
	if not invalid.is_empty():
		report += "\n\n[嚥≪뮆諭???쎈솭 ???筌왖]\n" + "\n".join(invalid)
	if missing.is_empty() and invalid.is_empty():
		report += "\n\n筌뤴뫀諭??怨뚭퍙 ???筌왖 筌〓챷?쒎첎? ?類ㅺ맒??낅빍??"
	var dialog := AcceptDialog.new()
	dialog.title = "???筌왖 筌〓챷???癒?"
	dialog.dialog_text = report
	dialog.ok_button_text = "??る┛"
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(760, 520))

func _scan_json_images(path: String, kind: String, field: String, usage: String, category: String, seen: Dictionary) -> void:
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
		entries.append({"label": "%s / %s" % [kind, str(data[key].get("name", key))], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage, "category": category})

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
			entries.append({"label": "Unit / %s / %s" % [str(data[key].get("name", key)), str(animation_name)], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "visuals.animations." + str(animation_name), "usage": "Unit animation %s" % str(animation_name), "category": "Unit"})

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
			var usage := "嚥≪뮆????疫????筌왖"
			match field:
				"sprite_attack": usage = "嚥≪뮆???⑤벀爰????筌왖"
				"default_image": usage = "嚥≪뮆??Profile Image"
				"sprite_move": usage = "嚥≪뮆????猷????筌왖"
				"sprite_skill": usage = "嚥≪뮆????쎄텢 ???筌왖"
				"projectile_anim": usage = "嚥≪뮆????沅쀯㎗????筌왖"
			entries.append({"label": "嚥≪뮆??/ %s" % robot_name, "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage, "category": "Robot"})
		var animations: Dictionary = data[key].get("animations", {})
		if animations is Dictionary:
			for animation_name in animations:
				var animation_path := str(animations[animation_name])
				if animation_path.is_empty() or seen.has(animation_path): continue
				seen[animation_path] = true
				entries.append({"label": "Robot / %s / %s" % [robot_name, str(animation_name)], "path": animation_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "animations." + str(animation_name), "usage": "Robot animation %s" % str(animation_name), "category": "Robot"})

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
		entries.append({"label": "燁삳똾源됪에?볥젃 / %s" % str(asset.get("display_name", asset.get("asset_id", "Asset"))), "path": image_path, "owner": path, "owner_kind": "catalog", "owner_key": str(asset.get("asset_id", "")), "field": "source_path", "usage": "%s / %s" % [str(asset.get("group", "燁삳똾源됪에?볥젃")), str(asset.get("kind", "asset"))], "category": "Map"})
func _scan_visual_assets(seen: Dictionary) -> void:
	var path := "res://content/editor/visual_assets.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return
	for asset_id in data:
		var asset = data[asset_id]
		if not asset is Dictionary:
			continue
		var image_path := str(asset.get("source", ""))
		if image_path.is_empty():
			continue
		# Visual Assets are distinct catalog entries even when they share a source image.
		var region_data: Array = asset.get("region", [])
		var region_text := ""
		if region_data.size() >= 4:
			region_text = " [%s,%s %sx%s]" % [region_data[0], region_data[1], region_data[2], region_data[3]]
		entries.append({
			"label": "Visual Asset / %s" % str(asset.get("id", asset_id)),
			"path": image_path,
			"region": region_data,
			"owner": path,
			"owner_kind": "visual_asset",
			"owner_key": str(asset_id),
			"field": "source",
			"usage": "Visual Asset%s" % region_text,
			"category": str(asset.get("category", "Other"))
		})

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
		entries.append({"label": "?怨???/ %s" % image_path.get_file(), "path": image_path, "owner": path, "owner_kind": "main", "owner_key": image_path, "field": "preload", "usage": "野껊슣???怨??????筌왖", "category": "Runtime"})

func _select_path(path: String) -> void:
	for visible_index in range(filtered_indices.size()):
		var entry_index := filtered_indices[visible_index]
		if str(entries[entry_index].get("path", "")) == path:
			list.select(visible_index)
			_select_entry(visible_index)
			return
	for entry_index in range(entries.size()):
		if str(entries[entry_index].get("path", "")) == path:
			if search_edit:
				search_edit.text = ""
			if filter_option:
				filter_option.select(0)
			_refresh_entry_list()
			if entry_index < filtered_indices.size():
				var visible_index := filtered_indices.find(entry_index)
				if visible_index >= 0:
					list.select(visible_index)
					_select_entry(visible_index)
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
	usage_label.text = "?醫뤾문??Asset ??곸벉"
	view.set_source_texture(null)
	status.text = "???筌왖 ?醫뤾문????곸젫??됰뮸??덈뼄."

func _select_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= list.item_count: return
	var entry_index := int(list.get_item_metadata(index))
	if entry_index < 0 or entry_index >= entries.size(): return
	catalog_target_index = entry_index
	current_index = entry_index
	current_path = str(entries[entry_index].get("path", ""))
	if IMAGE_STATE.selection_pending:
		IMAGE_STATE.selected_path = current_path
	else:
		IMAGE_STATE.open_image(current_path)
	current_image = LOADER.load_image(current_path)
	var entry: Dictionary = entries[entry_index]
	var catalog_region: Rect2i = _entry_region(entry)
	usage_label.text = "[%s] %s\nUsage: %s\nSource: %s\nOwner: %s\nField: %s" % [str(entry.get("category", "Other")), str(entry.get("label", "Asset")), str(entry.get("usage", "Unknown")), current_path, str(entry.get("owner", "Unknown")), str(entry.get("field", "Unknown"))]
	if current_image == null:
		status.text = "???筌왖???븍뜄???????곷뮸??덈뼄: %s" % current_path
		return
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	if catalog_region.size.x > 0 and catalog_region.size.y > 0:
		view.selected_region = catalog_region
		view.queue_redraw()
	status.text = "?醫뤾문??燁삳??롦에?볥젃: %s ???怨몃열 %d ??%d px" % [str(entry.get("label", "Asset")), catalog_region.size.x, catalog_region.size.y] if catalog_region.size.x > 0 else "?醫뤾문??Source: %s ??%d ??%d px" % [current_path, current_image.get_width(), current_image.get_height()]

func _entry_region(entry: Dictionary) -> Rect2i:
	var region_data: Array = entry.get("region", [])
	if region_data.size() < 4:
		return Rect2i()
	return Rect2i(int(region_data[0]), int(region_data[1]), int(region_data[2]), int(region_data[3]))

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
		status.text = "?紐꾩춿 ???????筌왖???븍뜄???????곷뮸??덈뼄: %s" % path
		return
	current_index = -1
	current_path = path
	current_image = loaded
	IMAGE_STATE.open_image(path)
	list.deselect_all()
	usage_label.text = "??몃즲: ???紐꾩춿 ???????筌왖"
	_refresh_view()
	status.text = "?????筌왖: %s ????뺤삋域밸챶以??怨몃열???醫뤾문????Visual Asset??곗쨮 ?源낆쨯??????됰뮸??덈뼄." % path

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
		status.text = "??긱걹 ?怨뚭퍙 筌뤴뫖以?癒?퐣 ?대Ŋ猿??燁삳똾源됪에?볥젃 ??????믪눘? ?醫뤾문??뤾쉭??"
		return
	if str(entries[catalog_target_index].get("path", "")) == current_path:
		status.text = "??삘뀲 ???筌왖???紐꾩춿 ???怨몄몵嚥???곷선 雅뚯눘苑??"
		return
	if source_path == current_path:
		source_path = ""
		source_image = null
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "?紐꾩춿 ???筌왖?????館釉?쭪? 筌륁궢鍮?燁삳똾源됪에?볥젃???대Ŋ猿??????곷뮸??덈뼄."
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "??긱걹 ?怨뚭퍙 筌뤴뫖以?癒?퐣 ?대Ŋ猿??燁삳똾源됪에?볥젃 ??????믪눘? ?醫뤾문??뤾쉭??"
		return
	if not _replace_entry_reference(entries[catalog_target_index], output):
		status.text = "???筌왖?????館六쏙쭪?筌??醫뤾문 燁삳똾源됪에?볥젃 筌〓챷???대Ŋ猿????쎈솭??됰뮸??덈뼄: %s" % output
		return
	current_path = output
	IMAGE_STATE.open_image(output)
	_refresh_view()
	_scan_connected_images()
	_select_path(output)
	status.text = "?醫뤾문 燁삳똾源됪에?볥젃 筌〓챷?쒐몴??????筌왖嚥??대Ŋ猿??됰뮸??덈뼄: %s" % output

func _replace_entry_reference(entry: Dictionary, new_path: String) -> bool:
	var owner_kind := str(entry.get("owner_kind", ""))
	if owner_kind == "json":
		return _replace_json_value(str(entry.get("owner", "")), str(entry.get("owner_key", "")), str(entry.get("field", "")), new_path)
	if owner_kind == "catalog":
		return _replace_catalog_value(str(entry.get("owner_key", "")), new_path)
	if owner_kind == "main":
		return _replace_main_path(str(entry.get("owner_key", "")), new_path)
	return false

func _create_visual_asset_from_selection() -> void:
	if not _require_image():
		return
	var rect := view.selected_region
	# When arriving from Robot/Unit/Tower Editor, the selected Visual Asset already
	# defines the intended region. Keep that region as the default registration area.
	if rect.size.x <= 0 or rect.size.y <= 0:
		var selected_entry: Dictionary = entries[current_index] if current_index >= 0 and current_index < entries.size() else {}
		rect = _entry_region(selected_entry)
		if rect.size.x > 0 and rect.size.y > 0:
			view.selected_region = rect
			view.queue_redraw()
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "?믪눘? ???筌왖?癒?퐣 燁삳똾源됪에?볥젃嚥?筌띾슢諭??怨몃열????뺤삋域밸챸鍮???醫뤾문??뤾쉭??"
		return
	_create_visual_asset(rect)

func _create_visual_asset_from_full_image() -> void:
	if not _require_image():
		return
	_create_visual_asset(Rect2i(0, 0, current_image.get_width(), current_image.get_height()))

func _create_visual_asset(rect: Rect2i) -> void:
	var catalog_path := "res://content/editor/visual_assets.json"
	var data: Variant = {}
	if FileAccess.file_exists(catalog_path):
		var file := FileAccess.open(catalog_path, FileAccess.READ)
		if file != null:
			data = JSON.parse_string(file.get_as_text())
			file.close()
	if not data is Dictionary:
		data = {}
	var base_name := current_path.get_file().get_basename().to_snake_case()
	if base_name.is_empty():
		base_name = "image"
	var inherited_frames := 1
	var inherited_category := "Other"
	if current_index >= 0 and current_index < entries.size():
		var source_entry: Dictionary = entries[current_index]
		if str(source_entry.get("owner_kind", "")) == "visual_asset":
			var source_asset_id := str(source_entry.get("owner_key", ""))
			var source_definition := VisualAssetResolver.get_asset(source_asset_id)
			if source_definition != null:
				inherited_frames = source_definition.frames
				inherited_category = source_definition.category
	var base_id := "image." + base_name
	var assets: Dictionary = data
	var suffix := 1
	var asset_id := base_id
	while assets.has(asset_id):
		asset_id = "%s.%02d" % [base_id, suffix]
		suffix += 1
	assets[asset_id] = {
		"id": asset_id,
		"category": inherited_category,
		"source": current_path,
		"region": [rect.position.x, rect.position.y, rect.size.x, rect.size.y],
		"frames": inherited_frames,
		"owner": "",
		"usage": "visual_asset_catalog"
	}
	if not _write_json(catalog_path, assets):
		status.text = "Visual Asset Catalog 저장에 실패했습니다."
		return
	VisualAssetResolver.reload()
	_scan_connected_images()
	var created_index := -1
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		if str(entry.get("owner_kind", "")) == "visual_asset" and str(entry.get("owner_key", "")) == asset_id:
			created_index = index
			break
	if created_index >= 0:
		for list_index in range(filtered_indices.size()):
			if filtered_indices[list_index] == created_index:
				list.select(list_index)
				_select_entry(list_index)
				break
	else:
		_select_path(current_path)
	if IMAGE_STATE.selection_pending and not IMAGE_STATE.selection_target.is_empty():
		IMAGE_STATE.apply_selection(asset_id)
		status.text = "Visual Asset ?源낆쨯 ?袁⑥┷ 獄??癒?삋 Editor???怨몄뒠 餓Β?? %s | ?怨몃열 %d ??%d px" % [asset_id, rect.size.x, rect.size.y]
		request_previous_editor.emit()
	else:
		status.text = "Visual Asset ?源낆쨯 ?袁⑥┷: %s | ?怨몃열 %d ??%d px" % [asset_id, rect.size.x, rect.size.y]

func _add_current_image_to_asset_catalog() -> void:
	if not _require_image():
		return
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "??燁삳똾源됪에?볥젃??PNG?????館釉?쭪? 筌륁궢六??щ빍??"
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
		status.text = "PNG?????館六쏙쭪?筌?Asset Catalog ???關肉???쎈솭??됰뮸??덈뼄: %s" % output
		return
	_scan_connected_images()
	_select_path(output)
	status.text = "??Asset Catalog ??????源낆쨯??됰뮸??덈뼄: %s" % asset_id

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
		status.text = "???怨대궢 ??삘뀲 ???筌왖??筌〓챷?????筌왖嚥??醫뤾문??뤾쉭??"
		return
	source_path = path
	source_index = -1
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "筌〓챷?????筌왖???븍뜄???????곷뮸??덈뼄: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "筌〓챷?? %s ????뺤삋域밸챶以??怨몃열???醫뤾문??뤾쉭??" % source_path

func _select_source_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= source_list.item_count: return
	var entry_index := int(source_list.get_item_metadata(index))
	if entry_index < 0 or entry_index >= entries.size(): return
	source_index = entry_index
	source_path = str(entries[entry_index].get("path", ""))
	if source_path == current_path:
		status.text = "???怨대궢 ??삘뀲 ???筌왖??筌〓챷?????筌왖嚥??醫뤾문??뤾쉭??"
		return
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "筌〓챷?????筌왖???븍뜄???????곷뮸??덈뼄: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "筌〓챷?? %s ???袁⑷퍥 ?癒?뮉 ??뺤삋域??醫뤾문 ?怨몃열???????뤾쉭??" % source_path

func _replace_from_source_full() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "?믪눘? ??삘뀲 筌〓챷?????筌왖???醫뤾문??뤾쉭??"
		return
	current_image = source_image.duplicate()
	_refresh_view()
	status.text = "筌〓챷?????筌왖 ?袁⑷퍥?????怨몄몵嚥??대Ŋ猿??됰뮸??덈뼄. ????+ ?怨뚭퍙 癰궰野껋럩?????쑎 ?怨몄뒠??뤾쉭??"

func _apply_source_region_reference() -> void:
	if not _require_image(): return
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "?믪눘? ??삘뀲 筌〓챷?????筌왖????욧탢???醫뤾문??뤾쉭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "筌〓챷?????筌왖?癒?퐣 ?怨몃열????뺤삋域밸챶以??醫뤾문??뤾쉭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	if not _save_source_reference(source_path, rect):
		status.text = "筌〓챷?????筌왖 ??쇱젟?????館釉?쭪? 筌륁궢六??щ빍??"
		return
	status.text = "筌〓챷?????筌왖嚥???쇱젟??됰뮸??덈뼄: %s [%d, %d, %d, %d]" % [source_path, rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _replace_from_source_region() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "?믪눘? ??삘뀲 筌〓챷?????筌왖???醫뤾문??뤾쉭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "筌〓챷?????筌왖?癒?퐣 ?대Ŋ猿???怨몃열????뺤삋域밸챶以??醫뤾문??뤾쉭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = source_image.get_region(rect)
	_refresh_view()
	status.text = "筌〓챷???怨몃열 %d ??%d px嚥????怨몄뱽 ?대Ŋ猿??됰뮸??덈뼄. ????+ ?怨뚭퍙 癰궰野껋럩?????쑎 ?怨몄뒠??뤾쉭??" % [rect.size.x, rect.size.y]

func _replace_source_region_as_unit() -> void:
	if not _require_image(): return
	if current_index < 0 or current_index >= entries.size():
		status.text = "?믪눘? ?醫딅뻺 ?癒?뮉 ???????筌왖???醫뤾문??뤾쉭??"
		return
	var entry: Dictionary = entries[current_index]
	var owner_path := str(entry.get("owner", ""))
	var owner_key := str(entry.get("owner_key", ""))
	if str(entry.get("owner_kind", "")) != "json" or (owner_path != "res://content/towers/towers.json" and owner_path != "res://content/allied_units/allied_units.json"):
		status.text = "?醫딅뻺 ?癒?뮉 ?????퓠 ?怨뚭퍙?????筌왖?癒?퐣 ?????????됰뮸??덈뼄."
		return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "?믪눘? ??삘뀲 筌〓챷?????筌왖???醫뤾문??뤾쉭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "筌〓챷?????筌왖?癒?퐣 ?醫딅뻺??곗쨮 ??????怨몃열????뺤삋域밸챶以??醫뤾문??뤾쉭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	var region := source_image.get_region(rect)
	var frame_size := Vector2i(60, 90)
	var frame_count := 4
	var unit_label := "Unit"
	if owner_path == "res://content/allied_units/allied_units.json":
		var sizes := {"basic": Vector2i(60, 90), "light": Vector2i(60, 90), "ranged": Vector2i(60, 90), "heavy": Vector2i(72, 96), "support": Vector2i(72, 96)}
		frame_size = sizes.get(owner_key, Vector2i(60, 90))
		frame_count = 8
		unit_label = "?醫딅뻺"
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
	status.text = "%s??%d?袁⑥쟿??%d ??%d px嚥??類?뇣?酉六??щ빍?? ????+ ?怨뚭퍙 癰궰野껋럩?????쑎 ?怨몄뒠??뤾쉭??" % [unit_label, frame_count, sheet.get_width(), sheet.get_height()]

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
	status.text = "%s ??%d ??%d px" % [current_path, current_image.get_width(), current_image.get_height()]
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
	# ????+ ?怨뚭퍙 癰궰野껋럩?앮에????紐꾩춿 PNG???怨뚭퍙?????뮉 ??곸읈 筌〓챷???怨몃열????볤탢??뺣뼄.
	# ??PNG ?癒?퍥揶쎛 ?대Ŋ猿?野껉퀗?듣눧?깆뵠沃샕嚥??袁⑷퍥 ???筌왖???????곷튊 ??뺣뼄.
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

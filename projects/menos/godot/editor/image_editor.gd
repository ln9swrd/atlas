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
		status.text = "?ъ슜??Asset??癒쇱? ?좏깮?섏꽭??"
		return
	if not IMAGE_STATE.selection_pending:
		status.text = "?꾩옱 Editor?먯꽌 Asset ?좏깮???붿껌???곹깭媛 ?꾨떃?덈떎."
		return
	IMAGE_STATE.apply_selection(current_path)
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
	title.text = "移대떎濡쒓렇 ?먮뵒??
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title_row.add_child(title)
	var previous_button := Button.new()
	previous_button.text = "?댁쟾 ?붾㈃"
	previous_button.pressed.connect(_request_previous_editor)
	title_row.add_child(previous_button)
	previous_button.visible = false
	var content_button := Button.new()
	content_button.text = "肄섑뀗痢??먮뵒??
	content_button.pressed.connect(_request_content_editor)
	title_row.add_child(content_button)
	content_button.visible = false
	var intro := Label.new()
	intro.text = "?깅줉??移대떎濡쒓렇瑜?議고쉶?섍퀬, Source Image???쇰? ?곸뿭???좏깮???덈줈??移대떎濡쒓렇 ??ぉ?쇰줈 ?깅줉?⑸땲??"
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
	list_title.text = "?깅줉??移대떎濡쒓렇"
	left.add_child(list_title)
	var search_row := HBoxContainer.new()
	left.add_child(search_row)
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "?대쫫 / 寃쎈줈 / ?⑸룄濡?寃??
	search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_edit.text_changed.connect(func(_text: String): _refresh_entry_list())
	search_row.add_child(search_edit)
	filter_option = OptionButton.new()
	for filter_name in ["?꾩껜", "移대떎濡쒓렇", "Map", "Unit", "Robot", "Tower", "Enemy", "Runtime"]:
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
	clear_selection.text = "?좏깮 ?댁젣"
	clear_selection.pressed.connect(_clear_image_selection)
	left.add_child(clear_selection)
	var use_selected_button := Button.new()
	use_selected_button.text = "?좏깮 Asset ?ъ슜"
	use_selected_button.pressed.connect(_use_selected_asset)
	left.add_child(use_selected_button)
	var open_target_button := Button.new()
	open_target_button.text = "Source Image ?닿린"
	open_target_button.pressed.connect(_open_target_dialog)
	left.add_child(open_target_button)
	var reconnect_target_button := Button.new()
	reconnect_target_button.text = "?몄쭛 寃곌낵濡?李몄“ ?대?吏 援먯껜"
	reconnect_target_button.pressed.connect(_reconnect_current_to_selected_entry)
	left.add_child(reconnect_target_button)
	reconnect_target_button.visible = false
	var new_catalog_button := Button.new()
	new_catalog_button.text = "?좏깮 ?곸뿭??Visual Asset?쇰줈 ?깅줉"
	new_catalog_button.pressed.connect(_create_visual_asset_from_selection)
	left.add_child(new_catalog_button)
	var full_catalog_button := Button.new()
	full_catalog_button.text = "?꾩껜 ?대?吏瑜?Visual Asset?쇰줈 ?깅줉"
	full_catalog_button.pressed.connect(_create_visual_asset_from_full_image)
	left.add_child(full_catalog_button)
	full_catalog_button.visible = false
	var audit_button := Button.new()
	audit_button.text = "?대?吏 李몄“ ?먭?"
	audit_button.pressed.connect(_audit_image_references)
	left.add_child(audit_button)
	audit_button.visible = false
	var source_panel := VBoxContainer.new()
	source_panel.custom_minimum_size.x = 280
	body.add_child(source_panel)
	source_panel.visible = false
	var source_title := Label.new()
	source_title.text = "Source / ?ㅻⅨ Asset"
	source_panel.add_child(source_title)
	source_list = ItemList.new()
	source_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	source_list.item_selected.connect(_select_source_entry)
	source_panel.add_child(source_list)
	var source_help := Label.new()
	source_help.text = "?쇱そ?먯꽌 ?좏깮??Asset怨??ㅻⅨ Source瑜?怨⑤씪 ?꾩껜 ?먮뒗 ?좏깮 ?곸뿭??鍮꾧탳/援먯껜?⑸땲??"
	source_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	source_panel.add_child(source_help)
	var source_full := Button.new()
	source_full.text = "Source ?꾩껜濡?援먯껜"
	source_full.pressed.connect(_replace_from_source_full)
	source_panel.add_child(source_full)
	var source_open := Button.new()
	source_open.text = "??Source ?닿린"
	source_open.pressed.connect(_open_source_dialog)
	source_panel.add_child(source_open)
	var source_region := Button.new()
	source_region.text = "?좏깮 ?곸뿭?쇰줈 援먯껜"
	source_region.pressed.connect(_replace_from_source_region)
	source_panel.add_child(source_region)
	var normalize := Button.new()
	normalize.name = "NormalizeUnitButton"
	normalize.text = "?좊떅 ?ш린濡?留욎떠 援먯껜"
	normalize.pressed.connect(_replace_source_region_as_unit)
	source_panel.add_child(normalize)
	var source_reference := Button.new()
	source_reference.text = "?좏깮 ?곸뿭??李몄“濡??곌껐"
	source_reference.pressed.connect(_apply_source_region_reference)
	source_panel.add_child(source_reference)
	source_dialog = FileDialog.new()
	source_dialog.title = "李몄“ ?대?吏 ?닿린"
	source_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	source_dialog.access = FileDialog.ACCESS_RESOURCES
	source_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; ?대?吏"])
	source_dialog.display_mode = FileDialog.DISPLAY_THUMBNAILS
	source_dialog.add_theme_constant_override("thumbnail_size", 112)
	FileDialog.set_get_thumbnail_callback(Callable(self, "_get_source_thumbnail"))
	source_dialog.current_dir = "res://"
	source_dialog.file_selected.connect(_on_source_file_selected)
	add_child(source_dialog)
	target_dialog = FileDialog.new()
	target_dialog.title = "?몄쭛 ????대?吏 ?닿린"
	target_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	target_dialog.access = FileDialog.ACCESS_RESOURCES
	target_dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp,*.bmp ; ?대?吏"])
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
	usage_label.text = "?좏깮??Asset ?놁쓬"
	usage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	usage_label.add_theme_font_size_override("font_size", 16)
	right.add_child(usage_label)
	view = REGION_VIEW_SCRIPT.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(view)
	var tools := HBoxContainer.new()
	right.add_child(tools)
	tools.visible = false
	_add_button(tools, "?뚰뙆 ??젣", _start_erase)
	_add_button(tools, "?먮Ⅴ湲?, _crop_selection)
	_add_button(tools, "醫뚯슦 諛섏쟾", _flip_h)
	_add_button(tools, "?곹븯 諛섏쟾", _flip_v)
	_add_button(tools, "?쒓퀎 諛⑺뼢 ?뚯쟾", _rotate_cw)
	_add_button(tools, "諛섏떆怨?諛⑺뼢 ?뚯쟾", _rotate_ccw)
	_add_button(tools, "?щ챸 ?곸뿭 ?쒓굅", _trim_alpha)
	_add_button(tools, "???+ ?곌껐 蹂寃?, _save_reconnect)
	var resize_row := HBoxContainer.new()
	right.add_child(resize_row)
	resize_row.visible = false
	var resize_label := Label.new()
	resize_label.text = "?ш린 蹂寃?
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
	resize_btn.text = "?ш린 ?곸슜"
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
	_scan_json_images("res://content/towers/towers.json", "???, "sprite_anim", "諛⑹뼱 ?쒖꽕 ?대?吏", "Tower", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?좊떅", "visuals.sprite", "?뚮젅?댁뼱 ?좊떅 ?대?吏", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?좊떅", "visuals.default_image", "?좊떅 Profile Image", "Unit", seen)
	_scan_json_images("res://content/allied_units/allied_units.json", "?좊떅", "projectile_anim", "?좊떅 ?꾪솚 ?대?吏", "Unit", seen)
	_scan_json_images("res://content/enemies/enemies.json", "???좊떅", "sprite_anim", "???좊떅 ?대?吏", "Enemy", seen)
	_scan_json_images("res://content/enemies/enemies.json", "???좊떅", "projectile_anim", "???좊떅 ?꾪솚 ?대?吏", "Enemy", seen)
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
	status.text = "%d媛?移대떎濡쒓렇 ??ぉ??議고쉶?????덉뒿?덈떎." % catalog_count

func _refresh_entry_list() -> void:
	if list == null or source_list == null:
		return
	filtered_indices.clear()
	list.clear()
	source_list.clear()
	var query := search_edit.text.strip_edges().to_lower() if search_edit else ""
	var filter_name := filter_option.get_item_text(filter_option.selected) if filter_option and filter_option.selected >= 0 else "?꾩껜"
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var category := str(entry.get("category", "Other"))
		var is_catalog_entry := str(entry.get("owner_kind", "")) == "visual_asset"
		if filter_name == "移대떎濡쒓렇" and not is_catalog_entry:
			continue
		if filter_name != "?꾩껜" and filter_name != "移대떎濡쒓렇" and category != filter_name:
			continue
		if not query.is_empty():
			var haystack := (str(entry.get("label", "")) + " " + str(entry.get("path", "")) + " " + str(entry.get("usage", "")) + " " + str(entry.get("owner", ""))).to_lower()
			if not haystack.contains(query):
				continue
		filtered_indices.append(index)
		var icon: Texture2D = _get_catalog_thumbnail(entry) if is_catalog_entry else load(str(entry.get("path", ""))) as Texture2D
		var display_category := "移대떎濡쒓렇" if is_catalog_entry else category
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
			missing.append("%s | %s" % [str(entry.get("label", "?대?吏")), image_path])
			continue
		var texture := load(image_path) as Texture2D
		if texture == null:
			invalid.append("%s | %s" % [str(entry.get("label", "?대?吏")), image_path])
	var report := "?대?吏 李몄“ ?먭? 寃곌낵\n\n?꾩껜 李몄“: %d\n?꾨씫: %d\n濡쒕뱶 ?ㅽ뙣: %d" % [entries.size(), missing.size(), invalid.size()]
	if not missing.is_empty():
		report += "\n\n[?꾨씫???대?吏]\n" + "\n".join(missing)
	if not invalid.is_empty():
		report += "\n\n[濡쒕뱶 ?ㅽ뙣 ?대?吏]\n" + "\n".join(invalid)
	if missing.is_empty() and invalid.is_empty():
		report += "\n\n紐⑤뱺 ?곌껐 ?대?吏 李몄“媛 ?뺤긽?낅땲??"
	var dialog := AcceptDialog.new()
	dialog.title = "?대?吏 李몄“ ?먭?"
	dialog.dialog_text = report
	dialog.ok_button_text = "?リ린"
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
			entries.append({"label": "?꾧뎔 ?좊떅 / %s / %s" % [str(data[key].get("name", key)), str(animation_name)], "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "visuals.animations." + str(animation_name), "usage": "?꾧뎔 ?좊떅 %s ?좊땲硫붿씠?? % str(animation_name), "category": "Unit"})

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
			var usage := "濡쒕큸 ?湲??대?吏"
			match field:
				"sprite_attack": usage = "濡쒕큸 怨듦꺽 ?대?吏"
				"default_image": usage = "濡쒕큸 Profile Image"
				"sprite_move": usage = "濡쒕큸 ?대룞 ?대?吏"
				"sprite_skill": usage = "濡쒕큸 ?ㅽ궗 ?대?吏"
				"projectile_anim": usage = "濡쒕큸 ?ъ궗泥??대?吏"
			entries.append({"label": "濡쒕큸 / %s" % robot_name, "path": image_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": field, "usage": usage, "category": "Robot"})
		var animations: Dictionary = data[key].get("animations", {})
		if animations is Dictionary:
			for animation_name in animations:
				var animation_path := str(animations[animation_name])
				if animation_path.is_empty() or seen.has(animation_path): continue
				seen[animation_path] = true
				entries.append({"label": "濡쒕큸 / %s / %s" % [robot_name, str(animation_name)], "path": animation_path, "owner": path, "owner_kind": "json", "owner_key": str(key), "field": "animations." + str(animation_name), "usage": "濡쒕큸 %s ?좊땲硫붿씠?? % str(animation_name), "category": "Robot"})

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
		entries.append({"label": "移댄깉濡쒓렇 / %s" % str(asset.get("display_name", asset.get("asset_id", "Asset"))), "path": image_path, "owner": path, "owner_kind": "catalog", "owner_key": str(asset.get("asset_id", "")), "field": "source_path", "usage": "%s / %s" % [str(asset.get("group", "移댄깉濡쒓렇")), str(asset.get("kind", "asset"))], "category": "Map"})
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
		entries.append({"label": "?고???/ %s" % image_path.get_file(), "path": image_path, "owner": path, "owner_kind": "main", "owner_key": image_path, "field": "preload", "usage": "寃뚯엫 ?고????대?吏", "category": "Runtime"})

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
	usage_label.text = "?좏깮??Asset ?놁쓬"
	view.set_source_texture(null)
	status.text = "?대?吏 ?좏깮???댁젣?덉뒿?덈떎."

func _select_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= list.item_count: return
	var entry_index := int(list.get_item_metadata(index))
	if entry_index < 0 or entry_index >= entries.size(): return
	catalog_target_index = entry_index
	current_index = entry_index
	current_path = str(entries[entry_index].get("path", ""))
	IMAGE_STATE.open_image(current_path)
	current_image = LOADER.load_image(current_path)
	var entry: Dictionary = entries[entry_index]
	var catalog_region: Rect2i = _entry_region(entry)
	usage_label.text = "[%s] %s\nUsage: %s\nSource: %s\nOwner: %s\nField: %s" % [str(entry.get("category", "Other")), str(entry.get("label", "Asset")), str(entry.get("usage", "誘몄???)), current_path, str(entry.get("owner", "誘몄???)), str(entry.get("field", "誘몄???))]
	if current_image == null:
		status.text = "?대?吏瑜?遺덈윭?????놁뒿?덈떎: %s" % current_path
		return
	view.set_source_texture(ImageTexture.create_from_image(current_image))
	if catalog_region.size.x > 0 and catalog_region.size.y > 0:
		view.selected_region = catalog_region
		view.queue_redraw()
	status.text = "?좏깮??移대떎濡쒓렇: %s ???곸뿭 %d 횞 %d px" % [str(entry.get("label", "Asset")), catalog_region.size.x, catalog_region.size.y] if catalog_region.size.x > 0 else "?좏깮??Source: %s ??%d 횞 %d px" % [current_path, current_image.get_width(), current_image.get_height()]

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
		status.text = "?몄쭛 ????대?吏瑜?遺덈윭?????놁뒿?덈떎: %s" % path
		return
	current_index = -1
	current_path = path
	current_image = loaded
	IMAGE_STATE.open_image(path)
	list.deselect_all()
	usage_label.text = "?⑸룄: ???몄쭛 ????대?吏"
	_refresh_view()
	status.text = "???대?吏: %s ???쒕옒洹몃줈 ?곸뿭???좏깮????Visual Asset?쇰줈 ?깅줉?????덉뒿?덈떎." % path

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
		status.text = "?쇱そ ?곌껐 紐⑸줉?먯꽌 援먯껜??移댄깉濡쒓렇 ??ぉ??癒쇱? ?좏깮?섏꽭??"
		return
	if str(entries[catalog_target_index].get("path", "")) == current_path:
		status.text = "?ㅻⅨ ?대?吏瑜??몄쭛 ??곸쑝濡??댁뼱 二쇱꽭??"
		return
	if source_path == current_path:
		source_path = ""
		source_image = null
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "?몄쭛 ?대?吏瑜???ν븯吏 紐삵빐 移댄깉濡쒓렇瑜?援먯껜?????놁뒿?덈떎."
		return
	if catalog_target_index < 0 or catalog_target_index >= entries.size():
		status.text = "?쇱そ ?곌껐 紐⑸줉?먯꽌 援먯껜??移댄깉濡쒓렇 ??ぉ??癒쇱? ?좏깮?섏꽭??"
		return
	if not _replace_entry_reference(entries[catalog_target_index], output):
		status.text = "?대?吏????ν뻽吏留??좏깮 移댄깉濡쒓렇 李몄“ 援먯껜???ㅽ뙣?덉뒿?덈떎: %s" % output
		return
	current_path = output
	IMAGE_STATE.open_image(output)
	_refresh_view()
	_scan_connected_images()
	_select_path(output)
	status.text = "?좏깮 移댄깉濡쒓렇 李몄“瑜????대?吏濡?援먯껜?덉뒿?덈떎: %s" % output

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
		status.text = "癒쇱? ?대?吏?먯꽌 移댄깉濡쒓렇濡?留뚮뱾 ?곸뿭???쒕옒洹명빐???좏깮?섏꽭??"
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
		status.text = "Visual Asset Catalog ??μ뿉 ?ㅽ뙣?덉뒿?덈떎."
		return
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
		status.text = "Visual Asset ?깅줉 ?꾨즺 諛??먮옒 Editor???곸슜 以鍮? %s | ?곸뿭 %d 횞 %d px" % [asset_id, rect.size.x, rect.size.y]
		request_previous_editor.emit()
	else:
		status.text = "Visual Asset ?깅줉 ?꾨즺: %s | ?곸뿭 %d 횞 %d px" % [asset_id, rect.size.x, rect.size.y]

func _add_current_image_to_asset_catalog() -> void:
	if not _require_image():
		return
	var output := _save_current_image_copy()
	if output.is_empty():
		status.text = "??移댄깉濡쒓렇??PNG瑜???ν븯吏 紐삵뻽?듬땲??"
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
		status.text = "PNG????ν뻽吏留?Asset Catalog ??μ뿉 ?ㅽ뙣?덉뒿?덈떎: %s" % output
		return
	_scan_connected_images()
	_select_path(output)
	status.text = "??Asset Catalog ??ぉ???깅줉?덉뒿?덈떎: %s" % asset_id

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
		status.text = "??곴낵 ?ㅻⅨ ?대?吏瑜?李몄“ ?대?吏濡??좏깮?섏꽭??"
		return
	source_path = path
	source_index = -1
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "李몄“ ?대?吏瑜?遺덈윭?????놁뒿?덈떎: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "李몄“: %s ???쒕옒洹몃줈 ?곸뿭???좏깮?섏꽭??" % source_path

func _select_source_entry(index: int) -> void:
	if editing: return
	if index < 0 or index >= source_list.item_count: return
	var entry_index := int(source_list.get_item_metadata(index))
	if entry_index < 0 or entry_index >= entries.size(): return
	source_index = entry_index
	source_path = str(entries[entry_index].get("path", ""))
	if source_path == current_path:
		status.text = "??곴낵 ?ㅻⅨ ?대?吏瑜?李몄“ ?대?吏濡??좏깮?섏꽭??"
		return
	source_image = LOADER.load_image(source_path)
	if source_image == null:
		status.text = "李몄“ ?대?吏瑜?遺덈윭?????놁뒿?덈떎: %s" % source_path
		return
	view.set_source_texture(ImageTexture.create_from_image(source_image))
	status.text = "李몄“: %s ???꾩껜 ?먮뒗 ?쒕옒洹??좏깮 ?곸뿭???ъ슜?섏꽭??" % source_path

func _replace_from_source_full() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "癒쇱? ?ㅻⅨ 李몄“ ?대?吏瑜??좏깮?섏꽭??"
		return
	current_image = source_image.duplicate()
	_refresh_view()
	status.text = "李몄“ ?대?吏 ?꾩껜瑜???곸쑝濡?援먯껜?덉뒿?덈떎. ???+ ?곌껐 蹂寃쎌쓣 ?뚮윭 ?곸슜?섏꽭??"

func _apply_source_region_reference() -> void:
	if not _require_image(): return
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "癒쇱? ?ㅻⅨ 李몄“ ?대?吏瑜??닿굅???좏깮?섏꽭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "李몄“ ?대?吏?먯꽌 ?곸뿭???쒕옒洹몃줈 ?좏깮?섏꽭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	if not _save_source_reference(source_path, rect):
		status.text = "李몄“ ?대?吏 ?ㅼ젙????ν븯吏 紐삵뻽?듬땲??"
		return
	status.text = "李몄“ ?대?吏濡??ㅼ젙?덉뒿?덈떎: %s [%d, %d, %d, %d]" % [source_path, rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func _replace_from_source_region() -> void:
	if not _require_image(): return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "癒쇱? ?ㅻⅨ 李몄“ ?대?吏瑜??좏깮?섏꽭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "李몄“ ?대?吏?먯꽌 援먯껜???곸뿭???쒕옒洹몃줈 ?좏깮?섏꽭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	current_image = source_image.get_region(rect)
	_refresh_view()
	status.text = "李몄“ ?곸뿭 %d 횞 %d px濡???곸쓣 援먯껜?덉뒿?덈떎. ???+ ?곌껐 蹂寃쎌쓣 ?뚮윭 ?곸슜?섏꽭??" % [rect.size.x, rect.size.y]

func _replace_source_region_as_unit() -> void:
	if not _require_image(): return
	if current_index < 0 or current_index >= entries.size():
		status.text = "癒쇱? ?좊떅 ?먮뒗 ????대?吏瑜??좏깮?섏꽭??"
		return
	var entry: Dictionary = entries[current_index]
	var owner_path := str(entry.get("owner", ""))
	var owner_key := str(entry.get("owner_key", ""))
	if str(entry.get("owner_kind", "")) != "json" or (owner_path != "res://content/towers/towers.json" and owner_path != "res://content/allied_units/allied_units.json"):
		status.text = "?좊떅 ?먮뒗 ??뚯뿉 ?곌껐???대?吏?먯꽌 ?ъ슜?????덉뒿?덈떎."
		return
	if editing: _finish_erase()
	if source_image == null or source_path.is_empty() or source_path == current_path:
		status.text = "癒쇱? ?ㅻⅨ 李몄“ ?대?吏瑜??좏깮?섏꽭??"
		return
	var rect := view.selected_region
	if rect.size.x <= 0 or rect.size.y <= 0:
		status.text = "李몄“ ?대?吏?먯꽌 ?좊떅?쇰줈 ?ъ슜???곸뿭???쒕옒洹몃줈 ?좏깮?섏꽭??"
		return
	rect = rect.intersection(Rect2i(0, 0, source_image.get_width(), source_image.get_height()))
	if rect.size.x <= 0 or rect.size.y <= 0: return
	var region := source_image.get_region(rect)
	var frame_size := Vector2i(60, 90)
	var frame_count := 4
	var unit_label := "???
	if owner_path == "res://content/allied_units/allied_units.json":
		var sizes := {"basic": Vector2i(60, 90), "light": Vector2i(60, 90), "ranged": Vector2i(60, 90), "heavy": Vector2i(72, 96), "support": Vector2i(72, 96)}
		frame_size = sizes.get(owner_key, Vector2i(60, 90))
		frame_count = 8
		unit_label = "?좊떅"
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
	status.text = "%s??%d?꾨젅??%d 횞 %d px濡??뺢퇋?뷀뻽?듬땲?? ???+ ?곌껐 蹂寃쎌쓣 ?뚮윭 ?곸슜?섏꽭??" % [unit_label, frame_count, sheet.get_width(), sheet.get_height()]

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
	status.text = "%s ??%d 횞 %d px" % [current_path, current_image.get_width(), current_image.get_height()]
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
	# ???+ ?곌껐 蹂寃쎌쑝濡????몄쭛 PNG???곌껐???뚮뒗 ?댁쟾 李몄“ ?곸뿭???쒓굅?쒕떎.
	# ??PNG ?먯껜媛 援먯껜 寃곌낵臾쇱씠誘濡??꾩껜 ?대?吏瑜??ъ슜?댁빞 ?쒕떎.
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

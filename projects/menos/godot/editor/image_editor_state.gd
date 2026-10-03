class_name ImageEditorState
extends RefCounted

static var selected_path := ""
static var selection_asset_id := ""
static var selection_target := ""
static var selection_pending := false

static func open_image(path: String, target: String = "", asset_id: String = "") -> void:
	selected_path = path
	selection_asset_id = asset_id
	selection_target = target
	selection_pending = not target.is_empty()

static func apply_selection(value: String = "") -> void:
	if not value.is_empty():
		selection_asset_id = value
		selected_path = value
	selection_pending = true

static func consume_selection(target: String) -> String:
	if not selection_pending or selection_target != target:
		return ""
	var result := selection_asset_id
	if result.is_empty():
		result = selected_path
	selection_pending = false
	selection_target = ""
	selection_asset_id = ""
	return result

static func cancel_selection() -> void:
	selection_target = ""
	selection_asset_id = ""
	selection_pending = false

static func clear() -> void:
	selected_path = ""
	selection_asset_id = ""
	selection_target = ""
	selection_pending = false

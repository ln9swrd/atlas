class_name ImageEditorState
extends RefCounted

static var selected_path := ""
static var selection_asset_id := ""
static var selection_target := ""
static var selection_owner_kind := ""
static var selection_owner_key := ""
static var selection_usage := ""
static var selection_frames := 1
static var selection_pending := false

static func open_image(path: String, target: String = "", asset_id: String = "", owner_kind: String = "", owner_key: String = "", usage: String = "", frames: int = 1) -> void:
	selected_path = path
	selection_asset_id = asset_id
	selection_target = target
	selection_owner_kind = owner_kind
	selection_owner_key = owner_key
	selection_usage = usage
	selection_frames = maxi(1, frames)
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
	selection_owner_kind = ""
	selection_owner_key = ""
	selection_usage = ""
	selection_frames = 1
	return result

static func cancel_selection() -> void:
	selection_target = ""
	selection_asset_id = ""
	selection_pending = false

static func clear() -> void
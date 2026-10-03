class_name ImageEditorState
extends RefCounted

static var selected_path := ""
static var selection_target := ""
static var selection_pending := false

static func open_image(path: String, target: String = "") -> void:
	selected_path = path
	selection_target = target
	selection_pending = not target.is_empty()

static func apply_selection(path: String = "") -> void:
	if not path.is_empty():
		selected_path = path
	selection_pending = true

static func consume_selection(target: String) -> String:
	if not selection_pending or selection_target != target:
		return ""
	var result := selected_path
	selection_pending = false
	selection_target = ""
	return result

static func cancel_selection() -> void:
	selection_target = ""
	selection_pending = false

static func clear() -> void:
	selected_path = ""
	selection_target = ""
	selection_pending = false

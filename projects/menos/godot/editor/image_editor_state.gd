class_name ImageEditorState
extends RefCounted

static var selected_path := ""

static func open_image(path: String) -> void:
	selected_path = path

static func clear() -> void:
	selected_path = ""

class_name ObjectPersistence
extends RefCounted

static func load_catalog(path: String) -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(path)

static func save_catalog(path: String, catalog: Dictionary) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	var parent_dir := absolute_path.get_base_dir()
	var dir_error := DirAccess.make_dir_recursive_absolute(parent_dir)
	if dir_error != OK:
		push_error("ObjectPersistence: failed to create directory: %s" % error_string(dir_error))
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ObjectPersistence: failed to open for writing: %s" % path)
		return false
	var json_text := JSON.stringify(catalog, "  ")
	file.store_string(json_text)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("ObjectPersistence: failed to write %s" % path)
		return false
	return _verify_text(path, json_text)

static func _verify_text(path: String, expected_text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ObjectPersistence: failed to reopen for verification: %s" % path)
		return false
	var actual_text := file.get_as_text()
	file.close()
	return actual_text.strip_edges() == expected_text.strip_edges()

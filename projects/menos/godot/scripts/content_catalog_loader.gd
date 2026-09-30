class_name ContentCatalogLoader
extends RefCounted

static func load_dictionary_catalog(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("ContentCatalogLoader: file not found: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ContentCatalogLoader: failed to open: %s" % path)
		return {}
	var json := JSON.new()
	var result: Error = json.parse(file.get_as_text())
	file.close()
	if result != OK or not (json.get_data() is Dictionary):
		push_error("ContentCatalogLoader: invalid JSON object: %s" % path)
		return {}
	var data: Dictionary = json.get_data()
	var catalog: Dictionary = {}
	for key in data.keys():
		if data[key] is Dictionary:
			catalog[str(key)] = data[key].duplicate(true)
	return catalog

static func load_single_entry(path: String, entry_id: String) -> Dictionary:
	var catalog := load_dictionary_catalog(path)
	if not catalog.has(entry_id):
		push_error("ContentCatalogLoader: entry '%s' not found in %s" % [entry_id, path])
		return {}
	return catalog[entry_id].duplicate(true)
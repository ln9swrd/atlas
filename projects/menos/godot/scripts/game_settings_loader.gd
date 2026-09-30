class_name GameSettingsLoader
extends RefCounted

static func load_gameplay() -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog("res://content/settings/gameplay.json")

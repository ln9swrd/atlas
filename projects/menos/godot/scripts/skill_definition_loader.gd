class_name SkillDefinitionLoader
extends RefCounted

static func load_catalog() -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog("res://content/skills/skills.json")

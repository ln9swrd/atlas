class_name GameSettingsLoader
extends RefCounted

const GAMEPLAY_PATH := "res://content/settings/gameplay.json"

static func load_gameplay() -> Dictionary:
	return ConfigRepository.load_dictionary(GAMEPLAY_PATH)

class_name GameSettingsLoader
extends RefCounted

const GAMEPLAY_PATH := "gameplay"

static func load_gameplay() -> Dictionary:
	return ConfigRepository.load_dictionary(GAMEPLAY_PATH)

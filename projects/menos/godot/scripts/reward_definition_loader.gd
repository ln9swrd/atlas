class_name RewardDefinitionLoader
extends RefCounted

const CATALOG_PATH := "rewards"

static func load_catalog() -> Dictionary:
	return ContentCatalogLoader.load_dictionary_catalog(CATALOG_PATH)

static func load_definition(reward_id: String) -> RewardDefinition:
	var catalog := load_catalog()
	if not catalog.has(reward_id):
		push_error("RewardDefinitionLoader: reward '%s' not found." % reward_id)
		return null
	return RewardDefinition.from_dict(catalog[reward_id], reward_id)

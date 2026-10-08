extends SceneTree

func _init() -> void:
	var errors: Array[String] = []
	var catalog = BGMDefinitionLoader.load_catalog()
	if catalog.is_empty():
		errors.append("BGM catalog is empty")
	var d = BGMDefinitionRepository.get_definition("FACTION_01_COMBAT")
	if d == null:
		errors.append("FACTION_01_COMBAT missing")
	else:
		var adapter = BGMRuntimeAdapter.new()
		adapter.configure(d)
		if not adapter.is_valid():
			errors.append("BGM definition invalid")
		if adapter.resolve_stream() == null:
			errors.append("BGM stream unresolved")
	if errors.is_empty():
		print("BGM_DEFINITION_ADAPTER_PASS")
		quit(0)
	else:
		for e in errors:
			push_error(e)
		print("BGM_DEFINITION_ADAPTER_FAIL errors=%d" % errors.size())
		quit(1)

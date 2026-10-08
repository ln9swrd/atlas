extends SceneTree

func _init() -> void:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var catalog = BGMDefinitionLoader.load_catalog()
	if catalog.size() != 4:
		errors.append("Expected 4 BGM pilot definitions, got %d" % catalog.size())
	BGMValidator.validate_catalog(errors, warnings)
	if errors.is_empty():
		print("BGM_VALIDATION_PASS warnings=%d" % warnings.size())
		quit(0)
	else:
		for e in errors:
			push_error(e)
		print("BGM_VALIDATION_FAIL errors=%d" % errors.size())
		quit(1)

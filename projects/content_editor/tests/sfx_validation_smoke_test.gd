extends SceneTree

const SFXValidatorScript = preload("res://editor/sfx_validator.gd")

func _init() -> void:
	var errors: Array = []
	var warnings: Array = []
	SFXValidatorScript.validate_catalog(errors, warnings)
	if not errors.is_empty():
		print("SFX_VALIDATION_FAIL errors=%d" % errors.size())
		for error in errors:
			print(error)
		quit(1)
		return
	print("SFX_VALIDATION_PASS warnings=%d" % warnings.size())
	quit(0)

extends SceneTree

func _init() -> void:
	var validator_script = load("res://editor/vfx_validator.gd")
	if validator_script == null:
		print("VFX_VALIDATOR_SMOKE_FAIL load")
		quit(1)
		return
	var validator = validator_script.new()
	var errors: Array[String] = []
	var warnings: Array[String] = []
	validator.validate_vfx_catalog(errors, warnings)
	print("VFX_VALIDATOR_RESULT errors=%d warnings=%d" % [errors.size(), warnings.size()])
	for error in errors:
		print("VFX_VALIDATOR_ERROR " + str(error))
	if errors.is_empty():
		print("VFX_VALIDATOR_SMOKE_PASS")
		quit(0)
	else:
		print("VFX_VALIDATOR_SMOKE_FAIL")
		quit(1)

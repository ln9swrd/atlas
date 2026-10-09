extends SceneTree

func _init() -> void:
	var validator_script = load("res://editor/content_validator.gd")
	if validator_script == null:
		print("CONTENT_VALIDATION_VFX_FAIL validator_load")
		quit(1)
		return
	var validator = validator_script.new()
	var result: Dictionary = validator.run()
	print("CONTENT_VALIDATION_VFX_RESULT valid=%s errors=%d warnings=%d" % [str(result.get("valid", false)), result.get("errors", []).size(), result.get("warnings", []).size()])
	for error in result.get("errors", []):
		print("CONTENT_VALIDATION_ERROR " + str(error))
	if bool(result.get("valid", false)):
		print("CONTENT_VALIDATION_VFX_PASS")
		quit(0)
	else:
		print("CONTENT_VALIDATION_VFX_FAIL")
		quit(1)

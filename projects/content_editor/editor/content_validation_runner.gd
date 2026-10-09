extends SceneTree

const VALIDATOR_SCRIPT = preload("res://editor/content_validator.gd")

func _init() -> void:
	var validator = VALIDATOR_SCRIPT.new()
	var result: Dictionary = validator.run()
	for warning in result.get("warnings", []):
		print("WARNING: ", warning)
	for error in result.get("errors", []):
		push_error(error)
	if bool(result.get("valid", false)):
		print("CONTENT_VALIDATION PASS")
	else:
		print("CONTENT_VALIDATION FAIL")
	quit(0 if bool(result.get("valid", false)) else 1)

extends SceneTree
const DefinitionScript=preload("res://scripts/voice_definition.gd")
const ValidatorScript=preload("res://editor/voice_validator.gd")
func _init():
	var d=DefinitionScript.from_dict({"id":"DIALOGUE_FACTION_01_CHARACTER_01_ATTACK_01_KO","dialogue_id":"DIALOGUE_FACTION_01_CHARACTER_01_ATTACK_01","voice_profile_id":"FACTION_01_CHARACTER_01_KO","language":"ko","bus":"Master","status":"Draft"})
	var errors:Array=[]; var warnings:Array=[]
	ValidatorScript.validate_definition(d,errors,warnings)
	if not errors.is_empty(): print("VOICE_VALIDATION_FAIL ",errors); quit(1); return
	print("VOICE_VALIDATION_PASS warnings=%d"%warnings.size()); quit(0)

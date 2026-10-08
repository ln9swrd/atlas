extends SceneTree
const RepositoryScript=preload("res://scripts/voice_definition_repository.gd")
const DefinitionScript=preload("res://scripts/voice_definition.gd")
func _init():
	var id="VOICE_PILOT_FACTION_01_ATTACK_01_KO"
	var d=DefinitionScript.from_dict({"id":id,"dialogue_id":"DIALOGUE_FACTION_01_CHARACTER_01_ATTACK_01","voice_profile_id":"FACTION_01_CHARACTER_01_KO","language":"ko","bus":"Master","status":"Draft"})
	if not RepositoryScript.save_definition(d): print("VOICE_REPOSITORY_SAVE_FAIL"); quit(1); return
	RepositoryScript.reload()
	if RepositoryScript.get_definition(id)==null: print("VOICE_REPOSITORY_RELOAD_FAIL"); quit(1); return
	if not RepositoryScript.delete_definition(id): print("VOICE_REPOSITORY_DELETE_FAIL"); quit(1); return
	print("VOICE_REPOSITORY_PASS"); quit(0)

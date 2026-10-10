extends SceneTree

const TEST_DB_PATH := "user://reference_safety_smoke.sqlite"
const MISSION_SCENE := preload("res://editor/mission_editor.tscn")
const FACTION_SCENE := preload("res://editor/faction_editor.tscn")
const SKILL_SCENE := preload("res://editor/skill_editor.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var source_path := ProjectSettings.globalize_path("res://data/content_editor.sqlite")
	var test_path := ProjectSettings.globalize_path(TEST_DB_PATH)
	if not _check(DirAccess.copy_absolute(source_path, test_path) == OK, "Could not create disposable authoring DB copy"):
		quit(1)
		return
	ContentCatalogLoader.set_database_path_for_tests(TEST_DB_PATH)
	ObjectPersistence.set_database_path_for_tests(TEST_DB_PATH)

	var mission = MISSION_SCENE.instantiate()
	root.add_child(mission)
	await process_frame
	mission.selected_id = "mission_stage_01"
	mission.id_edit.text = "renamed_mission"
	mission.title_edit.text = "Should not save"
	mission._save_mission()
	_check(str(mission.status_label.text).contains("ID rename is not supported"), "Mission ID rename was not rejected")
	_check(mission.catalog.has("mission_stage_01") and not mission.catalog.has("renamed_mission"), "Mission ID rename changed catalog keys")
	_check(mission._is_mission_referenced("mission_stage_01"), "Referenced mission was not protected from deletion")

	var faction = FACTION_SCENE.instantiate()
	root.add_child(faction)
	await process_frame
	faction.selected_id = "FACTION_01"
	faction.id_edit.text = "renamed_faction"
	faction.name_edit.text = "Should not save"
	faction._save_faction()
	_check(str(faction.status_label.text).contains("ID rename is not supported"), "Faction ID rename was not rejected")
	_check(faction.catalog.has("FACTION_01") and not faction.catalog.has("renamed_faction"), "Faction ID rename changed catalog keys")
	_check(faction._is_faction_referenced("FACTION_01"), "Referenced faction was not protected from deletion")

	var skill = SKILL_SCENE.instantiate()
	root.add_child(skill)
	await process_frame
	skill.selected_id = "area_attack"
	skill.id_edit.text = "renamed_skill"
	skill.name_edit.text = "Should not save"
	skill._save_skill()
	_check(str(skill.status_label.text).contains("ID rename is not supported"), "Skill ID rename was not rejected")
	_check(skill.catalog.has("area_attack") and not skill.catalog.has("renamed_skill"), "Skill ID rename changed catalog keys")
	_check(skill._is_skill_referenced("area_attack"), "Referenced skill was not protected from deletion")
	_check(not skill._is_skill_referenced("base_special"), "Unreferenced skill was incorrectly blocked by the current valid skill-slot data")
	_check(skill._skill_slots_reference_skill({}, "base_special"), "Missing skill slots did not fail closed")
	_check(skill._skill_slots_reference_skill({"test_slot": "10"}, "area_attack"), "Numeric-string ODB reference was not recognized")
	_check(skill._skill_slots_reference_skill({"test_slot": 10}, "area_attack"), "Numeric ODB reference was not recognized")

	if failures.is_empty():
		print("REFERENCE_SAFETY_PASS id_rename=3 reference_guards=3")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("REFERENCE_SAFETY_FAIL count=%d" % failures.size())
		quit(1)

func _check(condition: bool, message: String) -> bool:
	if not condition:
		failures.append(message)
	return condition

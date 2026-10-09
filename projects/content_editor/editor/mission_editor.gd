extends Control

signal request_content_editor

var catalog: Dictionary = {}
var selected_id := ""
@onready var mission_list: ItemList = $MainLayout/Body/MissionList
@onready var id_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/IdEdit
@onready var title_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/TitleEdit
@onready var briefing_edit: TextEdit = $MainLayout/Body/EditorPanel/Fields/BriefingEdit
@onready var type_option: OptionButton = $MainLayout/Body/EditorPanel/Fields/TypeOption
@onready var target_edit: LineEdit = $MainLayout/Body/EditorPanel/Fields/TargetEdit
@onready var time_spin: SpinBox = $MainLayout/Body/EditorPanel/Fields/TimeSpin
@onready var status_label: Label = $MainLayout/Status

const MISSION_TYPES := ["defend_base", "clear_encounters", "defeat_giant"]
const CORE_MISSIONS := [
	{"id":"mission_01_base_defense","title":"거점 방어","briefing":"지정된 거점을 방어하고 적의 공격을 저지합니다.","primary_type":"defend_base"},
	{"id":"mission_02_hold_line","title":"전선 유지","briefing":"제한 시간 동안 방어선을 유지합니다.","primary_type":"defend_base"},
	{"id":"mission_03_boss_elimination","title":"보스 격파","briefing":"전장에 등장한 핵심 적을 격파합니다.","primary_type":"defeat_giant"},
	{"id":"mission_04_elite_intercept","title":"엘리트 요격","briefing":"목표로 지정된 강력한 적을 우선 격파합니다.","primary_type":"defeat_giant"},
	{"id":"mission_05_breakthrough","title":"돌파 작전","briefing":"적의 저항을 돌파하고 작전 구역을 확보합니다.","primary_type":"clear_encounters"},
	{"id":"mission_06_evacuation_escape","title":"구출·탈출","briefing":"작전 구역의 목표를 확보하고 탈출 작전을 완료합니다.","primary_type":"clear_encounters"},
	{"id":"mission_07_escort_convoy","title":"호위·수송","briefing":"호위 대상의 생존을 유지하며 작전을 완료합니다.","primary_type":"defend_base"},
	{"id":"mission_08_stealth_infiltration","title":"잠입·회피","briefing":"불필요한 교전을 피하고 지정 구역에 침투합니다.","primary_type":"clear_encounters"},
	{"id":"mission_09_sabotage","title":"시설 파괴·교란","briefing":"지정된 시설 또는 작전 목표를 무력화합니다.","primary_type":"clear_encounters"},
	{"id":"mission_10_multi_objective","title":"다중 목표 작전","briefing":"여러 작전 목표를 순서에 맞게 처리합니다.","primary_type":"clear_encounters"},
	{"id":"mission_11_pursuit","title":"추격·탈출전","briefing":"추격 상황에서 목표를 따라잡거나 지정 지점까지 탈출합니다.","primary_type":"clear_encounters"},
	{"id":"mission_12_survival","title":"생존·자원 관리","briefing":"제한된 시간과 전투 자원을 관리하며 생존합니다.","primary_type":"defend_base"},
	{"id":"mission_13_story_choice","title":"서사·선택 작전","briefing":"작전 목표를 수행하고 스토리 선택에 따른 결과를 결정합니다.","primary_type":"clear_encounters"}
]

func _ready() -> void:
	for value in MISSION_TYPES:
		type_option.add_item(value)
	$MainLayout/Body/EditorPanel/Fields/Buttons/NewButton.pressed.connect(_new_mission)
	$MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save_mission)
	$MainLayout/Body/EditorPanel/Fields/Buttons/DeleteButton.pressed.connect(_delete_mission)
	mission_list.item_selected.connect(_select_mission)
	_load_catalog()
	_register_core_missions_if_missing()
	_load_catalog()
	_clear_editor()
	_refresh_list()

func _register_core_missions_if_missing() -> void:
	var changed := false
	for definition in CORE_MISSIONS:
		var mission_id := str(definition["id"])
		if not catalog.has(mission_id):
			var data: Dictionary = definition.duplicate(true)
			data["target_id"] = ""
			data["time_limit"] = 0
			catalog[mission_id] = data
			changed = true
	if changed:
		if ObjectPersistence.save_catalog("missions", catalog):
			status_label.text = "Registered missing core missions; existing definitions preserved."
		else:
			status_label.text = "ERROR: failed to register core missions in Content Editor SQLite."

func _load_catalog() -> void:
	catalog = ContentCatalogLoader.load_dictionary_catalog("missions")
	if catalog.is_empty():
		catalog = {}

func _refresh_list() -> void:
	mission_list.clear()
	var ids: Array[String] = []
	for key in catalog.keys():
		ids.append(str(key))
	ids.sort()
	for mission_id in ids:
		var data: Dictionary = catalog.get(mission_id, {})
		mission_list.add_item("%s  [%s]" % [str(data.get("title", mission_id)), mission_id])
		mission_list.set_item_metadata(mission_list.item_count - 1, mission_id)

func _select_mission(index: int) -> void:
	var mission_id := str(mission_list.get_item_metadata(index))
	var data: Dictionary = catalog.get(mission_id, {})
	selected_id = mission_id
	id_edit.text = mission_id
	title_edit.text = str(data.get("title", ""))
	briefing_edit.text = str(data.get("briefing", ""))
	var type_index := MISSION_TYPES.find(str(data.get("primary_type", "clear_encounters")))
	type_option.select(type_index if type_index >= 0 else 1)
	target_edit.text = str(data.get("target_id", ""))
	time_spin.value = max(0, int(data.get("time_limit", 0)))
	status_label.text = "Loaded: %s" % mission_id

func _clear_editor() -> void:
	selected_id = ""
	id_edit.text = ""
	title_edit.text = ""
	briefing_edit.text = ""
	type_option.select(1)
	target_edit.text = ""
	time_spin.value = 0

func _new_mission() -> void:
	_clear_editor()
	id_edit.grab_focus()
	status_label.text = "New mission"

func _save_mission() -> void:
	var mission_id := id_edit.text.strip_edges()
	if mission_id.is_empty() or title_edit.text.strip_edges().is_empty():
		status_label.text = "ERROR: mission ID and title are required"
		return
	if not selected_id.is_empty() and mission_id != selected_id:
		status_label.text = "ERROR: mission ID rename is not supported; create a new mission"
		return
	if selected_id.is_empty() and catalog.has(mission_id):
		status_label.text = "ERROR: mission ID already exists; select it to edit"
		return
	var data: Dictionary = {}
	if selected_id != "" and catalog.get(selected_id, {}) is Dictionary:
		data = (catalog[selected_id] as Dictionary).duplicate(true)
	data["id"] = mission_id
	data["title"] = title_edit.text.strip_edges()
	data["briefing"] = briefing_edit.text.strip_edges()
	data["primary_type"] = str(type_option.get_item_text(type_option.selected))
	data["target_id"] = target_edit.text.strip_edges()
	data["time_limit"] = int(time_spin.value)
	catalog[mission_id] = data
	if not ObjectPersistence.save_catalog("missions", catalog):
		status_label.text = "ERROR: SQLite save failed"
		return
	_load_catalog()
	_refresh_list()
	selected_id = mission_id
	status_label.text = "Saved to SQLite: %s" % mission_id

func _delete_mission() -> void:
	if selected_id.is_empty():
		status_label.text = "ERROR: select a mission"
		return
	if _is_mission_referenced(selected_id):
		status_label.text = "ERROR: mission is referenced by a stage and cannot be deleted"
		return
	catalog.erase(selected_id)
	if not ObjectPersistence.save_catalog("missions", catalog):
		status_label.text = "ERROR: SQLite delete failed"
		return
	var deleted_id := selected_id
	_load_catalog()
	_refresh_list()
	_clear_editor()
	status_label.text = "Deleted from SQLite: %s" % deleted_id

func _is_mission_referenced(mission_id: String) -> bool:
	var stage_catalog := ContentCatalogLoader.load_document("stage_catalog")
	var stage_ids = stage_catalog.get("stages", [])
	if not (stage_ids is Array) or stage_ids.is_empty():
		return true
	for stage_id_value in stage_ids:
		var stage_path := StageLoader.resolve_stage_path(str(stage_id_value))
		var stage := ContentCatalogLoader.load_document(stage_path)
		if stage.is_empty():
			return true
		var reference = stage.get("mission_id", "")
		if str(reference) == mission_id:
			return true
		if reference is int or reference is float:
			if ContentCatalogLoader.resolve_odb_pk("mission", int(reference)) == mission_id:
				return true
	return false

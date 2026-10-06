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
func _ready() -> void:
	for value in MISSION_TYPES: type_option.add_item(value)
	$MainLayout/Body/EditorPanel/Fields/Buttons/NewButton.pressed.connect(_new_mission)
	$MainLayout/Body/EditorPanel/Fields/Buttons/SaveButton.pressed.connect(_save_mission)
	$MainLayout/Body/EditorPanel/Fields/Buttons/DeleteButton.pressed.connect(_delete_mission)
	mission_list.item_selected.connect(_select_mission)
	_load_catalog(); _clear_editor(); _refresh_list()
func _load_catalog() -> void:
	catalog = ContentCatalogLoader.load_dictionary_catalog("missions")
	if catalog.is_empty(): catalog = {}
func _refresh_list() -> void:
	mission_list.clear()
	var ids: Array[String] = []
	for key in catalog.keys(): ids.append(str(key))
	ids.sort()
	for mission_id in ids:
		var data: Dictionary = catalog.get(mission_id, {})
		mission_list.add_item("%s  [%s]" % [str(data.get("title", mission_id)), mission_id])
		mission_list.set_item_metadata(mission_list.item_count - 1, mission_id)
func _select_mission(index: int) -> void:
	var mission_id := str(mission_list.get_item_metadata(index)); var data: Dictionary = catalog.get(mission_id, {})
	selected_id = mission_id; id_edit.text = mission_id; title_edit.text = str(data.get("title", "")); briefing_edit.text = str(data.get("briefing", ""))
	var type_index := MISSION_TYPES.find(str(data.get("primary_type", "clear_encounters"))); type_option.select(type_index if type_index >= 0 else 1)
	target_edit.text = str(data.get("target_id", "")); time_spin.value = max(0, int(data.get("time_limit", 0))); status_label.text = "Loaded: %s" % mission_id
func _clear_editor() -> void:
	selected_id = ""; id_edit.text = ""; title_edit.text = ""; briefing_edit.text = ""; type_option.select(1); target_edit.text = ""; time_spin.value = 0
func _new_mission() -> void:
	_clear_editor(); id_edit.grab_focus(); status_label.text = "New mission"
func _save_mission() -> void:
	var mission_id := id_edit.text.strip_edges()
	if mission_id.is_empty() or title_edit.text.strip_edges().is_empty(): status_label.text = "ERROR: mission ID and title are required"; return
	var data: Dictionary = {}
	if selected_id != "" and catalog.get(selected_id, {}) is Dictionary: data = (catalog[selected_id] as Dictionary).duplicate(true)
	data["id"] = mission_id; data["title"] = title_edit.text.strip_edges(); data["briefing"] = briefing_edit.text.strip_edges(); data["primary_type"] = str(type_option.get_item_text(type_option.selected)); data["target_id"] = target_edit.text.strip_edges(); data["time_limit"] = int(time_spin.value)
	if selected_id != "" and selected_id != mission_id: catalog.erase(selected_id)
	catalog[mission_id] = data
	if not ObjectPersistence.save_catalog("missions", catalog): status_label.text = "ERROR: SQLite save failed"; return
	_load_catalog(); _refresh_list(); selected_id = mission_id; status_label.text = "Saved to SQLite: %s" % mission_id
func _delete_mission() -> void:
	if selected_id.is_empty(): status_label.text = "ERROR: select a mission"; return
	catalog.erase(selected_id)
	if not ObjectPersistence.save_catalog("missions", catalog): status_label.text = "ERROR: SQLite delete failed"; return
	var deleted_id := selected_id; _load_catalog(); _refresh_list(); _clear_editor(); status_label.text = "Deleted from SQLite: %s" % deleted_id

\n
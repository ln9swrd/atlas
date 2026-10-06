class_name StageEditorMain
extends Control

signal request_map_editor_for_path(map_path: String)

const STAGE_DIR := ""
const STAGE_CATALOG_FILE := "stage_catalog"
const MISSION_CATALOG_FILE := "missions"
const REWARD_CATALOG_FILE := "rewards"
const MAP_DIR := ""
const ASSET_CATALOG_FILE := "asset_catalog"
const LANES := ["left", "right", "both"]
var current_path := ""
var stage_data: Dictionary = {}
var stage_list: OptionButton
var id_edit: LineEdit
var order_spin: SpinBox
var name_edit: LineEdit
var map_option: OptionButton
var gold_spin: SpinBox
var hp_spin: SpinBox
var next_edit: LineEdit
var mission_id_edit: LineEdit
var mission_title_edit: LineEdit
var mission_briefing_edit: TextEdit
var mission_type_option: OptionButton
var mission_target_edit: LineEdit
var mission_time_spin: SpinBox
var reward_id_edit: LineEdit
var reward_gold_spin: SpinBox
var reward_item_ids_edit: LineEdit
var map_open_button: Button
var map_preview_container: SubViewportContainer
var map_preview_viewport: SubViewport
var map_preview_canvas: EditorCanvas
var map_preview_status: Label
var enemy_types: Array = []
var map_preview_assets: Array[Dictionary] = []
var encounters_box: VBoxContainer
var status_label: Label

func _ready() -> void:
	enemy_types = ContentCatalogLoader.load_dictionary_catalog("enemies").keys()
	enemy_types.sort()
	_build_ui()
	_refresh_stage_list()
	if stage_list.item_count > 0:
		stage_list.select(0)
		_load_selected_stage()

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	add_child(root)
	var title := Label.new()
	title.text = "MENOS // STAGE EDITOR"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	stage_list = OptionButton.new()
	stage_list.custom_minimum_size.x = 220
	stage_list.item_selected.connect(_on_stage_selected)
	top.add_child(stage_list)
	var load_btn := Button.new()
	load_btn.text = "Reload"
	load_btn.pressed.connect(_load_selected_stage)
	top.add_child(load_btn)
	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_save_stage)
	top.add_child(save_btn)
	var delete_btn := Button.new()
	delete_btn.text = "Delete Stage"
	delete_btn.pressed.connect(_confirm_delete_stage)
	top.add_child(delete_btn)
	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(status_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	_build_stage_properties(content)
	content.add_child(HSeparator.new())
	var t := Label.new()
	t.text = "Encounters"
	t.add_theme_font_size_override("font_size", 16)
	content.add_child(t)
	encounters_box = VBoxContainer.new()
	encounters_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(encounters_box)
	var add_encounter := Button.new()
	add_encounter.text = "+ Add Encounter"
	add_encounter.pressed.connect(_add_encounter)
	content.add_child(add_encounter)

func _build_stage_properties(parent: VBoxContainer) -> void:
	id_edit = _line_row(parent, "Stage ID")
	order_spin = _spin_row(parent, "Order", 1, 999, 1, 1)
	name_edit = _line_row(parent, "Name")

	var map_row := HBoxContainer.new()
	parent.add_child(map_row)
	var map_label := Label.new()
	map_label.text = "사용 맵"
	map_label.custom_minimum_size.x = 130
	map_row.add_child(map_label)
	map_option = OptionButton.new()
	map_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_row.add_child(map_option)
	map_open_button = Button.new()
	map_open_button.text = "맵 편집"
	map_open_button.tooltip_text = "현재 선택된 맵을 맵 에디터에서 엽니다."
	map_open_button.pressed.connect(_open_selected_map)
	map_row.add_child(map_open_button)
	map_option.item_selected.connect(_on_map_option_selected)

	var preview_label := Label.new()
	preview_label.text = "연결된 맵 미리보기"
	preview_label.add_theme_font_size_override("font_size", 14)
	parent.add_child(preview_label)
	map_preview_container = SubViewportContainer.new()
	map_preview_container.custom_minimum_size = Vector2(0, 240)
	map_preview_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_preview_container.stretch = true
	parent.add_child(map_preview_container)
	map_preview_viewport = SubViewport.new()
	map_preview_viewport.size = Vector2i(480, 240)
	map_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	map_preview_viewport.transparent_bg = false
	map_preview_container.add_child(map_preview_viewport)
	map_preview_canvas = EditorCanvas.new()
	map_preview_canvas.set_process_input(false)
	map_preview_viewport.add_child(map_preview_canvas)
	map_preview_status = Label.new()
	map_preview_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_preview_status.modulate = Color("9fb2aa")
	parent.add_child(map_preview_status)

	var relation := Label.new()
	relation.text = "Stage → Map: 스테이지가 이 맵을 사용합니다. 맵을 여러 스테이지에서 재사용할 수 있습니다."
	relation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relation.modulate = Color("9fb2aa")
	parent.add_child(relation)

	gold_spin = _spin_row(parent, "Initial Gold", 0, 999999, 10, 180)
	hp_spin = _spin_row(parent, "Base HP", 1, 999999, 10, 100)

	parent.add_child(HSeparator.new())
	var mission_header := Label.new()
	mission_header.text = "Mission / 미션"
	mission_header.add_theme_font_size_override("font_size", 16)
	parent.add_child(mission_header)

	mission_id_edit = _line_row(parent, "Mission ID")
	mission_title_edit = _line_row(parent, "미션 제목")
	var briefing_row := VBoxContainer.new()
	parent.add_child(briefing_row)
	var briefing_label := Label.new()
	briefing_label.text = "미션 설명"
	briefing_row.add_child(briefing_label)
	mission_briefing_edit = TextEdit.new()
	mission_briefing_edit.custom_minimum_size.y = 90
	mission_briefing_edit.placeholder_text = "플레이어에게 표시할 임무 설명"
	briefing_row.add_child(mission_briefing_edit)

	mission_type_option = OptionButton.new()
	for value in ["defend_base", "clear_encounters", "defeat_giant"]:
		mission_type_option.add_item(value)
	_option_row(parent, "주 임무 유형", mission_type_option)
	mission_target_edit = _line_row(parent, "대상 ID")
	mission_time_spin = _spin_row(parent, "제한 시간(초)", 0, 86400, 1, 0)

	reward_id_edit = _line_row(parent, "Reward ID")
	reward_gold_spin = _spin_row(parent, "Reward Gold", 0, 999999999, 1, 0)
	reward_item_ids_edit = _line_row(parent, "Reward Item IDs")
	reward_item_ids_edit.placeholder_text = "예: weapon, armor (쉼표로 구분)"

	var reward_note := Label.new()
	reward_note.text = "보상은 Stage 완료 시 영구 Profile에 지급됩니다. Item ID는 Item Catalog의 base_id를 사용합니다."
	reward_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reward_note.modulate = Color("9fb2aa")
	parent.add_child(reward_note)

	var mission_note := Label.new()
	mission_note.text = "현재 Runtime이 실제 판정하는 기본 조건은 HQ 파괴 시 패배와 전체 Encounter 종료 시 클리어입니다. 위 설정은 Stage의 미션 정의를 저장합니다."
	mission_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_note.modulate = Color("9fb2aa")
	parent.add_child(mission_note)

func _line_row(parent: VBoxContainer, label_text: String) -> LineEdit:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	return edit

func _spin_row(parent: VBoxContainer, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step
	spin.value = value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spin)
	return spin

func _option_row(parent: VBoxContainer, label_text: String, option: OptionButton) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 130
	row.add_child(label)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(option)

func _refresh_stage_list() -> void:
	stage_list.clear()
	var catalog := ContentCatalogLoader.load_document(STAGE_CATALOG_FILE)
	for stage_id in catalog.get("stages", []):
		var id := str(stage_id)
		stage_list.add_item(id)
		stage_list.set_item_metadata(stage_list.item_count - 1, id)

func _refresh_map_options(selected_path: String) -> void:
	map_option.clear()
	var paths := MapLoader.list_map_paths()
	var selected := 0
	for path in paths:
		var f := path.get_file()
		map_option.add_item(f)
		map_option.set_item_metadata(map_option.item_count - 1, path)
		if path == selected_path: selected = map_option.item_count - 1
	if map_option.item_count > 0:
		map_option.select(selected)
	_refresh_map_preview(selected_path)

func _on_map_option_selected(index: int) -> void:
	if index < 0 or index >= map_option.item_count:
		_refresh_map_preview("")
		return
	_refresh_map_preview(str(map_option.get_item_metadata(index)))

func _load_map_preview_assets() -> void:
	map_preview_assets.clear()
	var parsed: Variant = ContentCatalogLoader.load_document(ASSET_CATALOG_FILE)
	if not parsed is Dictionary or not parsed.get("assets", []) is Array:
		return
	for value in parsed.get("assets", []):
		if value is Dictionary:
			map_preview_assets.append(value.duplicate(true))

func _refresh_map_preview(map_path: String) -> void:
	if map_preview_canvas == null:
		return
	if map_path.is_empty():
		map_preview_status.text = "연결된 맵 없음"
		map_preview_canvas.set_map_data({})
		return
	var data := MapLoader.load_map_data(map_path)
	if data.is_empty():
		map_preview_status.text = "맵을 불러올 수 없습니다: " + map_path
		map_preview_canvas.set_map_data({})
		return
	_load_map_preview_assets()
	map_preview_canvas.set_catalog_assets(map_preview_assets)
	map_preview_canvas.set_editor_mode("ASSET")
	map_preview_canvas.set_gameplay_visible(false)
	map_preview_canvas.set_map_data(data)
	map_preview_status.text = "%s  |  %s" % [str(data.get("name", map_path.get_file())), map_path]

func _on_stage_selected(_index: int) -> void:
	_load_selected_stage()

func _load_selected_stage() -> void:
	if stage_list == null or stage_list.selected < 0: return
	current_path = str(stage_list.get_item_metadata(stage_list.selected))
	stage_data = StageLoader.load_stage_data(current_path)
	if stage_data.is_empty():
		_set_status("FAILED to load: " + current_path)
		return
	id_edit.text = str(stage_data.get("stage_id", ""))
	order_spin.value = int(stage_data.get("order", 1))
	name_edit.text = str(stage_data.get("name", ""))
	_refresh_map_options(str(stage_data.get("map_file", "")))
	var balance: Dictionary = stage_data.get("balance", {}) if stage_data.get("balance", {}) is Dictionary else {}
	gold_spin.value = int(balance.get("initial_gold", 180))
	hp_spin.value = float(balance.get("base_hp", 100.0))
	_load_mission_fields()
	_rebuild_encounters()

func _load_mission_fields() -> void:
	var mission_id := str(stage_data.get("mission_id", ""))
	var mission := MissionDefinitionLoader.load_definition(mission_id) if not mission_id.is_empty() else null
	mission_id_edit.text = mission_id
	mission_title_edit.text = mission.title if mission != null else ""
	mission_briefing_edit.text = mission.briefing if mission != null else ""
	var mission_type := mission.primary_type if mission != null else "clear_encounters"
	mission_type_option.select(max(0, ["defend_base", "clear_encounters", "defeat_giant"].find(mission_type)))
	mission_target_edit.text = mission.target_id if mission != null else ""
	mission_time_spin.value = mission.time_limit if mission != null else 0
	reward_id_edit.text = str(stage_data.get("reward_id", ""))
	_load_reward_fields()

func _load_reward_fields() -> void:
	var reward_id := str(stage_data.get("reward_id", ""))
	var reward := RewardDefinitionLoader.load_definition(reward_id) if not reward_id.is_empty() else null
	reward_gold_spin.value = reward.gold if reward != null else 0
	reward_item_ids_edit.text = ", ".join(reward.item_ids) if reward != null else ""

func _open_selected_map() -> void:
	if map_option == null or map_option.selected < 0:
		_set_status("사용 맵이 선택되지 않았습니다.")
		return
	request_map_editor_for_path.emit(str(map_option.get_item_metadata(map_option.selected)))

func _rebuild_encounters() -> void:
	for child in encounters_box.get_children(): child.queue_free()
	for i in stage_data.get("encounters", []).size(): _build_encounter_card(i)

func _build_encounter_card(ei: int) -> void:
	var encounter: Dictionary = stage_data["encounters"][ei]
	var panel := PanelContainer.new()
	encounters_box.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "Encounter %d" % (ei + 1)
	title.custom_minimum_size.x = 100
	header.add_child(title)
	var id := LineEdit.new()
	id.text = str(encounter.get("id", "encounter_%02d" % (ei + 1)))
	id.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id.text_changed.connect(func(v): stage_data["encounters"][ei]["id"] = v)
	header.add_child(id)
	var label := LineEdit.new()
	label.text = str(encounter.get("label", "ENCOUNTER %d" % (ei + 1)))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text_changed.connect(func(v): stage_data["encounters"][ei]["label"] = v)
	header.add_child(label)
	var del := Button.new()
	del.text = "Delete"
	del.disabled = stage_data["encounters"].size() <= 1
	del.pressed.connect(func(): _delete_encounter(ei))
	header.add_child(del)
	for wi in encounter.get("waves", []).size(): _build_wave_card(box, ei, wi)
	var add := Button.new()
	add.text = "+ Add Wave"
	add.pressed.connect(func(): _add_wave(ei))
	box.add_child(add)

func _build_wave_card(parent: VBoxContainer, ei: int, wi: int) -> void:
	var wave: Dictionary = stage_data["encounters"][ei]["waves"][wi]
	var panel := PanelContainer.new()
	parent.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "Wave %d" % (wi + 1)
	header.add_child(title)
	var label := LineEdit.new()
	label.text = str(wave.get("label", "WAVE %d" % (wi + 1)))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text_changed.connect(func(v): stage_data["encounters"][ei]["waves"][wi]["label"] = v)
	header.add_child(label)
	var del := Button.new()
	del.text = "Delete Wave"
	del.disabled = stage_data["encounters"][ei]["waves"].size() <= 1
	del.pressed.connect(func(): _delete_wave(ei, wi))
	header.add_child(del)
	for gi in wave.get("groups", []).size(): _build_group_row(box, ei, wi, gi)
	var add := Button.new()
	add.text = "+ Add Group"
	add.pressed.connect(func(): _add_group(ei, wi))
	box.add_child(add)

func _build_group_row(parent: VBoxContainer, ei: int, wi: int, gi: int) -> void:
	var group: Array = stage_data["encounters"][ei]["waves"][wi]["groups"][gi]
	var row := HBoxContainer.new()
	parent.add_child(row)
	var enemy := OptionButton.new()
	for e in enemy_types: enemy.add_item(str(e).to_upper())
	enemy.select(max(0, enemy_types.find(str(group[0]))))
	enemy.item_selected.connect(func(v): stage_data["encounters"][ei]["waves"][wi]["groups"][gi][0] = str(enemy_types[v]))
	row.add_child(enemy)
	var count := SpinBox.new()
	count.min_value = 1
	count.max_value = 999
	count.step = 1
	count.value = int(group[1])
	count.value_changed.connect(func(v): stage_data["encounters"][ei]["waves"][wi]["groups"][gi][1] = int(v))
	row.add_child(count)
	var interval := SpinBox.new()
	interval.min_value = 0.05
	interval.max_value = 60
	interval.step = 0.05
	interval.value = float(group[2])
	interval.value_changed.connect(func(v): stage_data["encounters"][ei]["waves"][wi]["groups"][gi][2] = float(v))
	row.add_child(interval)
	var lane := OptionButton.new()
	for l in LANES: lane.add_item(l)
	var lanes: Array = group[3]
	var lane_value := "both" if lanes.size() > 1 else str(lanes[0]) if not lanes.is_empty() else "left"
	lane.select(max(0, LANES.find(lane_value)))
	lane.item_selected.connect(func(v): stage_data["encounters"][ei]["waves"][wi]["groups"][gi][3] = ["left", "right"] if LANES[v] == "both" else [LANES[v]])
	row.add_child(lane)
	var del := Button.new()
	del.text = "Delete"
	del.pressed.connect(func(): _delete_group(ei, wi, gi))
	row.add_child(del)

func _add_encounter() -> void:
	stage_data["encounters"].append({"id": "encounter_%02d" % (stage_data["encounters"].size() + 1), "label": "NEW ENCOUNTER", "waves": [{"label": "NEW WAVE", "groups": []}]})
	_rebuild_encounters()

func _delete_encounter(ei: int) -> void:
	if stage_data["encounters"].size() <= 1: return
	stage_data["encounters"].remove_at(ei)
	_rebuild_encounters()

func _add_wave(ei: int) -> void:
	stage_data["encounters"][ei]["waves"].append({"label": "NEW WAVE", "groups": []})
	_rebuild_encounters()

func _delete_wave(ei: int, wi: int) -> void:
	if stage_data["encounters"][ei]["waves"].size() <= 1: return
	stage_data["encounters"][ei]["waves"].remove_at(wi)
	_rebuild_encounters()

func _add_group(ei: int, wi: int) -> void:
	stage_data["encounters"][ei]["waves"][wi]["groups"].append(["normal", 1, 1.0, ["left"]])
	_rebuild_encounters()

func _delete_group(ei: int, wi: int, gi: int) -> void:
	stage_data["encounters"][ei]["waves"][wi]["groups"].remove_at(gi)
	_rebuild_encounters()

func _confirm_delete_stage() -> void:
	if current_path.is_empty():
		_set_status("No stage selected.")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Delete Stage"
	dialog.dialog_text = "Delete stage \"%s\"? The linked map will not be deleted." % str(stage_data.get("name", current_path.get_file().get_basename()))
	add_child(dialog)
	dialog.confirmed.connect(func(): _delete_stage(dialog))
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(520, 200))

func _delete_stage(dialog: ConfirmationDialog) -> void:
	var stage_id := str(stage_data.get("stage_id", current_path.get_file().get_basename()))
	var catalog := ContentCatalogLoader.load_document(STAGE_CATALOG_FILE)
	if catalog.is_empty():
		_set_status("FAILED to load stage catalog from SQLite.")
		dialog.queue_free()
		return
	var stages: Array = catalog.get("stages", [])
	stages.erase(stage_id)
	catalog["stages"] = stages
	if not ObjectPersistence.save_content_document(STAGE_CATALOG_FILE, catalog):
		_set_status("FAILED to update stage catalog in SQLite.")
		dialog.queue_free()
		return
	var stage_table := stage_id
	if not ObjectPersistence.delete_content_document(current_path):
		_set_status("FAILED to delete stage from SQLite: " + stage_table)
		dialog.queue_free()
		return
	current_path = ""
	stage_data = {}
	_refresh_stage_list()
	if stage_list.item_count > 0:
		stage_list.select(0)
		_load_selected_stage()
	_set_status("DELETED stage: " + stage_id)
	dialog.queue_free()

func _save_mission() -> bool:
	var mission_id := mission_id_edit.text.strip_edges()
	if mission_id.is_empty():
		_set_status("Mission ID is required."); return false
	var catalog := MissionDefinitionLoader.load_catalog()
	catalog[mission_id] = {
		"id": mission_id,
		"title": mission_title_edit.text.strip_edges(),
		"briefing": mission_briefing_edit.text.strip_edges(),
		"primary_type": str(mission_type_option.get_item_text(mission_type_option.selected)),
		"target_id": mission_target_edit.text.strip_edges(),
		"time_limit": int(mission_time_spin.value)
	}
	return ObjectPersistence.save_catalog(MISSION_CATALOG_FILE, catalog)

func _save_reward() -> bool:
	var reward_id := reward_id_edit.text.strip_edges()
	if reward_id.is_empty():
		_set_status("Reward ID is required."); return false
	var item_ids: Array[String] = []
	for raw_item_id in reward_item_ids_edit.text.split(","):
		var item_id := str(raw_item_id).strip_edges()
		if not item_id.is_empty() and not item_ids.has(item_id):
			item_ids.append(item_id)
	var catalog := RewardDefinitionLoader.load_catalog()
	catalog[reward_id] = {
		"id": reward_id,
		"gold": int(reward_gold_spin.value),
		"item_ids": item_ids
	}
	return ObjectPersistence.save_catalog(REWARD_CATALOG_FILE, catalog)

func _save_stage() -> void:
	if current_path.is_empty() or id_edit.text.strip_edges().is_empty() or name_edit.text.strip_edges().is_empty():
		_set_status("Stage ID and Name are required."); return
	if map_option.selected < 0:
		_set_status("A Map is required."); return
	var encounters: Array = stage_data.get("encounters", [])
	if encounters.is_empty():
		_set_status("At least one Encounter is required."); return
	for encounter in encounters:
		if not (encounter is Dictionary) or str(encounter.get("id", "")).strip_edges().is_empty() or not (encounter.get("waves", []) is Array) or encounter["waves"].is_empty():
			_set_status("Every Encounter requires an ID and at least one Wave."); return
	stage_data["stage_id"] = id_edit.text.strip_edges()
	stage_data["order"] = int(order_spin.value)
	stage_data["name"] = name_edit.text
	stage_data["map_file"] = str(map_option.get_item_metadata(map_option.selected))
	stage_data["balance"] = {"initial_gold": int(gold_spin.value), "base_hp": float(hp_spin.value)}
	if not _save_mission(): return
	if not _save_reward(): return
	stage_data["mission_id"] = mission_id_edit.text.strip_edges()
	stage_data["reward_id"] = reward_id_edit.text.strip_edges()
	stage_data.erase("mission")
	if not ObjectPersistence.save_content_document(current_path, stage_data):
		_set_status("FAILED to save Stage to SQLite: " + current_path)
		return
	_set_status("SAVED TO SQLITE: " + current_path)

func _set_status(message: String) -> void:
	if status_label: status_label.text = "Status: " + message

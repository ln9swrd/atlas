class_name StageEditorMain
extends Control

const STAGE_DIR := "res://content/stages/"
const MAP_DIR := "res://content/maps/"
const ENEMY_TYPES := ["normal", "rusher", "heavy", "giant"]
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
var waves_box: VBoxContainer
var status_label: Label

func _ready() -> void:
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
	title.text = "MENOS // 스테이지 에디터  —  MVP"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)
	var top := HBoxContainer.new()
	root.add_child(top)
	stage_list = OptionButton.new()
	stage_list.custom_minimum_size.x = 220
	stage_list.item_selected.connect(_on_stage_selected)
	top.add_child(stage_list)
	var load_btn := Button.new(); load_btn.text = "새로고침"; load_btn.pressed.connect(_load_selected_stage); top.add_child(load_btn)
	var save_btn := Button.new(); save_btn.text = "JSON 저장"; save_btn.pressed.connect(_save_stage); top.add_child(save_btn)
	status_label = Label.new(); status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; top.add_child(status_label)
	var scroll := ScrollContainer.new(); scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL; root.add_child(scroll)
	var content := VBoxContainer.new(); content.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll.add_child(content)
	_build_stage_properties(content)
	var sep := HSeparator.new(); content.add_child(sep)
	var waves_title := Label.new(); waves_title.text = "웨이브"; waves_title.add_theme_font_size_override("font_size", 16); content.add_child(waves_title)
	waves_box = VBoxContainer.new(); waves_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL; content.add_child(waves_box)
	var add_wave := Button.new(); add_wave.text = "+ 웨이브 추가"; add_wave.pressed.connect(_add_wave); content.add_child(add_wave)

func _build_stage_properties(parent: VBoxContainer) -> void:
	var title := Label.new(); title.text = "스테이지 속성"; title.add_theme_font_size_override("font_size", 16); parent.add_child(title)
	id_edit = _line_row(parent, "스테이지 ID")
	order_spin = _spin_row(parent, "순서", 1, 999, 1, 1)
	name_edit = _line_row(parent, "이름")
	map_option = OptionButton.new(); _option_row(parent, "Map", map_option)
	gold_spin = _spin_row(parent, "초기 골드", 0, 999999, 10, 180)
	hp_spin = _spin_row(parent, "기지 HP", 1, 999999, 10, 100)
	next_edit = _line_row(parent, "Next 스테이지 ID")

func _line_row(parent: VBoxContainer, label_text: String) -> LineEdit:
	var row := HBoxContainer.new(); parent.add_child(row)
	var label := Label.new(); label.text = label_text; label.custom_minimum_size.x = 130; row.add_child(label)
	var edit := LineEdit.new(); edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(edit)
	return edit

func _spin_row(parent: VBoxContainer, label_text: String, minimum: float, maximum: float, step: float, value: float) -> SpinBox:
	var row := HBoxContainer.new(); parent.add_child(row)
	var label := Label.new(); label.text = label_text; label.custom_minimum_size.x = 130; row.add_child(label)
	var spin := SpinBox.new(); spin.min_value = minimum; spin.max_value = maximum; spin.step = step; spin.value = value; spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(spin)
	return spin

func _option_row(parent: VBoxContainer, label_text: String, option: OptionButton) -> void:
	var row := HBoxContainer.new(); parent.add_child(row)
	var label := Label.new(); label.text = label_text; label.custom_minimum_size.x = 130; row.add_child(label)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(option)

func _refresh_stage_list() -> void:
	stage_list.clear()
	var dir := DirAccess.open(STAGE_DIR)
	if dir == null: return
	var files: Array[String] = []
	dir.list_dir_begin()
	var file := dir.get_next()
	while not file.is_empty():
		if not dir.current_is_dir() and file.ends_with(".json"): files.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for f in files: stage_list.add_item(f.get_basename()); stage_list.set_item_metadata(stage_list.item_count - 1, STAGE_DIR + f)

func _refresh_map_options(selected_path: String) -> void:
	map_option.clear()
	var dir := DirAccess.open(MAP_DIR)
	if dir == null: return
	var files: Array[String] = []
	dir.list_dir_begin()
	var file := dir.get_next()
	while not file.is_empty():
		if not dir.current_is_dir() and file.ends_with(".json"): files.append(file)
		file = dir.get_next()
	dir.list_dir_end(); files.sort()
	var selected := 0
	for f in files:
		var path := MAP_DIR + f; map_option.add_item(f); map_option.set_item_metadata(map_option.item_count - 1, path)
		if path == selected_path: selected = map_option.item_count - 1
	if map_option.item_count > 0: map_option.select(selected)

func _on_stage_selected(_index: int) -> void:
	_load_selected_stage()

func _load_selected_stage() -> void:
	if stage_list == null or stage_list.selected < 0: return
	current_path = str(stage_list.get_item_metadata(stage_list.selected))
	stage_data = StageLoader.load_stage_data(current_path)
	if stage_data.is_empty():
		_set_status("FAILED to load: " + current_path); return
	id_edit.text = str(stage_data.get("stage_id", ""))
	order_spin.value = int(stage_data.get("order", 1))
	name_edit.text = str(stage_data.get("name", ""))
	_refresh_map_options(str(stage_data.get("map_file", "")))
	gold_spin.value = int(stage_data.get("initial_gold", 180))
	hp_spin.value = float(stage_data.get("base_hp", 100.0))
	next_edit.text = str(stage_data.get("next_stage_id", ""))
	_rebuild_waves()
	_set_status("Loaded: " + current_path)

func _rebuild_waves() -> void:
	for child in waves_box.get_children(): child.queue_free()
	var waves: Array = stage_data.get("waves", [])
	for i in waves.size(): _build_wave_card(i)

func _build_wave_card(index: int) -> void:
	var waves: Array = stage_data["waves"]
	var wave: Dictionary = waves[index]
	var panel := PanelContainer.new(); waves_box.add_child(panel)
	var box := VBoxContainer.new(); panel.add_child(box)
	var header := HBoxContainer.new(); box.add_child(header)
	var label := Label.new(); label.text = "Wave %d" % (index + 1); label.custom_minimum_size.x = 80; header.add_child(label)
	var wave_label := LineEdit.new(); wave_label.text = str(wave.get("label", "WAVE %d" % (index + 1))); wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(wave_label)
	wave_label.text_changed.connect(func(v): stage_data["waves"][index]["label"] = v)
	var up := Button.new(); up.text = "↑"; up.disabled = index == 0; up.pressed.connect(func(): _move_wave(index, -1)); header.add_child(up)
	var down := Button.new(); down.text = "↓"; down.disabled = index >= waves.size() - 1; down.pressed.connect(func(): _move_wave(index, 1)); header.add_child(down)
	var del := Button.new(); del.text = "삭제 Wave"; del.pressed.connect(func(): _delete_wave(index)); header.add_child(del)
	var groups: Array = wave.get("groups", [])
	for g in groups.size(): _build_group_row(box, index, g)
	var add := Button.new(); add.text = "+ 그룹 추가"; add.pressed.connect(func(): _add_group(index)); box.add_child(add)

func _build_group_row(parent: VBoxContainer, wave_index: int, group_index: int) -> void:
	var groups: Array = stage_data["waves"][wave_index]["groups"]
	var group: Array = groups[group_index]
	var row := HBoxContainer.new(); parent.add_child(row)
	var enemy := OptionButton.new(); enemy.custom_minimum_size.x = 105
	for e in ENEMY_TYPES: enemy.add_item(e.to_upper())
	enemy.select(max(0, ENEMY_TYPES.find(str(group[0])))); enemy.item_selected.connect(func(v): stage_data["waves"][wave_index]["groups"][group_index][0] = ENEMY_TYPES[v]); row.add_child(enemy)
	var count := SpinBox.new(); count.min_value = 1; count.max_value = 999; count.step = 1; count.value = int(group[1]); count.custom_minimum_size.x = 80; count.value_changed.connect(func(v): stage_data["waves"][wave_index]["groups"][group_index][1] = int(v)); row.add_child(count)
	var interval := SpinBox.new(); interval.min_value = 0.05; interval.max_value = 60; interval.step = 0.05; interval.value = float(group[2]); interval.custom_minimum_size.x = 90; interval.value_changed.connect(func(v): stage_data["waves"][wave_index]["groups"][group_index][2] = float(v)); row.add_child(interval)
	var lane := OptionButton.new(); lane.custom_minimum_size.x = 90; for l in LANES: lane.add_item(l)
	var lanes: Array = group[3]; var lane_value := "both" if lanes.size() > 1 else str(lanes[0]) if not lanes.is_empty() else "left"; lane.select(LANES.find(lane_value)); lane.item_selected.connect(func(v): stage_data["waves"][wave_index]["groups"][group_index][3] = ["left", "right"] if LANES[v] == "both" else [LANES[v]]); row.add_child(lane)
	var del := Button.new(); del.text = "삭제"; del.pressed.connect(func(): _delete_group(wave_index, group_index)); row.add_child(del)

func _add_wave() -> void:
	if not stage_data.has("waves"): stage_data["waves"] = []
	stage_data["waves"].append({"label": "NEW WAVE", "groups": []}); _rebuild_waves(); _set_status("Wave added (unsaved)")

func _delete_wave(index: int) -> void:
	if stage_data["waves"].size() <= 1: _set_status("At least one wave is required."); return
	stage_data["waves"].remove_at(index); _rebuild_waves(); _set_status("Wave deleted (unsaved)")

func _move_wave(index: int, direction: int) -> void:
	var target := index + direction
	if target < 0 or target >= stage_data["waves"].size(): return
	var tmp = stage_data["waves"][index]; stage_data["waves"][index] = stage_data["waves"][target]; stage_data["waves"][target] = tmp
	_rebuild_waves(); _set_status("Wave order changed (unsaved)")

func _add_group(wave_index: int) -> void:
	if not stage_data["waves"][wave_index].has("groups"): stage_data["waves"][wave_index]["groups"] = []
	stage_data["waves"][wave_index]["groups"].append(["normal", 1, 1.0, ["left"]]); _rebuild_waves(); _set_status("Group added (unsaved)")

func _delete_group(wave_index: int, group_index: int) -> void:
	var groups: Array = stage_data["waves"][wave_index]["groups"]
	groups.remove_at(group_index); _rebuild_waves(); _set_status("Group deleted (unsaved)")

func _save_stage() -> void:
	if current_path.is_empty(): _set_status("No stage loaded."); return
	if id_edit.text.strip_edges().is_empty() or name_edit.text.strip_edges().is_empty(): _set_status("스테이지 ID and 이름 are required."); return
	if map_option.selected < 0: _set_status("A Map is required."); return
	var waves: Array = stage_data.get("waves", [])
	if waves.is_empty(): _set_status("At least one Wave is required."); return
	stage_data["stage_id"] = id_edit.text.strip_edges()
	stage_data["order"] = int(order_spin.value)
	stage_data["name"] = name_edit.text
	stage_data["map_file"] = str(map_option.get_item_metadata(map_option.selected))
	stage_data["balance"] = {"initial_gold": int(gold_spin.value), "base_hp": float(hp_spin.value)}
	stage_data["initial_gold"] = int(gold_spin.value); stage_data["base_hp"] = float(hp_spin.value)
	stage_data["next_stage_id"] = next_edit.text.strip_edges()
	var file := FileAccess.open(current_path, FileAccess.WRITE)
	if file == null: _set_status("FAILED to open file for writing."); return
	file.store_string(JSON.stringify(_raw_stage_data(), "  ")); file.close()
	_set_status("SAVED: " + current_path)

func _raw_stage_data() -> Dictionary:
	var raw := stage_data.duplicate(true)
	raw.erase("initial_gold"); raw.erase("base_hp")
	return raw

func _set_status(message: String) -> void:
	if status_label: status_label.text = "Status: " + message

extends Window

const TOOL_PATH := "res://tools/manage_runtime_registry.py"
var targets: Array = []
var table_catalog: Array = []
var selected_runtime_id := 0
var selected_target: Dictionary = {}
var target_combo: OptionButton
var name_edit: LineEdit
var path_edit: LineEdit
var notes_edit: LineEdit
var enabled_check: CheckBox
var table_list: VBoxContainer
var status_label: Label
var path_dialog: FileDialog
var delete_confirm: ConfirmationDialog
var _loading_tables := false

func _ready() -> void:
	title = "Runtime Targets / 런타임 관리"
	size = Vector2i(1120, 760)
	min_size = Vector2i(900, 600)
	_build_ui()
	_load_registry()
	close_requested.connect(queue_free)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var heading := Label.new()
	heading.text = "RUNTIME TARGETS  |  런타임 등록 및 테이블 관리"
	heading.add_theme_font_size_override("font_size", 18)
	root.add_child(heading)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 310
	split.add_child(left)
	var targets_title := Label.new()
	targets_title.text = "등록된 런타임"
	left.add_child(targets_title)
	target_combo = OptionButton.new()
	target_combo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_combo.item_selected.connect(_on_target_selected)
	left.add_child(target_combo)
	var target_actions := HBoxContainer.new()
	left.add_child(target_actions)
	var add_button := Button.new()
	add_button.text = "새 런타임"
	add_button.pressed.connect(_new_target)
	target_actions.add_child(add_button)
	var save_button := Button.new()
	save_button.text = "등록/저장"
	save_button.pressed.connect(_save_target)
	target_actions.add_child(save_button)
	var delete_button := Button.new()
	delete_button.text = "삭제"
	delete_button.pressed.connect(_confirm_delete)
	target_actions.add_child(delete_button)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	split.add_child(right)
	var details_title := Label.new()
	details_title.text = "런타임 정보"
	right.add_child(details_title)
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "런타임 이름 (예: MENOS Development)"
	right.add_child(name_edit)
	var path_row := HBoxContainer.new()
	right.add_child(path_row)
	path_edit = LineEdit.new()
	path_edit.placeholder_text = "런타임 프로젝트 경로 (project.godot 폴더)"
	path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_row.add_child(path_edit)
	var browse := Button.new()
	browse.text = "찾기..."
	browse.pressed.connect(_browse_path)
	path_row.add_child(browse)
	enabled_check = CheckBox.new()
	enabled_check.text = "발행 대상 활성화"
	enabled_check.button_pressed = true
	right.add_child(enabled_check)
	notes_edit = LineEdit.new()
	notes_edit.placeholder_text = "메모 (선택)"
	right.add_child(notes_edit)
	var table_heading := Label.new()
	table_heading.text = "이 런타임에 포함할 콘텐츠 테이블"
	table_heading.add_theme_font_size_override("font_size", 15)
	right.add_child(table_heading)
	var table_hint := Label.new()
	table_hint.text = "체크된 테이블은 이 런타임의 관리 설정입니다. 에디터 전용 테이블은 목록에서 제외됩니다."
	table_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(table_hint)
	var table_scroll := ScrollContainer.new()
	table_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(table_scroll)
	table_list = VBoxContainer.new()
	table_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table_scroll.add_child(table_list)
	var table_actions := HBoxContainer.new()
	right.add_child(table_actions)
	var all_button := Button.new()
	all_button.text = "전체 선택"
	all_button.pressed.connect(func(): _set_all_tables(true))
	table_actions.add_child(all_button)
	var none_button := Button.new()
	none_button.text = "전체 해제"
	none_button.pressed.connect(func(): _set_all_tables(false))
	table_actions.add_child(none_button)
	var save_tables_button := Button.new()
	save_tables_button.text = "테이블 설정 저장"
	save_tables_button.pressed.connect(_save_table_settings)
	table_actions.add_child(save_tables_button)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(footer)
	var refresh_button := Button.new()
	refresh_button.text = "새로고침"
	refresh_button.pressed.connect(_load_registry)
	footer.add_child(refresh_button)
	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.pressed.connect(queue_free)
	footer.add_child(close_button)

	path_dialog = FileDialog.new()
	path_dialog.title = "런타임 프로젝트 폴더 선택"
	path_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	path_dialog.access = FileDialog.ACCESS_FILESYSTEM
	path_dialog.dir_selected.connect(func(path: String): path_edit.text = path)
	add_child(path_dialog)
	delete_confirm = ConfirmationDialog.new()
	delete_confirm.title = "런타임 등록 삭제"
	delete_confirm.dialog_text = "선택한 런타임 등록과 해당 런타임의 테이블 설정을 삭제하시겠습니까? 실제 런타임 프로젝트 파일은 삭제하지 않습니다."
	delete_confirm.confirmed.connect(_delete_target)
	add_child(delete_confirm)

func _run_tool(action: String, extra: PackedStringArray = PackedStringArray()) -> Dictionary:
	var script := ProjectSettings.globalize_path(TOOL_PATH)
	var args := PackedStringArray([script, action])
	args.append_array(extra)
	var output: Array = []
	# The tool emits its machine-readable result on stdout. Keep stderr separate so
	# warnings or interpreter diagnostics cannot corrupt the JSON response.
	var code := OS.execute("python", args, output, false)
	if code == -1:
		output.clear()
		var fallback := PackedStringArray(["-3", script, action])
		fallback.append_array(extra)
		code = OS.execute("py", fallback, output, false)
	var raw := "\n".join(PackedStringArray(output)).strip_edges()
	raw = raw.trim_prefix("\uFEFF")
	# Use JSON.parse() instead of parse_string(): malformed/empty output should
	# be reported in the UI, not emitted as a noisy engine error.
	var parser := JSON.new()
	var parse_error := parser.parse(raw)
	var parsed: Variant = parser.data if parse_error == OK else null
	# Be tolerant of harmless stdout noise, but only parse an actual JSON object.
	if not (parsed is Dictionary):
		var json_start := raw.find("{")
		var json_end := raw.rfind("}")
		if json_start >= 0 and json_end >= json_start:
			var fallback_parser := JSON.new()
			if fallback_parser.parse(raw.substr(json_start, json_end - json_start + 1)) == OK:
				parsed = fallback_parser.data
	if not (parsed is Dictionary):
		return {"status":"FAIL","error":"도구 응답을 읽을 수 없습니다 (exit=%d, 출력=%d자, JSON 오류=%s): %s" % [code, raw.length(), parser.get_error_message(), raw]}
	return parsed

func _load_registry() -> void:
	var result := _run_tool("list")
	if result.get("status") != "PASS":
		status_label.text = "로드 실패: " + str(result.get("error", "unknown error"))
		return
	targets = result.get("targets", [])
	table_catalog = result.get("table_catalog", [])
	target_combo.clear()
	for target in targets:
		var suffix := " [활성]" if int(target.get("enabled", 0)) == 1 else " [비활성]"
		target_combo.add_item(str(target.get("name", "Unnamed")) + suffix)
		target_combo.set_item_metadata(target_combo.item_count - 1, int(target.get("id", 0)))
	status_label.text = "등록 런타임 %d개 | 관리 테이블 %d개" % [targets.size(), table_catalog.size()]
	if targets.is_empty():
		selected_runtime_id = 0
		selected_target = {}
		_clear_form()
	else:
		var index := 0
		for i in range(targets.size()):
			if int(targets[i].get("id", 0)) == selected_runtime_id:
				index = i
				break
		target_combo.select(index)
		_on_target_selected(index)

func _clear_form() -> void:
	name_edit.text = ""
	path_edit.text = ""
	notes_edit.text = ""
	enabled_check.button_pressed = true
	for child in table_list.get_children():
		child.queue_free()

func _on_target_selected(index: int) -> void:
	if index < 0 or index >= targets.size():
		return
	selected_target = targets[index]
	selected_runtime_id = int(selected_target.get("id", 0))
	var selection_config := ConfigFile.new()
	selection_config.set_value("runtime", "selected_runtime_id", selected_runtime_id)
	selection_config.save("user://menos_settings.cfg")
	name_edit.text = str(selected_target.get("name", ""))
	path_edit.text = str(selected_target.get("path", ""))
	notes_edit.text = str(selected_target.get("notes", ""))
	enabled_check.button_pressed = int(selected_target.get("enabled", 1)) == 1
	_render_tables(selected_target.get("tables", []))

func _render_tables(saved_tables: Array) -> void:
	_loading_tables = true
	for child in table_list.get_children():
		child.queue_free()
	var enabled_by_name := {}
	for table in saved_tables:
		enabled_by_name[str(table.get("name", ""))] = int(table.get("enabled", 1)) == 1
	for table_name in table_catalog:
		var check := CheckBox.new()
		check.text = str(table_name)
		check.name = "Table_" + str(table_name)
		check.button_pressed = bool(enabled_by_name.get(str(table_name), true))
		check.set_meta("table_name", str(table_name))
		table_list.add_child(check)
	_loading_tables = false

func _new_target() -> void:
	selected_runtime_id = 0
	selected_target = {}
	var selection_config := ConfigFile.new()
	selection_config.set_value("runtime", "selected_runtime_id", 0)
	selection_config.save("user://menos_settings.cfg")
	target_combo.select(-1)
	_clear_form()
	name_edit.text = "MENOS Runtime"
	status_label.text = "새 런타임 정보를 입력한 뒤 '등록/저장'을 누르십시오."

func _browse_path() -> void:
	path_dialog.current_dir = path_edit.text if not path_edit.text.is_empty() else "D:/Atlas/projects"
	path_dialog.popup_centered(Vector2i(850, 600))

func _save_target() -> void:
	if name_edit.text.strip_edges().is_empty() or path_edit.text.strip_edges().is_empty():
		status_label.text = "런타임 이름과 프로젝트 경로가 필요합니다."
		return
	var action := "add" if selected_runtime_id == 0 else "update"
	var extra := PackedStringArray()
	if selected_runtime_id != 0:
		extra.append_array(["--id", str(selected_runtime_id)])
	extra.append_array(["--name", name_edit.text.strip_edges(), "--path", path_edit.text.strip_edges(),
		"--notes", notes_edit.text, "--enabled", "1" if enabled_check.button_pressed else "0"])
	var result := _run_tool(action, extra)
	if result.get("status") != "PASS":
		status_label.text = "저장 실패: " + str(result.get("error", "unknown error"))
		return
	if action == "add":
		selected_runtime_id = int(result.get("id", 0))
	status_label.text = "런타임 정보가 저장되었습니다."
	_load_registry()

func _confirm_delete() -> void:
	if selected_runtime_id == 0:
		status_label.text = "삭제할 런타임을 먼저 선택하십시오."
		return
	delete_confirm.dialog_text = "‘%s’ 등록과 런타임별 테이블 설정을 삭제하시겠습니까? 실제 런타임 파일은 삭제하지 않습니다." % name_edit.text
	delete_confirm.popup_centered()

func _delete_target() -> void:
	var result := _run_tool("delete", PackedStringArray(["--id", str(selected_runtime_id)]))
	if result.get("status") == "PASS":
		selected_runtime_id = 0
		_load_registry()
		status_label.text = "런타임 등록을 삭제했습니다. 런타임 프로젝트 파일은 변경하지 않았습니다."
	else:
		status_label.text = "삭제 실패: " + str(result.get("error", "unknown error"))

func _set_all_tables(value: bool) -> void:
	for child in table_list.get_children():
		if child is CheckBox:
			child.button_pressed = value

func _save_table_settings() -> void:
	if selected_runtime_id == 0:
		status_label.text = "먼저 런타임을 등록하고 선택하십시오."
		return
	for child in table_list.get_children():
		if child is CheckBox:
			var result := _run_tool("set_table", PackedStringArray([
				"--id", str(selected_runtime_id),
				"--table", str(child.get_meta("table_name")),
				"--enabled", "1" if child.button_pressed else "0"
			]))
			if result.get("status") != "PASS":
				status_label.text = "테이블 설정 저장 실패: " + str(result.get("error", "unknown error"))
				return
	status_label.text = "런타임별 테이블 설정을 저장했습니다."
	_load_registry()

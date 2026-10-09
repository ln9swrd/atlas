extends Control

@onready var title_label: Label = $Center/Panel/Content/Title
@onready var resolution_label: Label = $Center/Panel/Content/ResolutionLabel
@onready var resolution_option: OptionButton = $Center/Panel/Content/ResolutionOption
@onready var bgm_label: Label = $Center/Panel/Content/BgmLabel
@onready var sfx_label: Label = $Center/Panel/Content/SfxLabel
@onready var voice_label: Label = $Center/Panel/Content/VoiceLabel
@onready var bgm_slider: HSlider = $Center/Panel/Content/BgmSlider
@onready var sfx_slider: HSlider = $Center/Panel/Content/SfxSlider
@onready var voice_slider: HSlider = $Center/Panel/Content/VoiceSlider
@onready var language_label: Label = $Center/Panel/Content/LanguageLabel
@onready var korean_button: Button = $Center/Panel/Content/Languages/Korean
@onready var english_button: Button = $Center/Panel/Content/Languages/English
@onready var restore_defaults_button: Button = $Center/Panel/Content/RestoreDefaults
@onready var restore_confirm: ConfirmationDialog = $RestoreConfirm
@onready var back_button: Button = $Center/Panel/Content/Back

func _ready() -> void:
	SettingsManager.get_language()
	for size in SettingsManager.RESOLUTIONS:
		resolution_option.add_item("%dx%d" % [size.x, size.y])
	resolution_option.item_selected.connect(_on_resolution_selected)
	korean_button.pressed.connect(func(): _set_language("ko"))
	english_button.pressed.connect(func(): _set_language("en"))
	restore_defaults_button.pressed.connect(restore_confirm.popup_centered)
	restore_confirm.confirmed.connect(_restore_defaults)
	back_button.pressed.connect(_on_back_pressed)
	bgm_slider.value_changed.connect(SettingsManager.set_bgm_volume)
	sfx_slider.value_changed.connect(SettingsManager.set_sfx_volume)
	voice_slider.value_changed.connect(SettingsManager.set_voice_volume)
	bgm_slider.value = SettingsManager.get_bgm_volume()
	sfx_slider.value = SettingsManager.get_sfx_volume()
	voice_slider.value = SettingsManager.get_voice_volume()
	_select_resolution(SettingsManager.get_resolution())
	_refresh_text()

func _set_language(value: String) -> void:
	SettingsManager.set_language(value)
	_refresh_text()

func _on_resolution_selected(index: int) -> void:
	if index >= 0 and index < SettingsManager.RESOLUTIONS.size():
		SettingsManager.set_resolution(SettingsManager.RESOLUTIONS[index])

func _select_resolution(value: Vector2i) -> void:
	var index := SettingsManager.RESOLUTIONS.find(value)
	if index >= 0:
		resolution_option.select(index)

func _restore_defaults() -> void:
	SettingsManager.restore_defaults()
	bgm_slider.set_value_no_signal(SettingsManager.get_bgm_volume())
	sfx_slider.set_value_no_signal(SettingsManager.get_sfx_volume())
	voice_slider.set_value_no_signal(SettingsManager.get_voice_volume())
	_select_resolution(SettingsManager.get_resolution())
	_refresh_text()

func _refresh_text() -> void:
	title_label.text = tr("SETTINGS")
	resolution_label.text = tr("RESOLUTION")
	bgm_label.text = tr("BGM")
	sfx_label.text = tr("SFX")
	voice_label.text = tr("VOICE")
	language_label.text = tr("LANGUAGE")
	korean_button.text = tr("KOREAN")
	english_button.text = tr("ENGLISH")
	restore_defaults_button.text = tr("RESTORE_DEFAULTS")
	back_button.text = tr("BACK")
	restore_confirm.title = tr("RESTORE_DEFAULTS")
	restore_confirm.dialog_text = tr("RESTORE_DEFAULTS_CONFIRM")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/title_screen.tscn")

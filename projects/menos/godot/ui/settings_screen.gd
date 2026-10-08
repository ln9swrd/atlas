extends Control

@onready var title_label: Label = $Center/Panel/Content/Title
@onready var bgm_label: Label = $Center/Panel/Content/BgmLabel
@onready var sfx_label: Label = $Center/Panel/Content/SfxLabel
@onready var bgm_slider: HSlider = $Center/Panel/Content/BgmSlider
@onready var sfx_slider: HSlider = $Center/Panel/Content/SfxSlider
@onready var language_label: Label = $Center/Panel/Content/LanguageLabel
@onready var korean_button: Button = $Center/Panel/Content/Languages/Korean
@onready var english_button: Button = $Center/Panel/Content/Languages/English
@onready var restore_defaults_button: Button = $Center/Panel/Content/RestoreDefaults
@onready var restore_confirm: ConfirmationDialog = $RestoreConfirm
@onready var back_button: Button = $Center/Panel/Content/Back

func _ready() -> void:
	korean_button.pressed.connect(func(): _set_language("ko"))
	english_button.pressed.connect(func(): _set_language("en"))
	restore_defaults_button.pressed.connect(restore_confirm.popup_centered)
	restore_confirm.confirmed.connect(_restore_defaults)
	back_button.pressed.connect(_on_back_pressed)
	bgm_slider.value_changed.connect(SettingsManager.set_bgm_volume)
	sfx_slider.value_changed.connect(SettingsManager.set_sfx_volume)
	bgm_slider.value = SettingsManager.get_bgm_volume()
	sfx_slider.value = SettingsManager.get_sfx_volume()
	_refresh_text()

func _set_language(value: String) -> void:
	SettingsManager.set_language(value)
	_refresh_text()

func _restore_defaults() -> void:
	SettingsManager.restore_defaults()
	bgm_slider.value = SettingsManager.get_bgm_volume()
	sfx_slider.value = SettingsManager.get_sfx_volume()
	_refresh_text()

func _refresh_text() -> void:
	title_label.text = tr("SETTINGS")
	bgm_label.text = tr("BGM")
	sfx_label.text = tr("SFX")
	language_label.text = tr("LANGUAGE")
	korean_button.text = tr("KOREAN")
	english_button.text = tr("ENGLISH")
	back_button.text = tr("BACK")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/title_screen.tscn")

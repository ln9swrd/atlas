extends Control

@onready var title_label: Label = $Center/Panel/Content/Title
@onready var language_label: Label = $Center/Panel/Content/LanguageLabel
@onready var korean_button: Button = $Center/Panel/Content/Languages/Korean
@onready var english_button: Button = $Center/Panel/Content/Languages/English
@onready var back_button: Button = $Center/Panel/Content/Back

func _ready() -> void:
	korean_button.pressed.connect(func(): _set_language("ko"))
	english_button.pressed.connect(func(): _set_language("en"))
	back_button.pressed.connect(_on_back_pressed)
	_refresh_text()

func _set_language(value: String) -> void:
	SettingsManager.set_language(value)
	_refresh_text()

func _refresh_text() -> void:
	title_label.text = LocalizationRepository.message("settings.title")
	language_label.text = LocalizationRepository.message("settings.language")
	korean_button.text = LocalizationRepository.message("settings.korean")
	english_button.text = LocalizationRepository.message("settings.english")
	back_button.text = LocalizationRepository.message("settings.back")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/title_screen.tscn")
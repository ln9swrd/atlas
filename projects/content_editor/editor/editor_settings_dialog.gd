extends Window

@onready var resolution_label: Label = $Margin/Content/ResolutionLabel
@onready var resolution_option: OptionButton = $Margin/Content/ResolutionOption
@onready var bgm_label: Label = $Margin/Content/BgmLabel
@onready var sfx_label: Label = $Margin/Content/SfxLabel
@onready var voice_label: Label = $Margin/Content/VoiceLabel
@onready var bgm_slider: HSlider = $Margin/Content/BgmSlider
@onready var sfx_slider: HSlider = $Margin/Content/SfxSlider
@onready var voice_slider: HSlider = $Margin/Content/VoiceSlider
@onready var language_label: Label = $Margin/Content/LanguageLabel
@onready var language_option: OptionButton = $Margin/Content/LanguageOption
@onready var restore_button: Button = $Margin/Content/Actions/RestoreDefaults
@onready var close_button: Button = $Margin/Content/Actions/Close

func _ready() -> void:
	EditorSettingsManager.initialize()
	for size in EditorSettingsManager.RESOLUTIONS:
		resolution_option.add_item("%dx%d" % [size.x, size.y])
	resolution_option.item_selected.connect(_on_resolution_selected)
	language_option.add_item("한국어")
	language_option.add_item("English")
	language_option.item_selected.connect(_on_language_selected)
	bgm_slider.value_changed.connect(func(value: float): EditorSettingsManager.set_volume("BGM", value))
	sfx_slider.value_changed.connect(func(value: float): EditorSettingsManager.set_volume("SFX", value))
	voice_slider.value_changed.connect(func(value: float): EditorSettingsManager.set_volume("Voice", value))
	restore_button.pressed.connect(_restore_defaults)
	close_button.pressed.connect(queue_free)
	close_requested.connect(queue_free)
	_sync_controls()
	_refresh_text()

func _sync_controls() -> void:
	resolution_option.select(maxi(0, EditorSettingsManager.RESOLUTIONS.find(EditorSettingsManager.resolution)))
	language_option.select(0 if EditorSettingsManager.language == "ko" else 1)
	bgm_slider.set_value_no_signal(EditorSettingsManager.get_volume("BGM"))
	sfx_slider.set_value_no_signal(EditorSettingsManager.get_volume("SFX"))
	voice_slider.set_value_no_signal(EditorSettingsManager.get_volume("Voice"))

func _on_resolution_selected(index: int) -> void:
	if index >= 0 and index < EditorSettingsManager.RESOLUTIONS.size():
		EditorSettingsManager.set_resolution(EditorSettingsManager.RESOLUTIONS[index])

func _on_language_selected(index: int) -> void:
	EditorSettingsManager.set_language("ko" if index == 0 else "en")
	_refresh_text()

func _restore_defaults() -> void:
	EditorSettingsManager.restore_defaults()
	_sync_controls()
	_refresh_text()

func _refresh_text() -> void:
	var korean := EditorSettingsManager.language == "ko"
	title = "설정" if korean else "Settings"
	resolution_label.text = "화면 해상도" if korean else "Resolution"
	bgm_label.text = "배경 음악 볼륨 (BGM)" if korean else "Background music volume (BGM)"
	sfx_label.text = "효과음 볼륨 (SFX)" if korean else "Sound effects volume (SFX)"
	voice_label.text = "음성 볼륨 (Voice)" if korean else "Voice volume"
	language_label.text = "언어" if korean else "Language"
	restore_button.text = "기본값 복원" if korean else "Restore defaults"
	close_button.text = "닫기" if korean else "Close"

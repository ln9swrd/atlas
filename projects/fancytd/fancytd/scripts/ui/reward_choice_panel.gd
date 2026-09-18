class_name RewardChoicePanel
extends PanelContainer

signal reward_selected(reward: RewardData)

var _rewards: Array[RewardData] = []
@onready var _title: Label = get_node_or_null("Margin/VBox/Title") as Label
@onready var _buttons: Array[Button] = [
	get_node_or_null("Margin/VBox/Choices/Choice1") as Button,
	get_node_or_null("Margin/VBox/Choices/Choice2") as Button,
	get_node_or_null("Margin/VBox/Choices/Choice3") as Button,
]


func show_rewards(rewards: Array[RewardData]) -> void:
	_rewards = rewards
	visible = true
	if _title != null:
		_title.text = "Choose a Reward"
	for index in _buttons.size():
		var button := _buttons[index]
		if button == null:
			continue
		button.visible = index < _rewards.size()
		if index < _rewards.size():
			button.text = "%s\n%s" % [_rewards[index].title, _rewards[index].description]


func hide_rewards() -> void:
	visible = false


func _ready() -> void:
	for index in _buttons.size():
		if _buttons[index] != null:
			_buttons[index].pressed.connect(_on_choice_pressed.bind(index))
	hide_rewards()


func _on_choice_pressed(index: int) -> void:
	if index < 0 or index >= _rewards.size():
		return
	var selected := _rewards[index]
	hide_rewards()
	reward_selected.emit(selected)
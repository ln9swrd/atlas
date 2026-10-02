extends Node2D

var controller: Node2D

func _ready() -> void:
	controller = load("res://game_controller.gd").new()
	controller.name = "GameController"
	add_child(controller)

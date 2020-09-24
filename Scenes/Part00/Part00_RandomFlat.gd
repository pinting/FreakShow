extends Node2D

onready var door = $Inside/Door

signal exit_selected

func _ready():
	door.connect("selected", self, "_on_door_selected")

func _on_door_selected():
	emit_signal("exit_selected")

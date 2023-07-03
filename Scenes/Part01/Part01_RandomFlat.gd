extends Node2D

@onready var door: Selectable = $Inside/Door

signal exit_selected

func _ready() -> void:
	door.connect("selected", Callable(self, "_on_door_selected"))

func _on_door_selected() -> void:
	emit_signal("exit_selected")

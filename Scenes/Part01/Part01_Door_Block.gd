extends Node2D

@export var duration: float = 0.5

@onready var door_closed: Selectable = $DoorClosed
@onready var door_open: Selectable = $DoorOpen

signal selected

func _ready() -> void:
	door_closed.connect("selected", Callable(self, "_on_door_selected"))
	door_open.connect("selected", Callable(self, "_on_door_selected"))
	
	door_closed.visible = true
	door_open.visible = false
	door_open.modulate.a = 0.0

func _on_door_selected() -> void:
	emit_signal("selected")

func _set_effect(value: float) -> void:
	door_open.modulate.a = value
	door_closed.modulate.a = 1.0 - value

func open() -> void:
	door_open.visible = true
	
	await Animator.run(self, "_set_effect", 0.0, 1.0, duration)
	
	door_closed.visible = false

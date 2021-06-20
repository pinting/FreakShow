extends Node2D

export var duration: float = 0.5

onready var tween: Tween = $Tween
onready var door_closed: Selectable = $DoorClosed
onready var door_open: Selectable = $DoorOpen

signal selected

func _ready() -> void:
	door_closed.connect("selected", self, "_on_door_selected")
	door_open.connect("selected", self, "_on_door_selected")
	
	door_closed.visible = true
	door_open.visible = false
	door_open.modulate.a = 0.0

func _on_door_selected() -> void:
	emit_signal("selected")

func open() -> void:
	door_open.visible = true
	
	tween.interpolate_property(
		door_open,
		"modulate:a",
		door_open.modulate.a,
		1.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.interpolate_property(
		door_closed,
		"modulate:a",
		door_closed.modulate.a,
		0.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	door_closed.visible = false

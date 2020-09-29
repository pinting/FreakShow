extends Node2D

export var duration: float = 0.5

onready var door_closed = $DoorClosed
onready var door_open = $DoorOpen

signal selected

func _ready():
	door_closed.connect("selected", self, "_on_door_select")
	door_open.connect("selected", self, "_on_door_select")

func _on_door_select():
	emit_signal("selected")

func _process(delta):
	if door_open.visible:
		var next = door_open.self_modulate.a + delta / duration
		var a = min(1.0, next)
		
		if a == 1.0:
			door_closed.visible = false
		
		door_open.self_modulate.a = a

func open():
	door_open.visible = true

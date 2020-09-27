extends Node2D

onready var door_closed = $DoorClosed
onready var door_open = $DoorOpen

signal selected

func _ready():
	door_closed.connect("selected", self, "_on_door_select")
	door_open.connect("selected", self, "_on_door_select")

func _on_door_select():
	emit_signal("selected")

func open():
	door_closed.visible = false
	door_open.visible = true

func close():
	door_closed.visible = true
	door_open.visible = false

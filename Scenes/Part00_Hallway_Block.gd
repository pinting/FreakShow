extends Node2D

onready var door_locked = $DoorLocked
onready var door_unlocked = $DoorUnlocked

onready var knock_sound = $KnockSound
onready var open_sound = $OpenSound

var locked = true

signal select

func _ready():
	door_locked.connect("select", self, "_on_door_select")
	door_unlocked.connect("select", self, "_on_door_select")

func _on_door_select():
	if locked:
		knock_sound.play()
	else:
		emit_signal("select")

func open():
	open_sound.play()
	door_locked.visible = false
	door_unlocked.visible = true
	locked = false

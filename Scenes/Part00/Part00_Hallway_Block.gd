extends Node2D

onready var door_locked = $DoorLocked
onready var door_unlocked = $DoorUnlocked
onready var knock_sound = $KnockSound

var locked = true
var knocking = true

signal selected

func _ready():
	door_locked.connect("selected", self, "_on_door_select")
	door_unlocked.connect("selected", self, "_on_door_select")

func _on_door_select():
	emit_signal("selected")
	
	if knocking and locked:
		knock_sound.play()

func open():
	door_locked.visible = false
	door_unlocked.visible = true
	locked = false

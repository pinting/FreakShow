extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part00.tscn"

# Continue blink interval
export var continue_blink_interval: float = 0.5

# Zero value
export var zero: float = 0.05

onready var text_continue = $TextCanvas/Continue

func _ready():
	text_continue.text = tr("CONTINUE00")
	text_continue.visible = false
	
	disable_auto_restart = true

func _process(delta):
	if fmod(current_second, continue_blink_interval) <= zero:
		text_continue.visible = not text_continue.visible

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		load_scene(next_scene)

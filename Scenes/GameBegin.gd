extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part00/Part00.tscn"

# Continue blink interval
export var continue_blink_interval: float = 0.5

# Zero value
export var zero: float = 0.05

onready var text_continue = $TextCanvas/Continue

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")

	text_continue.text = tr("CONTINUE00")
	text_continue.visible = false
	
	disable_auto_restart = true

func _process(delta: float) -> void:
	if fmod(current_second, continue_blink_interval) <= zero:
		text_continue.visible = not text_continue.visible

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		load_scene(next_scene)

func _on_scene_started() -> void:
	var scene = Global.AUTO_LOAD_SCENE
	
	if scene and scene != "res://Scenes/GameBegin.tscn":
		visible = false
		
		load_scene(Global.AUTO_LOAD_SCENE)

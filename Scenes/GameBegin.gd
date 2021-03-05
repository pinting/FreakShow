extends "res://Scenes/BaseScene.gd"

export var speed_div: Vector2 = Vector2(30.0, 1500.0)

onready var background = $CanvasLayer/Background
onready var new_game = $CanvasLayer/ColorChanger/Menu/NewGame
onready var continue_game = $CanvasLayer/ColorChanger/Menu/ContinueGame

var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")
	new_game.connect("selected", self, "_on_new_game_selected")
	continue_game.connect("selected", self, "_on_continue_game_selected")
	
	disable_auto_restart = true
	disable_cancel_button = true

func _process(delta: float) -> void:
	offset = offset + Vector2(delta, sin(current_second)) / speed_div
	background.material.set_shader_param("offset", offset)

func _on_scene_started() -> void:
	black_screen.fade_out()

func _on_new_game_selected() -> void:
	yield(black_screen.fade_in(), "animation_finished")
	Save.clear()
	load_scene(Config.FIRST_SCENE, true)

func _on_continue_game_selected() -> void:
	var last_scene = Save.get_value("game", "current_scene")
	
	if last_scene:
		yield(black_screen.fade_in(), "animation_finished")
		load_scene(last_scene)

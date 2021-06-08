extends "res://Game/BaseScene.gd"

export var speed_div: Vector2 = Vector2(30.0, 1500.0)
export var pi_per_pixel: float = PI * 0.0025
export var turn_back_after: float = 1220
export var speed: float = 0.5
export var y_scale: float = 2.0

onready var waves = $CanvasLayer/Waves
onready var decoration = $CanvasLayer/ColorChanger/Decoration
onready var new_game = $CanvasLayer/ColorChanger/NewGame
onready var continue_game = $CanvasLayer/ColorChanger/ContinueGame

var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")
	decoration.connect("direction_changed", self, "_next_decoration_frame")
	new_game.connect("selected", self, "_on_new_game_selected")
	continue_game.connect("selected", self, "_on_continue_game_selected")
	
	disable_auto_restart = true
	disable_cancel_button = true

func _process(delta: float) -> void:
	offset = offset + Vector2(delta, sin(current_second)) / speed_div
	waves.material.set_shader_param("offset", offset)

func _next_decoration_frame():
	var current_animation = decoration.animation
	var last_frame = decoration.frames.get_frame_count(current_animation) - 1
	
	if decoration.frame == last_frame:
		decoration.frame = 0
	else:
		decoration.frame += 1

func _on_scene_started() -> void:
	black_screen.fade_out()

func _on_new_game_selected() -> void:
	yield(black_screen.fade_in(), "tween_completed")
	Save.clear()
	load_next_scene()

func _on_continue_game_selected() -> void:
	var last_scene = Save.get_value("game", "current_scene")
	
	if last_scene:
		yield(black_screen.fade_in(), "tween_completed")
		SceneLoader.load_scene(last_scene)

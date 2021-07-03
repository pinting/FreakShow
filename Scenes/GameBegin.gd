extends "res://Game/BaseScene.gd"

onready var decoration = $Menu/ColorChanger/Decoration
onready var new_game = $Menu/ColorChanger/NewGame
onready var continue_game = $Menu/ColorChanger/ContinueGame

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")
	decoration.connect("direction_changed", self, "_next_decoration_frame")
	new_game.connect("selected", self, "_on_new_game_selected")
	continue_game.connect("selected", self, "_on_continue_game_selected")
	
	VirtualInput.test_mode = true
	VirtualInput.test_keys = ["move_right"]

func _next_decoration_frame():
	var current_animation = decoration.animation
	var last_frame = decoration.frames.get_frame_count(current_animation) - 1
	
	if decoration.frame == last_frame:
		decoration.frame = 0
	else:
		decoration.frame += 1

func _on_scene_started() -> void:
	black_screen.fade_out()
	VirtualCursorManager.move_to_center()

func _on_new_game_selected() -> void:
	yield(black_screen.fade_in(), "tween_completed")
	Save.clear()
	load_next_scene()

func _on_continue_game_selected() -> void:
	var last_scene = Save.get_value("game", "current_scene")
	
	if last_scene:
		yield(black_screen.fade_in(), "tween_completed")
		SceneLoader.load_scene(last_scene)

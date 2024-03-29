extends "res://Game/BaseScene.gd"

onready var new_game = $Menu/NewGame
onready var continue_game = $Menu/ContinueGame

func _ready() -> void:
	new_game.connect("selected", self, "_on_new_game_selected")
	continue_game.connect("selected", self, "_on_continue_game_selected")
	
	VirtualInput.test_keys = {
		"player_right": 1.0,
		"player_left": 0.0
	}

func _on_new_game_selected() -> void:
	CursorManager.lock()
	yield(black_screen.fade_in(), "completed")
	Save.clear()
	load_next_scene()

func _on_continue_game_selected() -> void:
	var last_scene = Save.get_value("game", "current_scene")
	
	if last_scene:
		CursorManager.lock()
		yield(black_screen.fade_in(), "completed")
		SceneLoader.load_scene(last_scene)

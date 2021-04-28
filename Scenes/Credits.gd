extends "res://Scenes/BaseScene.gd"

# Timeout of a credit block
export var credits_timeout: float = 5.0

# Delay between credits
export var credits_delay: float = 2.0

# How many lines of credits to display
export var credits_count: int = 6

# Prefix of the credits entries in the translation file
export var text_prefix = "Cred"

onready var text_bottom = $TextCanvas/Bottom
onready var text_top = $TextCanvas/Top

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")

	disable_auto_restart = true

func _on_scene_started() -> void:
	black_screen.fade_out(2.0)
	yield(Game.timer(credits_delay), "timeout")

	for n in range(0, credits_count):
		var padded_top_index = str("000", 2 * n)
		var padded_bottom_index = str("000", 2 * n + 1)
		var top_index = padded_top_index.right(len(padded_top_index) - 3)
		var bottom_index = padded_bottom_index.right(len(padded_bottom_index) - 3)

		var top = Text.find(text_prefix + top_index)
		var bottom = Text.find(text_prefix + bottom_index)
		
		if not len(top) or not len(bottom):
			continue

		text_top.text = top
		text_bottom.text = bottom

		yield(Game.timer(credits_timeout), "timeout")
		
		text_top.text = ""
		text_bottom.text = ""

		yield(Game.timer(credits_delay), "timeout")
	
	black_screen.fade_in(2.0)
	yield(Game.timer(2.0), "timeout")
	
	load_scene(ProjectSettings.get_setting("application/run/main_scene"))

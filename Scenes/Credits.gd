extends "res://Game/BaseScene.gd"

# Timeout of a credit block
export var credits_timeout: float = 5.0

# Delay between credits
export var credits_delay: float = 2.0

# How many lines of credits to display
export var credits_count: int = 6

# Prefix of the credits entries in the translation file
export var text_prefix = "Credits"

onready var text_bottom = $TextCanvas/Bottom
onready var text_top = $TextCanvas/Top

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started() -> void:
	black_screen.fade_out(2.0)
	yield(Tools.timer(credits_delay), "timeout")

	for n in range(0, credits_count):
		var top_index = Tools.pad_number(2 * n, 3)
		var bottom_index = Tools.pad_number(2 * n + 1, 3)

		var top = Text.find(text_prefix + top_index)
		var bottom = Text.find(text_prefix + bottom_index)
		
		if not len(top) or not len(bottom):
			continue

		text_top.text = top
		text_bottom.text = bottom

		yield(Tools.timer(credits_timeout), "timeout")
		
		text_top.text = ""
		text_bottom.text = ""

		yield(Tools.timer(credits_delay), "timeout")
	
	black_screen.fade_in(2.0)
	yield(Tools.timer(2.0), "timeout")

	var main_scene = ProjectSettings.get_setting("application/run/main_scene")
	
	SceneLoader.load_scene(main_scene)
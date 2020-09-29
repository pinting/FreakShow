extends "res://Scenes/BaseScene.gd"

# Timeout of a credit block
export var credits_timeout: float = 5.0

# Delay between credits
export var credits_delay: float = 2.0

# How many lines of credits to display
export var credits_count: int = 4

onready var text_center = $TextCanvas/Center
onready var text_bottom = $TextCanvas/Bottom
onready var text_top = $TextCanvas/Top

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started() -> void:
	yield(timer(credits_delay), "timeout")

	for n in range(0, credits_count):
		var sn = str(n)
		var prefix = "CREDITS" + (sn if len(sn) > 1 else "0" + sn) + "_"
		var top = tr(prefix + "0")
		var bottom = tr(prefix + "1")
		
		if not len(top) or top == prefix + "0" or not len(bottom) or bottom == prefix + "1":
			continue

		text_top.text = top
		text_bottom.text = bottom

		yield(timer(credits_timeout), "timeout")
		
		text_top.text = ""
		text_bottom.text = ""

		yield(timer(credits_delay), "timeout")
	
	fade_out(2.0)
	yield(timer(2.0), "timeout")
	
	load_scene(ProjectSettings.get_setting("application/run/main_scene"))

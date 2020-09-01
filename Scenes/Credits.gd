extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part00.tscn"

# Delay between credits
export var credits_delay: int = 5.0

# How many lines of credits to display
export var credits_count: int = 4

var music_00: int

func _ready():
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started():
	var id = get_instance_id()

	yield(timer(credits_delay), "timeout")

	for n in range(0, credits_count):
		var sn = str(n)
		var prefix = "CREDITS" + (sn if len(sn) > 1 else "0" + sn) + "_"
		var top = tr(prefix + "0")
		var bottom = tr(prefix + "1")
		
		if not len(top) or top == prefix + "0" or not len(bottom) or bottom == prefix + "1":
			continue

		Global.subtitle.describe(id, top, false)
		Global.subtitle.say(bottom, 0, credits_delay)

		yield(timer(credits_delay), "timeout")

		Global.subtitle.describe(id, "", false)

		yield(timer(2), "timeout")
	
	fade_out(2)
	yield(timer(2), "timeout")
	Global.load_scene(next_scene)

extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part00.tscn"

# Delay between credits
export var credits_delay: int = 5.0

export var credits_count: int = 4

onready var player = $Player
onready var music_mixer = $MusicMixer

var music_00: int

func _ready():
	music_00 = music_mixer.add_part(2, 5 * 60, true, 5, 5, -5)
	
	connect("scene_started", self, "_on_scene_started")
	
	music_mixer.play()

func _on_scene_started():
	var id = get_instance_id()

	yield(timer(credits_delay), "timeout")

	for n in range(0, credits_count):
		var prefix = "CREDITS0" + str(n) + "_"

		Global.subtitle.describe(id, tr(prefix + "0"), false)
		Global.subtitle.say(tr(prefix + "1"), 0, credits_delay)

		yield(timer(credits_delay), "timeout")

		Global.subtitle.describe(id, "", false)

		yield(timer(2), "timeout")

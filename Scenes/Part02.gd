extends "res://Scenes/BaseScene.gd"

onready var connect_sound = $Sound/ConnectSound

var music_00
var music_01

func _ready():
	music_00 = music_mixer.add_part(0, 4 * 60 + 10, false, 0, 20, 0)
	music_01 = music_mixer.add_part(10, 3 * 60 + 20, true, 20, 20, -5)
	
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started():
	if not Global.NO_SOUNDS:
		connect_sound.play()

func _process(delta):
	pass

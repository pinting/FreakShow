extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Credits.tscn"

onready var player = $Player
onready var music_mixer = $MusicMixer

func _ready():
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started():
	yield(timer(2.0), "timeout")
	var door = $Environment/Bottom/Door
	
	door.open()

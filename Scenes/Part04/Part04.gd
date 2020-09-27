extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Credits.tscn"

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

func _ready():
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started():
	pass

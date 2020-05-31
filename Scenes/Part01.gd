extends "res://Scenes/BaseScene.gd"

export var SOUND_SCALE_SECONDS = 10.0

onready var music = $BackgroundMusic
onready var wind = $Wind

var seconds = 0

func _ready():
	music.play()
	wind.play()

func _process(delta):
	var v = delta / SOUND_SCALE_SECONDS
	
	if(music.pitch_scale < 1.0):
		music.pitch_scale += v
		wind.pitch_scale += v

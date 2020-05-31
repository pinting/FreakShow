extends "res://Scenes/BaseScene.gd"

export var SOUND_SCALE_SECONDS = 10.0

onready var intro = $Intro
onready var background_music = $BackgroundMusic
onready var wind = $Wind

var seconds = 0
var sum = 0

func _ready():
	intro.visible = true
	
	background_music.play()
	wind.play()

func _process(delta):
	var v = delta / SOUND_SCALE_SECONDS
	
	if(sum < 1.0):
		background_music.pitch_scale += v
		wind.pitch_scale += v
		sum += v
		
		intro.modulate = Color(0, 0, 0, max(1 - sum, 0))

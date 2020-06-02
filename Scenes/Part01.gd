extends "res://Scenes/BaseScene.gd"

export var FADE_SECONDS = 10.0

onready var intro_darkness = $IntroDarkness
onready var background_music = $BackgroundMusic
onready var wind = $Wind

var sum = 0

func _ready():
	if not Global.DEBUG:
		intro_darkness.visible = true
	
		background_music.play()
		wind.play()

func _process(delta):
	var v = delta / FADE_SECONDS
	
	if sum < 1.0:
		sum += v
		
		# Make vinyl mix sound effect
		background_music.pitch_scale = sum
		wind.pitch_scale = sum
		
		# Make the darkness fade
		intro_darkness.modulate = Color(0, 0, 0, max(1 - sum, 0))

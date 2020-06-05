extends "res://Scenes/BaseScene.gd"

export var FADE_IN_SECONDS = 5

onready var intro_darkness = $IntroDarkness
onready var music_player = $MusicPlayer
onready var wind = $Wind

var sum = 0

func _ready():
	music_player.add_part(0, 3 * 60 + 20, false, 0, 10)
	music_player.add_part(14.3, 3 * 60 + 20, true, 10, 10)
	
	if not Global.DEBUG:
		intro_darkness.visible = true
	
		music_player.start()
		wind.play()

func _process(delta):
	var v = delta / FADE_IN_SECONDS
	
	if sum < 1.0:
		sum += v
		
		# Make vinyl mix sound effect
		music_player.master_player.pitch_scale = sum
		music_player.slave_player.pitch_scale = sum
		wind.pitch_scale = sum
		
		# Make the darkness fade
		intro_darkness.modulate = Color(0, 0, 0, max(1 - sum, 0))

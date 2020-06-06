extends "res://Scenes/BaseScene.gd"

export var FADE_IN_SECONDS = 5

onready var intro = $Intro
onready var music_mixer = $MusicMixer
onready var wind = $Wind

var sum = 0

func _ready():
	music_mixer.add_part(0, 3 * 60 + 20, false, 0, 5)
	music_mixer.add_part(14.3, 3 * 60 + 20, true, 5, 5, -20)
	
	if not Global.NO_INTRO:
		intro.visible = true
		
		music_mixer.master_player.pitch_scale = 0.01
		music_mixer.slave_player.pitch_scale = 0.01
		wind.pitch_scale = 0.01
	
	if not Global.NO_SOUNDS:
		music_mixer.play()
		wind.play()

func _process(delta):
	if Global.NO_INTRO or sum >= 1.0:
		return
	
	sum += delta / FADE_IN_SECONDS
	
	# Make vinyl mix sound effect
	music_mixer.set_pitch_scale(min(sum, 1))
	wind.pitch_scale = min(sum, 1)
	
	# Make the darkness fade
	intro.modulate = Color(0, 0, 0, max(1 - sum, 0))

extends "res://Scenes/BaseScene.gd"

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 10

# Time after the black screen fades out
export var FADE_OUT_AFTER = 2

# Fade out duration
export var FADE_OUT_DURATION = 3

# Length of the intro sound effect
export var LOW_PITCH_LENGTH = 5

onready var black_screen = $BlackScreen
onready var music_mixer = $MusicMixer
onready var wind_sound = $WindSound
onready var player = $Player
onready var ball = $Pickable/Ball
onready var background_train = $Environment/BackgroundTrain

onready var trigger_point_00_train = $Trigger/TriggerPoint00_Train
onready var trigger_point_01_music = $Trigger/TriggerPoint01_Music
onready var trigger_point_02_music = $Trigger/TriggerPoint02_Music

var current_second = 0

func _ready():
	music_mixer.add_part(0, 3 * 60 + 20, true, 0, 10, -30)
	music_mixer.add_part(5 * 60 + 33, 7 * 60 + 27, true, 10, 10, -30)
	music_mixer.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -10)
	
	if not Global.NO_INTRO:
		black_screen.visible = true
		
		music_mixer.master_player.pitch_scale = 0.001
		wind_sound.pitch_scale = 0.001
	
	if not Global.NO_SOUNDS:
		wind_sound.play()
		music_mixer.play()

func _trigger_point_check():
	if trigger_point_00_train:
		var p = trigger_point_00_train.position
		
		if(abs(p.x - player.position.x) < DETECT_THRESHOLD):
			get_parent().remove_child(trigger_point_00_train)
			background_train.start()
	
	if trigger_point_01_music:
		var p = trigger_point_01_music.position
		
		if abs(p.x - player.position.x) < DETECT_THRESHOLD:
			get_parent().remove_child(trigger_point_01_music)
			music_mixer.next_now()
	
	elif trigger_point_02_music:
		var p = trigger_point_02_music.position
		
		var x_diff = abs(p.x - ball.position.x)
		var y_diff = abs(p.y - ball.position.y)
		
		if(x_diff < DETECT_THRESHOLD and y_diff < DETECT_THRESHOLD):
			get_parent().remove_child(trigger_point_02_music)
			music_mixer.next_now()

func _intro(delta):
	if Global.NO_INTRO:
		return
		
	current_second += delta
	
	var pitch_value = current_second / LOW_PITCH_LENGTH
	
	if pitch_value >= 1.0:
		music_mixer.master_player.pitch_scale = 1
		wind_sound.pitch_scale = 1
	else:
		# Make vinyl mix sound effect
		music_mixer.master_player.pitch_scale = min(pitch_value, 1)
		wind_sound.pitch_scale = min(pitch_value, 1)
	
	var fade_out_value = (current_second - FADE_OUT_AFTER) / FADE_OUT_DURATION
	
	if fade_out_value >= 1.0:
		black_screen.modulate = Color(0, 0, 0, 0)
	elif fade_out_value >= 0:
		# Make the black screen fade away
		black_screen.modulate = Color(0, 0, 0, max(1 - fade_out_value, 0))

func _process(delta):
	_intro(delta)
	_trigger_point_check()

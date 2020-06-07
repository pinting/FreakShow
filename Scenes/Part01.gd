extends "res://Scenes/BaseScene.gd"

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 100

# Time after the black screen fades out
export var FADE_OUT_AFTER = 2

# Fade out duration
export var FADE_OUT_DURATION = 3

# Length of the intro sound effect
export var LOW_PITCH_LENGTH = 5

# Seconds to wait for the ball to be stuck
export var BALL_IS_STUCK_TIMEOUT = 2

onready var black_screen = $BlackScreen
onready var music_mixer = $MusicMixer
onready var wind_sound = $WindSound
onready var player = $Player

onready var ball = $Pickable/Ball

onready var background_train = $Environment/BackgroundTrain

onready var trigger_point_00 = $Trigger/TriggerPoint00
onready var trigger_point_01 = $Trigger/TriggerPoint01
onready var trigger_point_02 = $Trigger/TriggerPoint02

var ball_is_stuck_counter = BALL_IS_STUCK_TIMEOUT
var current_second = 0

var music_00
var music_01
var music_02

func _ready():
	music_00 = music_mixer.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = music_mixer.add_part(5 * 60 + 36, 7 * 60 + 27, true, 10, 10, -40)
	music_02 = music_mixer.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -40)
	
	if not Global.NO_INTRO:
		black_screen.visible = true
		
		music_mixer.master_player.pitch_scale = 0.001
		wind_sound.pitch_scale = 0.001
	
	if not Global.NO_SOUNDS:
		wind_sound.play()
		music_mixer.play()

func _trigger_point_check(delta):
	# Background train
	if trigger_point_00.visible:
		var trigger = trigger_point_00.get_global_position()
		var object = player.get_global_position()
		
		if abs(trigger.x - object.x) < DETECT_THRESHOLD:
			trigger_point_00.visible = false
			background_train.start()
	
	# Switch to mysterious music
	if trigger_point_01.visible:
		var trigger = trigger_point_01.get_global_position()
		var object = player.get_global_position()
		
		if abs(trigger.x - object.x) < DETECT_THRESHOLD:
			trigger_point_01.visible = false
			music_mixer.force_next(music_01)
	
	# Switch to action music
	if trigger_point_02.visible:
		var trigger = trigger_point_02.get_global_position()
		var object = ball.get_global_position()
		
		var xd = abs(trigger.x - object.x)
		var yd = abs(trigger.y - object.y)
		
		if xd < DETECT_THRESHOLD and yd < DETECT_THRESHOLD:
			ball_is_stuck_counter -= delta
			
			if ball_is_stuck_counter < 0:
				# Turn off previous trigger point too
				trigger_point_01.visible = false
				trigger_point_02.visible = false
				music_mixer.force_next(music_02)
		else:
			ball_is_stuck_counter = BALL_IS_STUCK_TIMEOUT

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
		black_screen.visible = false
	elif fade_out_value >= 0:
		# Make the black screen fade away
		black_screen.modulate = Color(0, 0, 0, max(1 - fade_out_value, 0))

func _process(delta):
	_intro(delta)
	_trigger_point_check(delta)

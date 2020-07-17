extends "res://Scenes/BaseScene.gd"

# Length of the intro sound effect
export var LOW_PITCH_LENGTH = 5

# Seconds to wait for the ball to be stuck
export var BALL_IS_STUCK_TIMEOUT = 1

# Sound
onready var music_mixer = $Sound/MusicMixer
onready var wind_sound = $Sound/WindSound

# Environment
onready var background_train = $Environment/BackgroundTrain

# Triggers
onready var trigger_point_00 = $Triggers/TriggerPoint00
onready var trigger_point_01 = $Triggers/TriggerPoint01
onready var trigger_point_02 = $Triggers/TriggerPoint02

# Pickable
onready var ball = $Environment/Ball

var ball_is_stuck_counter = BALL_IS_STUCK_TIMEOUT

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

func _process_trigger_points(delta):
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
				ball.mode = RigidBody2D.MODE_STATIC
				music_mixer.force_next(music_02)
		else:
			ball_is_stuck_counter = BALL_IS_STUCK_TIMEOUT

func _process_music_intro(delta):
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

func _process(delta):
	_process_music_intro(delta)
	_process_trigger_points(delta)

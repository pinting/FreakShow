extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part02.tscn"

# Length of the intro sound effect
export var low_pitch_length: float = 10.0

# Seconds to wait for the ball to be stuck
export var ball_is_stuck_timeout: float = 1.0

# Teleport player to the end
export var teleport_player_to_end: bool = false

# Size of a trigger point detect field
export var detect_threshold: float = 15.0

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var background_train = $Environment/BackgroundTrain
onready var ball = $Environment/Ball
onready var phone = $Environment/PhoneBox/Phone
onready var crate = $Environment/Crate

onready var trigger_comment = $Trigger/TriggerComment
onready var trigger_train = $Trigger/TriggerTrain
onready var reaching_hoop = $Trigger/ReachingHoop
onready var inside_hoop = $Trigger/InsideHoop
onready var teleport_player = $Trigger/TeleportPlayer

onready var wind_sound = $Sound/WindSound
onready var ring_sound = $Sound/RingSound
onready var pick_up_sound = $Sound/PickUpSound

var music_00: int
var music_01: int
var music_02: int

var ball_is_stuck_counter = ball_is_stuck_timeout

func _ready():
	music_00 = music_mixer.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = music_mixer.add_part(5 * 60 + 36, 7 * 60 + 27, true, 10, 10, -40)
	music_02 = music_mixer.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -40)
	
	connect("scene_started", self, "_on_scene_started")
	connect("intro_over", self, "_on_intro_over")
	
	music_mixer.master_player.pitch_scale = 0.001
	wind_sound.pitch_scale = 0.001
	
	wind_sound.play()
	
	if teleport_player_to_end:
		player.position = teleport_player.position

func _on_intro_over():
	music_mixer.play()

func _on_scene_started():
	Global.subtitle.say(tr("NARRATOR02"), 6.0)

func _on_phone_selected():
	music_mixer.kill(2.0);
	fade_out(2.0)
	yield(timer(3.0), "timeout")
	ring_sound.stop()
	yield(timer(0.5), "timeout")
	pick_up_sound.play()
	yield(timer(2.0), "timeout")
	Global.load_scene(next_scene)

func _process_trigger_comment(_delta: float):
	if not trigger_comment.visible:
		return
	
	var trigger = trigger_comment.global_position
	var object = player.global_position
	
	if abs(trigger.x - object.x) < detect_threshold:
		trigger_comment.visible = false
		Global.subtitle.say(tr("NARRATOR03"), 6)

func _process_train(_delta: float):
	if not trigger_train.visible:
		return
	
	var trigger = trigger_train.global_position
	var object = player.global_position
	
	if abs(trigger.x - object.x) < detect_threshold:
		trigger_train.visible = false
		background_train.start()

func _process_hoop_scene(_delta: float):
	if not reaching_hoop.visible:
		return
	
	var trigger = reaching_hoop.global_position
	var object = player.global_position
	
	if abs(trigger.x - object.x) < detect_threshold:
		reaching_hoop.visible = false
		music_mixer.force_next(music_01)

func _process_ball_in_hoop(delta: float):
	if not inside_hoop.visible:
		return
	
	var trigger = inside_hoop.global_position
	var object = ball.global_position
	
	var xd = abs(trigger.x - object.x)
	var yd = abs(trigger.y - object.y)
	
	if xd < detect_threshold and yd < detect_threshold:
		ball_is_stuck_counter -= delta
		
		if ball_is_stuck_counter < 0.0:
			# Turn off previous trigger point too
			reaching_hoop.visible = false
			inside_hoop.visible = false
			ball.mode = RigidBody2D.MODE_STATIC
			
			ring_sound.play()
			music_mixer.force_next(music_02)
			phone.visible = true
			
			yield(timer(2.0), "timeout")
			Global.subtitle.say(tr("NARRATOR04"), 2.0, 12.0)
			phone.connect("selected", self, "_on_phone_selected")
	else:
		ball_is_stuck_counter = ball_is_stuck_timeout

func _process_wind_intro(_delta):
	if Global.NO_INTRO:
		return
	
	# Make vinyl sound effect
	var pitch_value = current_second / low_pitch_length
	
	if pitch_value >= 1.0:
		wind_sound.pitch_scale = 1.0
		music_mixer.master_player.pitch_scale = 1.0
	else:
		wind_sound.pitch_scale = max(min(pitch_value, 1.0), 0.001)
		music_mixer.master_player.pitch_scale = max(min(pitch_value, 1.0), 0.001)

func _process(delta):
	_process_wind_intro(delta)
	_process_trigger_comment(delta)
	_process_train(delta)
	_process_hoop_scene(delta)
	_process_ball_in_hoop(delta)

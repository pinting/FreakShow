class_name BackgroundTrain
extends Node2D

# Start the train from X set in Editor minus this
export var start_from: float = 15000.0

# Speed to move on the X axis
export var speed: float = 25.0

# Destory the train from X set in Editor plus this
export var stop_after: float = 50000.0

# Amplitude of the shake (Y axis)
export var shake_amp: float = 0.1

# Number of shakes (X axis)
export var shake_count: float = 15.0

# Difference in rhythem per train
export var rhythm_diff: float = 0.33

onready var train_00 = $Train00
onready var audio_stream_00 = $Train00/AudioStreamPlayer2D

onready var train_01 = $Train01
onready var audio_stream_01 = $Train01/AudioStreamPlayer2D

onready var train_02 = $Train02
onready var audio_stream_02 = $Train02/AudioStreamPlayer2D

var started: bool = false
var current_second: float = 0.0
var base_position: Vector2 = Vector2(0.0, 0.0)

func _ready():
	visible = false

func start():
	base_position = global_position
	
	position.x -= start_from
	visible = true
	started = true
	
	audio_stream_00.play()
	audio_stream_01.play()
	audio_stream_02.play()

func _process(delta):
	var self_position = global_position
	
	if not started:
		return
	
	current_second += delta

	var s = current_second
	var m = shake_amp
	var c = shake_count
	
	train_00.position.y += m * sin(c * s + 0.0 * rhythm_diff) * randf()
	train_01.position.y += m * sin(c * s + 1.0 * rhythm_diff) * randf()
	train_02.position.y += m * sin(c * s + 2.0 * rhythm_diff) * randf()
	
	position.x += speed

	if abs(base_position.x - self_position.x) > stop_after:
		started = false
		visible = false
		
		audio_stream_00.stop()
		audio_stream_01.stop()
		audio_stream_02.stop()

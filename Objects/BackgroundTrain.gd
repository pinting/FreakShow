extends Node2D

# Start the train from X set in Editor minus this
export var START_FROM = 15000

# Speed to move on the X axis
export var SPEED = 25

# Destory the train from X set in Editor plus this
export var STOP_AFTER = 50000

# Amplitude of the shake (Y axis)
export var SHAKE_AMP = 0.1

# Number of shakes (X axis)
export var SHAKE_COUNT = 15

# Difference in rhythem per train
export var RHYTHM_DIFF = 0.33

onready var train_00 = $Train00
onready var audio_stream_00 = $Train00/AudioStreamPlayer2D

onready var train_01 = $Train01
onready var audio_stream_01 = $Train01/AudioStreamPlayer2D

onready var train_02 = $Train02
onready var audio_stream_02 = $Train02/AudioStreamPlayer2D

var _started = false
var _current_second = 0
var _base_position = Vector2(0, 0)

func _ready():
	visible = false

func start():
	_base_position = get_global_position()
	
	position.x -= START_FROM
	visible = true
	_started = true
	
	if not Global.NO_SOUNDS:
		audio_stream_00.play()
		audio_stream_01.play()
		audio_stream_02.play()

func _process(delta):
	var self_position = get_global_position()
	
	if not _started:
		return
	
	_current_second += delta

	var s = _current_second
	var m = SHAKE_AMP
	var c = SHAKE_COUNT
	
	train_00.position.y += m * sin(c * s + 0 * RHYTHM_DIFF) * randf()
	train_01.position.y += m * sin(c * s + 1 * RHYTHM_DIFF) * randf()
	train_02.position.y += m * sin(c * s + 2 * RHYTHM_DIFF) * randf()
	
	position.x += SPEED

	if abs(_base_position.x - self_position.x) > STOP_AFTER:
		_started = false
		visible = false
		
		audio_stream_00.stop()
		audio_stream_01.stop()
		audio_stream_02.stop()

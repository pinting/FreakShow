extends Node2D

# Size of the detect interval
export var DETECT_THRESHOLD = 10

# Start the train from X set in Editor minus this
export var START_FROM = 15000

# Speed to move on the X axis
export var SPEED = 20

# Destory the rain after this X + TriggerPoint.X
export var DESTROY_AFTER = 15000

# Amplitude of the shake (Y axis)
export var SHAKE_AMP = 0.1

# Number of shakes (X axis)
export var SHAKE_COUNT = 15

# Difference in rhythem per train
export var RHYTHM_DIFF = 0.33

onready var trigger_point = $TriggerPoint

onready var train_00 = $Train00
onready var audio_stream_00 = $Train00/AudioStreamPlayer2D

onready var train_01 = $Train01
onready var audio_stream_01 = $Train01/AudioStreamPlayer2D

onready var train_02 = $Train02
onready var audio_stream_02 = $Train02/AudioStreamPlayer2D

var started = false
var current_second = 0

func start():
	position.x -= START_FROM
	visible = true
	started = true
	
	if(!Global.DEBUG):
		audio_stream_00.play()
		audio_stream_01.play()
		audio_stream_02.play()

func move():
	var s = current_second
	var m = SHAKE_AMP
	var c = SHAKE_COUNT
	
	train_00.position.y += m * sin(c * s + 0 * RHYTHM_DIFF)
	train_01.position.y += m * sin(c * s + 1 * RHYTHM_DIFF)
	train_02.position.y += m * sin(c * s + 2 * RHYTHM_DIFF)
	
	position.x += SPEED

func _ready():
	visible = false

func _process(delta):
	var player_position = Global.player_position
	var trigger_position = trigger_point.get_global_position()
	var self_position = get_global_position()
	
	current_second += delta
	
	if(!started && abs(trigger_position.x - player_position.x) < DETECT_THRESHOLD):
		start()
	
	if(started):
		move()
	
		if(abs(trigger_position.x - self_position.x) > DESTROY_AFTER):
			get_parent().remove_child(self)

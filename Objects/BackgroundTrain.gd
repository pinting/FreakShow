extends Node2D

export var DISTANCE_THRESHOLD = 10
export var BEFORE = 15000
export var SPEED = 20
export var DESTROY_AFTER = 15000
export var SHAKE_STRENGTH = 0.33
export var SHAKE_COUNT = 15

onready var audio_stream_00 = $Train00/AudioStreamPlayer2D
onready var audio_stream_01 = $Train01/AudioStreamPlayer2D
onready var audio_stream_02 = $Train02/AudioStreamPlayer2D
onready var trigger_point = $TriggerPoint

var started = false
var seconds = 0

func _ready():
	visible = false
	pass

func _process(delta):
	var player_position = Global.player_position
	var trigger_position = trigger_point.get_global_position()
	var self_position = get_global_position()
	
	seconds += delta
	
	position.y += SHAKE_STRENGTH * sin(SHAKE_COUNT * seconds)
	
	if(!started && abs(trigger_position.x - player_position.x) < DISTANCE_THRESHOLD):
		position.x -= BEFORE
		visible = true
		started = true
		
		audio_stream_00.play()
		audio_stream_01.play()
		audio_stream_02.play()
	
	if(started):
		position.x += SPEED
		
		if(abs(trigger_position.x - self_position.x) > DESTROY_AFTER):
			get_parent().remove_child(self)

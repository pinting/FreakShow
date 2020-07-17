extends "res://Scenes/BaseScene.gd"

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 15

# Time after the black screen fades out
export var FADE_OUT_AFTER = 2

# Fade out duration
export var FADE_OUT_DURATION = 3

# Delay to wait before starting the game (if intro is ON)
export var START_DELAY = 1

onready var black_screen = $BlackScreen
onready var player = $Player
onready var camera = $Player/Camera

# Triggers
onready var loop_begin = $Triggers/LoopBegin
onready var loop_end = $Triggers/LoopEnd

var current_second = 0
var delay = 0

func _trigger_point_check(delta):
	var left_end_position = loop_begin.get_global_position()
	var right_end_position = loop_end.get_global_position()
	var player_position = player.get_global_position()
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)
	
func _intro(delta):
	if Global.NO_INTRO:
		return
	
	delay += delta
	
	if delay < START_DELAY:
		return
	
	current_second += delta
	
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

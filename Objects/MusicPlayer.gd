class_name MusicPlayer
extends Node

# Should the parts repeat
export var GLOBAL_LOOP = false

# Playing volume in DB
export var MAX_VOLUME = 0

# Muting volume in DB
export var MIN_VOLUME = -60

# Epsilon used for comparison
export var EPS = 0.1

onready var player_00 = $AudioStreamPlayer00
onready var player_01 = $AudioStreamPlayer01

var master_player = null
var slave_player = null

var stopped = true
var next = false
var parts = []

var current_part_index = 0
var break_loop = false # Wait until the end
var break_loop_now = false # Break it ASAP
var mixing = false

func _ready():
	pass

func add_part(start, end, loop, fade_in, fade_out):
	var new_part = {
		"start": start,
		"end": end,
		"loop": loop,
		"fade_in": fade_in if fade_in > EPS else EPS,
		"fade_out": fade_out if fade_out > EPS else EPS
	}
	
	parts.append(new_part)
	
func start():
	if len(parts) > 0:
		master_player = player_00
		master_player.volume_db = MAX_VOLUME
		
		slave_player = player_01
		slave_player.volume_db = MIN_VOLUME
		
		master_player.play(parts[0].start)
		slave_player.play(0)
		
		break_loop = false
		break_loop_now = false
		stopped = false
		current_part_index = 0
	
func get_next():
	if len(parts) > current_part_index + 1:
		return current_part_index + 1
	elif GLOBAL_LOOP:
		return 0
	else:
		return -1

func stop_loop():
	break_loop = true
	
func stop_loop_now():
	break_loop = true
	break_loop_now = true

func _process(delta):
	if stopped:
		return
	
	var next_part_index = current_part_index
	var current_part = parts[current_part_index]
	
	var position = master_player.get_playback_position()
	var position_diff = abs(current_part.end - position)
	
	if not current_part.loop or break_loop:
		next_part_index = get_next()
	
	if next_part_index < 0:
		if position_diff < EPS:
			master_player.stop()
			slave_player.stop()
			
			stopped = true
		
		return
	
	var next_part = parts[next_part_index]
	
	if not break_loop_now and position_diff > current_part.fade_out + next_part.fade_in:
		return
	
	# Start the second track and start mixing
	var finished = _do_mixing(delta, current_part, next_part)
	
	# Finish mixing
	if finished:
		_finish_mixing(next_part_index)

func _do_mixing(delta, current_part, next_part):
	if not mixing:
		slave_player.play(next_part.start)
		mixing = true
	
	var volume_diff = abs(MAX_VOLUME - MIN_VOLUME)
	
	if abs(MAX_VOLUME - slave_player.volume_db) > EPS:
		# Increase next part volume until max
		slave_player.volume_db += volume_diff * (delta / next_part.fade_in)
	elif abs(MIN_VOLUME - master_player.volume_db) > EPS:
		# Start to decrease the current part volume until min
		master_player.volume_db -= volume_diff * (delta / current_part.fade_out)
	else:
		return true
		
	return false

func _finish_mixing(next_part_index):
		# Swap players
		var temp = master_player
		
		master_player = slave_player
		slave_player = temp
		
		# Finalize swap by fixing volume
		master_player.volume_db = MAX_VOLUME
		slave_player.volume_db = MIN_VOLUME
		
		# Set the next part as current and stop mixing
		current_part_index = next_part_index
		break_loop = false
		break_loop_now = false
		mixing = false

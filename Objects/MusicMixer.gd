class_name MusicMixer
extends Node

# Playback stream
export (AudioStream) var STREAM

# Should the whole thing repeat
export var LOOP = false

# If auto play
export var AUTOPLAY = false

# Playing volume in DB
export var MAX_VOLUME = 0

# Muting volume in DB
export var MIN_VOLUME = -60

# Parts of the music
export var PARTS = []

# Debug the music player (Global.DEBUG needs to be true)
export var DEBUG = false

const EPS = 0.05

onready var player_00 = $AudioStreamPlayer00
onready var player_01 = $AudioStreamPlayer01

var master_player = null
var slave_player = null
var stopped = true
var parts = PARTS

var _current_part_index = 0
var _playback_prev_position = 0
var _playback_prev_diff = 0
var _virtual_position = 0
var _break_loop = false # Wait until the end
var _break_loop_now = false # Break it ASAP
var _forced_next = null # Index of the next part
var _mixing = false
var _kill_timeout = 0
var _kill = false

func _ready():
	master_player = player_00
	master_player.stream = STREAM
	master_player.volume_db = MIN_VOLUME
	
	slave_player = player_01
	slave_player.stream = STREAM
	slave_player.volume_db = MIN_VOLUME
	
	if AUTOPLAY:
		play()

func add_part(start, end, loop, in_duration, out_duration, offset = 0):
	# A part needs to start earlier than end
	assert(start < end)
	
	# The N + 1 part can only start fading out after the N ended
	assert(end - start - out_duration + offset > 0)
	
	var new_part = {
		# At start the fade in will start
		"start": start,
		# At end the fade out will end
		"end": end,
		# If the part is looped, so the next is the current
		"loop": loop,
		# Duration of the fade in effect
		"in_duration": in_duration if in_duration > EPS else EPS,
		# Duration of the fade out effect
		"out_duration": out_duration if out_duration > EPS else EPS,
		# Offset the start to the previous one
		# This does not apply to the first played part
		# Too large offset can break the mixer
		"offset": offset
	}
	
	parts.append(new_part)
	
	return len(parts) - 1

func kill(timeout = 5):
	_kill = true
	_kill_timeout = timeout

func play():
	if len(parts) == 0:
		return
	
	master_player.play(parts[0].start)
	
	stopped = false
	_current_part_index = 0
	
	_playback_prev_position = parts[0].start
	_virtual_position = parts[0].start
	_break_loop = false
	_break_loop_now = false
	_mixing = false
	_kill = false
	_kill_timeout = 0

func get_next():
	var current_part = parts[_current_part_index]
	
	if _kill:
		return -1
	elif _forced_next != null:
		assert(len(parts) > _forced_next)
		return _forced_next
	elif current_part.loop and not _break_loop:
		return _current_part_index
	elif len(parts) > _current_part_index + 1:
		return _current_part_index + 1
	elif LOOP:
		return 0
	else:
		return -1

func force_next(value):
	if _mixing:
		_finish_mixing(get_next())
		
	_forced_next = value
	_break_loop_now = true
	_break_loop = true

func _process(delta):
	if stopped:
		return
	
	var playback_position_now = master_player.get_playback_position()
	var position_diff = _playback_prev_position - playback_position_now
	
	_playback_prev_position = playback_position_now
	
	if position_diff > 0:
		position_diff = _playback_prev_diff
	else:
		_playback_prev_diff = position_diff
	
	_virtual_position += abs(position_diff)
	
	var current_part = parts[_current_part_index]
	
	var diff_to_start = current_part.start - _virtual_position
	var diff_to_end = current_part.end - _virtual_position
	
	# If kill is set, start to act like diff_to_end is near
	if _kill:
		diff_to_end = _kill_timeout
		_kill_timeout -= delta
	
	_debug_if_integer(diff_to_start, str(round(diff_to_start), " / ", round(diff_to_end)))
	
	var volume_diff = abs(MAX_VOLUME - MIN_VOLUME)
	
	# Fade in the current part 
	if not _break_loop_now and diff_to_start < 0:
		if abs(diff_to_start) < current_part.in_duration:
			master_player.volume_db += volume_diff * (delta / current_part.in_duration)
			_debug_if_integer(diff_to_start, str("master fade in ", master_player.volume_db))
		elif abs(diff_to_end) > current_part.out_duration:
			master_player.volume_db = MAX_VOLUME
			_debug_if_integer(diff_to_start, "master max volume")
	
	# Fade out the current part 
	if abs(diff_to_end) < current_part.out_duration:
		master_player.volume_db -= volume_diff * (delta / current_part.out_duration)
		_debug_if_integer(diff_to_start, str("master fade out ", master_player.volume_db))
	elif diff_to_end < 0:
		master_player.volume_db = MIN_VOLUME
		_debug_if_integer(diff_to_start, "master min volume")
	
	# Determinate if the current or the next part should be played as next
	var next_part_index = get_next()
	
	# If no next part is present and we are close to the end, stop
	if next_part_index == -1:
		if diff_to_end < 0:
			master_player.stop()
			slave_player.stop()
			stopped = true
		
		return
	
	var next_part = parts[next_part_index]
	
	# Start mix in slave if end + offset is reached
	if _break_loop_now or diff_to_end + next_part.offset < 0:
		if not _mixing:
			slave_player.play(next_part.start)
			slave_player.volume_db = MIN_VOLUME
			_mixing = true
		
		if _mixing:
			if slave_player.volume_db < MAX_VOLUME:
				slave_player.volume_db += volume_diff * (delta / next_part.in_duration)
				_debug_if_integer(diff_to_end, str("slave fade in ", slave_player.volume_db))
			elif diff_to_end < 0:
				_finish_mixing(next_part_index)
			elif _break_loop_now:
				if master_player.volume_db > MIN_VOLUME:
					master_player.volume_db -= volume_diff * (delta / current_part.out_duration)
					_debug_if_integer(diff_to_start, str("master fade out ", master_player.volume_db))
				else:
					_finish_mixing(next_part_index)

func _finish_mixing(next_part_index):
	_debug(str("new master index ", next_part_index))
	
	# Swap players
	var temp = master_player
	
	master_player = slave_player
	slave_player = temp
	
	# Fix volumes
	master_player.volume_db = MAX_VOLUME
	slave_player.volume_db = MIN_VOLUME
	
	# Set the next part as current and stop mixing
	_current_part_index = next_part_index
	
	_virtual_position = master_player.get_playback_position()
	_playback_prev_position = _virtual_position
	_break_loop = false
	_break_loop_now = false
	_forced_next = null
	_mixing = false

func _debug(message):
	if DEBUG:
		Global.debug(message)

func _debug_if_integer(t, message):
	if abs(floor(t) - t) < 0.05:
		_debug(message)

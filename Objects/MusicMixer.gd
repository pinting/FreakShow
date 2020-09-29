class_name MusicMixer
extends Node

# Playback stream
export var stream: AudioStream

# Should the whole thing repeat
export var loop: bool = false

# If auto play
export var autoplay: bool = false

# Playing volume in DB
export var max_volume: int = 0

# Muting volume in DB
export var min_volume: int = -60

# Debug the music player (Global.debug needs to be true)
export var debug: bool = false

onready var player_00 = $AudioStreamPlayer00
onready var player_01 = $AudioStreamPlayer01

var master_player: AudioStreamPlayer = null
var slave_player: AudioStreamPlayer = null
var stopped: bool = true
var paused: bool = false
var parts: Array = []

var current_part_index: int = 0.0
var playback_prev_position: float = 0.0
var playback_prev_diff: float = 0.0
var virtual_position: float = 0.0
var break_loop: bool = false # Wait until the end
var break_loop_now: bool = false # Break it ASAP
var forced_next: int = -1 # Index of the next part
var mixing: bool = false
var kill_timeout: float = 0.0
var kill: bool = false

func _ready():
	master_player = player_00
	master_player.stream = stream
	master_player.volume_db = min_volume
	
	slave_player = player_01
	slave_player.stream = stream
	slave_player.volume_db = min_volume
	
	if autoplay:
		play()

func add_part(start: float, end: float, loop: bool, in_duration: float, out_duration: float, offset: float = 0.0):
	# A part needs to start earlier than end
	assert(start < end)
	
	# The N + 1 part can only start fading out after the N ended
	assert(end - start - out_duration + offset > 0.0)
	
	var new_part = {
		# At start the fade in will start
		"start": start,
		# At end the fade out will end
		"end": end,
		# If the part is looped, so the next is the current
		"loop": loop,
		# Duration of the fade in effect
		"in_duration": in_duration,
		# Duration of the fade out effect
		"out_duration": out_duration,
		# Offset the start to the previous one
		# This does not apply to the first played part
		# Too large offset can break the mixer
		"offset": offset
	}
	
	parts.append(new_part)
	
	return len(parts) - 1

func kill(timeout: float = 5.0):
	kill = true
	kill_timeout = timeout

func play():
	if len(parts) == 0:
		return
	
	if parts[0].in_duration == 0.0:
		master_player.volume_db = max_volume
		slave_player.volume_db = min_volume
	
	master_player.play(parts[0].start)
	
	stopped = false
	paused = false
	current_part_index = 0
	
	playback_prev_position = parts[0].start
	virtual_position = parts[0].start
	break_loop = false
	break_loop_now = false
	mixing = false
	kill = false
	kill_timeout = 0.0

func pause():
	if stopped:
		return
	
	paused = true
	master_player.stream_paused = true
	slave_player.stream_paused = true

func resume():
	if stopped:
		return
	
	paused = false
	master_player.stream_paused = false
	slave_player.stream_paused = false

func get_next():
	var current_part = parts[current_part_index]
	
	if kill:
		return -1
	elif forced_next >= 0:
		assert(len(parts) > forced_next)
		return forced_next
	elif current_part.loop and not break_loop:
		return current_part_index
	elif len(parts) > current_part_index + 1:
		return current_part_index + 1
	elif loop:
		return 0
	else:
		return -1

func force_next(index: int):
	if mixing:
		_finish_mixing(get_next())
		
	forced_next = index
	break_loop_now = true
	break_loop = true

func _process(delta: float):
	if stopped or paused:
		return
	
	var playback_position_now = master_player.get_playback_position()
	var position_diff = playback_prev_position - playback_position_now
	
	playback_prev_position = playback_position_now
	
	if position_diff > 0.0:
		position_diff = playback_prev_diff
	else:
		playback_prev_diff = position_diff
	
	virtual_position += abs(position_diff)
	
	var current_part = parts[current_part_index]
	
	var diff_to_start = current_part.start - virtual_position
	var diff_to_end = current_part.end - virtual_position
	
	# If kill is set, start to act like diff_to_end is near
	if kill:
		diff_to_end = kill_timeout
		kill_timeout -= delta
	
	_debug_if_integer(diff_to_start, str(round(diff_to_start), " / ", round(diff_to_end)))
	
	var volume_diff = abs(max_volume - min_volume)
	
	# Fade in the current part 
	if not break_loop_now and diff_to_start < 0:
		if abs(diff_to_start) < current_part.in_duration and current_part.in_duration > 0:
			master_player.volume_db += volume_diff * (delta / current_part.in_duration)
			_debug_if_integer(diff_to_start, str("master fade in ", master_player.volume_db))
		elif abs(diff_to_end) > current_part.out_duration:
			master_player.volume_db = max_volume
			_debug_if_integer(diff_to_start, "master max volume")
	
	# Fade out the current part 
	if diff_to_end > 0 and abs(diff_to_end) < current_part.out_duration and current_part.out_duration > 0:
		master_player.volume_db -= volume_diff * (delta / current_part.out_duration)
		_debug_if_integer(diff_to_start, str("master fade out ", master_player.volume_db))
	elif diff_to_end <= 0:
		master_player.volume_db = min_volume
		_debug_if_integer(diff_to_start, "master min volume")
	
	# Determinate if the current or the next part should be played as next
	var next_part_index = get_next()
	
	# If no next part is present and we are close enough to the end, stop
	if next_part_index == -1:
		if diff_to_end < 0:
			master_player.stop()
			slave_player.stop()
			stopped = true
		
		return
	
	var next_part = parts[next_part_index]
	
	# Start mix in slave if end + offset is reached
	if break_loop_now or diff_to_end + next_part.offset < 0:
		if not mixing:
			slave_player.play(next_part.start)
			slave_player.volume_db = min_volume
			mixing = true
		
		if mixing:
			if slave_player.volume_db < max_volume:
				if next_part.in_duration > 0:
					slave_player.volume_db += volume_diff * (delta / next_part.in_duration)
				else:
					slave_player.volume_db += volume_diff
				
				_debug_if_integer(diff_to_end, str("slave fade in ", slave_player.volume_db))
			elif diff_to_end < 0:
				_finish_mixing(next_part_index)
			elif break_loop_now:
				if master_player.volume_db > min_volume:
					if current_part.out_duration > 0:
						master_player.volume_db -= volume_diff * (delta / current_part.out_duration)
					else:
						master_player.volume_db -= volume_diff
					
					_debug_if_integer(diff_to_start, str("master fade out ", master_player.volume_db))
				else:
					_finish_mixing(next_part_index)

func _finish_mixing(next_part_index: int):
	_debug(str("new master index ", next_part_index))
	
	# Swap players
	var temp = master_player
	
	master_player = slave_player
	slave_player = temp
	
	# Fix volumes
	master_player.volume_db = max_volume
	slave_player.volume_db = min_volume
	
	# Set the next part as current and stop mixing
	current_part_index = next_part_index
	
	virtual_position = master_player.get_playback_position()
	playback_prev_position = virtual_position
	break_loop = false
	break_loop_now = false
	forced_next = -1
	mixing = false

func _debug(message: String):
	if debug:
		Global.debug(message)

func _debug_if_integer(t: float, message: String):
	if abs(floor(t) - t) < 0.05:
		_debug(message)

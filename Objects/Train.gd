class_name Train
extends StaticBody2D

# Sound of the train
export var train_sound: AudioStream

# Start the train using this X offset
export var start_from: float = -15000.0

# Speed and direction to move on the X axis
export var speed: float = 1600.0

# Stop the train after this dinstance to the player
export var stop_after_player_diff: float = 25000.0

# Amplitude of the shake (Y axis)
export var shake_amp: float = 2.0

# Number of shakes (X axis)
export var shake_count: float = 15.0

# Difference in rhythem per train
export var rhythm_diff: float = 0.33

# Maximum pitch diff
export var max_pitch_diff: float = 0.25

# Seconds the player will pick up the speed of the train
export var speed_scale_m: float = 2.5

# How fast the volume should fade in
export var fade_in_volume_per_s: float = 80

onready var on_top = $OnTop

onready var train_00 = $Train00
onready var audio_stream_00 = $Noise00
onready var collision_00 = $CollisionShape00
onready var on_top_collision_00 = $OnTop/CollisionShape00

onready var train_01 = $Train01
onready var audio_stream_01 = $Noise01
onready var collision_01 = $CollisionShape01
onready var on_top_collision_01 = $OnTop/CollisionShape01

onready var train_02 = $Train02
onready var audio_stream_02 = $Noise02
onready var collision_02 = $CollisionShape02
onready var on_top_collision_02 = $OnTop/CollisionShape02

signal stopped
signal player_on_top

var started: bool = false
var enable_sound: bool = true
var current_second: float = 0.0
var last_position_diff: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2(0.0, 0.0)
var exit_list_player = []
var exit_list_skip_stick = []
var enter_list_player = []
var enter_list_speed_scale = []

func _ready() -> void:
	on_top.connect("body_exited", self, "_player_exited_top")
	on_top.connect("body_entered", self, "_player_entered_top")
	
	visible = false
	base_position = global_position
	
	if train_sound:
		audio_stream_00.stream = train_sound
		audio_stream_01.stream = train_sound
		audio_stream_02.stream = train_sound

func _player_entered_top(player: Node):
	if not player.is_in_group("player") or enter_list_player.find(player) >= 0:
		return
	
	emit_signal("player_on_top")
	
	enter_list_player.push_back(player)
	enter_list_speed_scale.push_back(0.0)

func _player_exited_top(player: Node):
	if not player.is_in_group("player") or exit_list_player.find(player) >= 0:
		return
	
	exit_list_player.push_back(player)
	exit_list_skip_stick.push_back(true)

func start() -> void:
	position.x = base_position.x + start_from
	visible = true
	
	audio_stream_00.pitch_scale = _generate_pitch_scale()
	audio_stream_01.pitch_scale = audio_stream_00.pitch_scale
	audio_stream_02.pitch_scale = audio_stream_00.pitch_scale
	
	resume()

func pause() -> void:
	started = false
	
	if enable_sound:
		audio_stream_00.stop()
		audio_stream_01.stop()
		audio_stream_02.stop()

func _generate_pitch_scale():
	return Game.random_generator.randf_range(1.0 - max_pitch_diff, 1.0 + max_pitch_diff)

func resume() -> void:
	if not visible:
		return
	
	started = true
	
	if enable_sound:
		audio_stream_00.volume_db = -80
		audio_stream_01.volume_db = -80
		audio_stream_02.volume_db = -80
		
		audio_stream_00.play()
		audio_stream_01.play()
		audio_stream_02.play()

func stop():
	pause()
	
	visible = false

func destroy():
	# This might reduce the number of crashes
	on_top_collision_00.disabled = true
	collision_00.disabled = true
	
	on_top_collision_01.disabled = true
	collision_01.disabled = true
	
	on_top_collision_02.disabled = true
	collision_02.disabled = true
	
	get_parent().remove_child(self)
	queue_free()

func _process_exit_list() -> void:
	var new_list_player = []
	var new_list_skipped_tick = []
	
	while len(exit_list_player) > 0:
		var player = exit_list_player.pop_back()
		var skip_tick = exit_list_skip_stick.pop_back()
		
		if skip_tick:
			new_list_player.push_back(player)
			new_list_skipped_tick.push_back(false)
			continue
		
		if on_top.overlaps_body(player):
			continue
		
		if started:
			player.current_velocity.x = speed
		
		var index = enter_list_player.find(player)
		
		if index >= 0:
			enter_list_player.remove(index)
			enter_list_speed_scale.remove(index)
	
	exit_list_player = new_list_player
	exit_list_skip_stick = new_list_skipped_tick

func _process_train_movement(delta: float) -> void:
	var s = current_second
	var m = shake_amp
	var c = shake_count
	
	var diff_00 = m * sin(c * s + 0.0 * rhythm_diff) * randf()
	var diff_01 = m * sin(c * s + 1.0 * rhythm_diff) * randf()
	var diff_02 = m * sin(c * s + 1.0 * rhythm_diff) * randf()
	
	train_00.position.y += diff_00
	train_01.position.y += diff_01
	train_02.position.y += diff_02
	
	collision_00.position.y += diff_00
	collision_01.position.y += diff_01
	collision_02.position.y += diff_02
	
	on_top_collision_00.position.y += diff_00
	on_top_collision_01.position.y += diff_01
	on_top_collision_02.position.y += diff_02
	
	var position_diff = speed * delta
	
	position.x += position_diff

func _process_player_on_top(delta: float) -> void:
	var position_diff = speed * delta
	
	for index in range(len(enter_list_player)):
		var player = enter_list_player[index]
		var speed_scale = enter_list_speed_scale[index]

		if not player or player.dead or Game.loader:
			exit_list_player.push_back(player)
			exit_list_skip_stick.push_back(false)
			continue
		
		player.position.x += position_diff * speed_scale
		enter_list_speed_scale[index] = min(1.0, speed_scale + delta * speed_scale_m)
		
		if player.current_velocity.x > player.current_max_speed:
			player.current_velocity.x -= player.current_max_speed * delta

func _process_fade_in(delta: float) -> void:
	if not enable_sound:
		return
	
	var d = delta * fade_in_volume_per_s
	
	audio_stream_00.volume_db = min(0, audio_stream_00.volume_db + d)
	audio_stream_01.volume_db = min(0, audio_stream_01.volume_db + d)
	audio_stream_02.volume_db = min(0, audio_stream_02.volume_db + d)

func _process_recycle() -> void:
	var source_position = base_position
	
	for player in Game.players:
		source_position = player.global_position
		break
	
	if source_position.distance_to(global_position) > stop_after_player_diff:
		stop()
		destroy()

func _process(delta: float) -> void:
	if not started or Game.loader:
		return
	
	current_second += delta
	
	_process_fade_in(delta)
	_process_exit_list()
	_process_train_movement(delta)
	_process_player_on_top(delta)
	_process_recycle()

extends StaticBody2D

# Sound of the train
export var train_sound: AudioStream

# Start the train using this X offset
export var offset: Vector2 = Vector2(-15000.0, 0)

# Speed and direction to move on the X axis
export var speed: float = 1600.0

# Recycle the train after this dinstance to the player
export var recycle_after_distance_to_player: float = 50000.0

# Amplitude of the shake (Y axis)
export var shake_amp: float = 1.5

# Number of shakes (X axis)
export var shake_count: float = 15.0

# Difference in rhythem per train
export var rhythm_diff: float = 0.33

# Maximum pitch diff
export var max_pitch_diff: float = 0.25

# Seconds the player will pick up the speed of the train
export var speed_scale_m: float = 2.5

# Disable running-on-top physics script
export var no_custom_physics: bool = false

onready var tween = $Tween

onready var train_00 = $Train00
onready var sound_00 = $Sound00
onready var collision_00 = $CollisionShape00
onready var on_top_collision_00 = $OnTop/CollisionShape00

onready var train_01 = $Train01
onready var sound_01 = $Sound01
onready var collision_01 = $CollisionShape01
onready var on_top_collision_01 = $OnTop/CollisionShape01

onready var train_02 = $Train02
onready var sound_02 = $Sound02
onready var collision_02 = $CollisionShape02
onready var on_top_collision_02 = $OnTop/CollisionShape02

onready var on_top = $OnTop

signal stopped
signal player_on_top

var started: bool = false
var current_second: float = 0.0
var last_position_diff: Vector2 = Vector2.ZERO

var base_position: Vector2

var exit_list_player = []
var exit_list_skip_stick = []
var enter_list_player = []
var enter_list_speed_scale = []

const silent = -100.0
const silence_duration = 2.0

func _ready() -> void:
	visible = false
	
	on_top.connect("body_exited", self, "_player_exited_top")
	on_top.connect("body_entered", self, "_player_entered_top")
	
	base_position = global_position
	
	if train_sound:
		sound_00.stream = train_sound
		sound_01.stream = train_sound
		sound_02.stream = train_sound

func _player_entered_top(player: Node):
	if no_custom_physics:
		return
	
	if not player.is_in_group("player") or enter_list_player.find(player) >= 0:
		return
	
	emit_signal("player_on_top")
	
	enter_list_player.push_back(player)
	enter_list_speed_scale.push_back(0.0)

func _player_exited_top(player: Node):
	if no_custom_physics:
		return
	
	if not player.is_in_group("player") or exit_list_player.find(player) >= 0:
		return
	
	exit_list_player.push_back(player)
	exit_list_skip_stick.push_back(true)

func start() -> void:
	Tools.debug("Train start called")
	
	global_position = base_position + offset
	visible = true
	
	var pitch_scale = _generate_pitch_scale()
	
	sound_00.pitch_scale = pitch_scale
	sound_01.pitch_scale = pitch_scale
	sound_02.pitch_scale = pitch_scale
	
	resume()

func pause() -> void:
	Tools.debug("Train pause called")
	
	started = false
	
	tween.interpolate_method(self, "_set_volume", 0.0, silent, silence_duration)
	tween.start()
	
	yield(tween, "tween_completed")
	
	_stop_sound()

func _generate_pitch_scale():
	return Tools.random_float(1.0 - max_pitch_diff, 1.0 + max_pitch_diff)

func resume() -> void:
	if not visible:
		return
	
	Tools.debug("Train resume called")
	
	started = true
	
	_play_sound()
	
	tween.interpolate_method(self, "_set_volume", silent, 0.0, silence_duration)
	tween.start()

func stop():
	Tools.debug("Train stop called")
	
	pause()
	
	visible = false

func _set_volume(volume_db: float) -> void:
	sound_00.volume_db = volume_db
	sound_01.volume_db = volume_db
	sound_02.volume_db = volume_db

func _play_sound() -> void:
	sound_00.play()
	sound_01.play()
	sound_02.play()

func _stop_sound() -> void:
	sound_00.stop()
	sound_01.stop()
	sound_02.stop()

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

func _process_movement(delta: float) -> void:
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
	
	position.x += speed * delta

func _process_player_on_top(delta: float) -> void:
	var position_diff = speed * delta
	
	for index in range(len(enter_list_player)):
		var player = enter_list_player[index]
		var speed_scale = enter_list_speed_scale[index]

		if not player or player.dead:
			exit_list_player.push_back(player)
			exit_list_skip_stick.push_back(false)
			continue
		
		player.position.x += position_diff * speed_scale
		enter_list_speed_scale[index] = min(1.0, speed_scale + delta * speed_scale_m)
		
		if player.current_velocity.x > player.current_max_speed:
			player.current_velocity.x -= player.current_max_speed * delta

func _process_recycle() -> void:
	var player = PlayerManager.get_by_distance(global_position)
	var source_position = base_position + offset
	
	if player:
		source_position = player.global_position
	
	if source_position.distance_to(global_position) > recycle_after_distance_to_player:
		stop()
		Tools.destroy(self)

func _physics_process(delta: float) -> void:
	if not started:
		return
	
	current_second += delta
	
	_process_exit_list()
	_process_movement(delta)
	_process_player_on_top(delta)
	_process_recycle()

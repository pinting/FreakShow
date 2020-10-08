class_name Train
extends StaticBody2D

# Sound of the train
export var train_sound: AudioStream

# Start the train using this X offset
export var start_from: float = -15000.0

# Speed and direction to move on the X axis
export var speed: float = 1600.0

# Destory the train after this offset
export var stop_after: float = 150000.0

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

onready var train_00 = $RandomChild00
onready var audio_stream_00 = $Noise00
onready var collision_00 = $CollisionShape00
onready var on_top_collision_00 = $OnTop/CollisionShape00

onready var train_01 = $RandomChild01
onready var audio_stream_01 = $Noise01
onready var collision_01 = $CollisionShape01
onready var on_top_collision_01 = $OnTop/CollisionShape01

onready var train_02 = $RandomChild02
onready var audio_stream_02 = $Noise02
onready var collision_02 = $CollisionShape02
onready var on_top_collision_02 = $OnTop/CollisionShape02

signal stopped
signal body_on_top

var started: bool = false
var enable_sound: bool = true
var current_second: float = 0.0
var last_position_diff: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2(0.0, 0.0)
var players_on_top = []
var players_on_top_speed_scale = []

func _ready() -> void:
	on_top.connect("body_exited", self, "_top_on_body_exited")
	on_top.connect("body_entered", self, "_top_on_body_entered")
	
	visible = false
	base_position = global_position
	
	if train_sound:
		audio_stream_00.stream = train_sound
		audio_stream_01.stream = train_sound
		audio_stream_02.stream = train_sound

func _top_on_body_entered(body: Node):
	if not body.is_in_group("player"):
		return
	
	emit_signal("body_on_top")
	
	if players_on_top.find(body) == -1:
		players_on_top.push_back(body)
		players_on_top_speed_scale.push_back(0.0)

func _top_on_body_exited(body: Node):
	if not body.is_in_group("player"):
		return
	
	yield(Global.timer(0.1), "timeout")
	
	if on_top.overlaps_body(body):
		return
	
	body.current_velocity.x = speed
	
	var index = players_on_top.find(body)
	
	if index >= 0:
		players_on_top.remove(index)
		players_on_top_speed_scale.remove(index)

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
	return Global.random_generator.randf_range(1.0 - max_pitch_diff, 1.0 + max_pitch_diff)

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

func _process(delta) -> void:
	if not started or Global.loader:
		return
	
	current_second += delta
	
	if enable_sound:
		var d = delta * fade_in_volume_per_s
		
		audio_stream_00.volume_db = min(0, audio_stream_00.volume_db + d)
		audio_stream_01.volume_db = min(0, audio_stream_01.volume_db + d)
		audio_stream_02.volume_db = min(0, audio_stream_02.volume_db + d)
	
	var self_position = global_position

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
	
	for index in range(len(players_on_top)):
		var player = players_on_top[index]

		if not player or player.dead:
			continue
		
		var speed_scale = players_on_top_speed_scale[index]
		
		player.position.x += position_diff * speed_scale
		players_on_top_speed_scale[index] = min(1.0, speed_scale + delta * speed_scale_m)
		
		if player.current_velocity.x > player.current_max_speed:
			player.current_velocity.x -= player.current_max_speed * delta
	
	if base_position.distance_to(self_position) > stop_after:
		stop()
		emit_signal("stopped")

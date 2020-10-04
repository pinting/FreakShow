class_name Train
extends StaticBody2D

# Start the train from this point
export var start_from: Vector2 = Vector2(-15000.0, 0.0)

# Speed and direction to move on the X axis
export var speed: Vector2 = Vector2(1600.0, 0.0)

# Destory the train after this offset
export var stop_after: float = 50000.0

# Amplitude of the shake (Y axis)
export var shake_amp: float = 0.1

# Number of shakes (X axis)
export var shake_count: float = 15.0

# Difference in rhythem per train
export var rhythm_diff: float = 0.33

# Maximum pitch diff
export var max_pitch_diff: float = 0.25

onready var on_top = $OnTop

onready var train_00 = $RandomChild00
onready var audio_stream_00 = $Noise00

onready var train_01 = $RandomChild01
onready var audio_stream_01 = $Noise01

onready var train_02 = $RandomChild02
onready var audio_stream_02 = $Noise02

signal stopped

var started: bool = false
var current_second: float = 0.0
var last_position_diff: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2(0.0, 0.0)

func _ready() -> void:
	on_top.connect("body_exited", self, "_on_body_exited")
	on_top.connect("body_entered", self, "_on_body_entered")
	
	visible = false
	base_position = global_position

func _on_body_entered(body: Node):
	if not body.is_in_group("player"):
		return
	
	body.no_max_speed = true
	body.friction = 1.0

func _on_body_exited(body: Node):
	if not body.is_in_group("player"):
		return
	
	body.no_max_speed = false
	body.friction = 0.001

func start() -> void:
	position = base_position + start_from
	visible = true
	
	audio_stream_00.pitch_scale = _generate_pitch_scale()
	audio_stream_01.pitch_scale = audio_stream_00.pitch_scale
	audio_stream_02.pitch_scale = audio_stream_00.pitch_scale
	
	resume()

func pause() -> void:
	started = false
	
	audio_stream_00.stop()
	audio_stream_01.stop()
	audio_stream_02.stop()

func _generate_pitch_scale():
	return Global.random_generator.randf_range(1.0 - max_pitch_diff, 1.0 + max_pitch_diff)

func resume() -> void:
	if not visible:
		return
	
	started = true
	
	audio_stream_00.play()
	audio_stream_01.play()
	audio_stream_02.play()

func stop():
	pause()
	
	visible = false

func _process(delta) -> void:
	var self_position = global_position
	
	if not started:
		return
	
	current_second += delta

	var s = current_second
	var m = shake_amp
	var c = shake_count
	
	train_00.position.y += m * sin(c * s + 0.0 * rhythm_diff) * randf()
	train_01.position.y += m * sin(c * s + 1.0 * rhythm_diff) * randf()
	train_02.position.y += m * sin(c * s + 2.0 * rhythm_diff) * randf()
	
	var position_diff = speed * delta
	var bodies_on_top = on_top.get_overlapping_bodies()
	
	position += position_diff
	
	for body in bodies_on_top:
		if body.is_in_group("player"):
			body.current_velocity += position_diff
	
	if base_position.distance_to(self_position) > stop_after:
		stop()
		emit_signal("stopped")

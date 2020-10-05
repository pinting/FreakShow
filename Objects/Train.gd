class_name Train
extends StaticBody2D

# Start the train using this X offset
export var start_from: float = -15000.0

# Speed and direction to move on the X axis
export var speed: float = 1600.0

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
var bodies_on_top = []
var bodies_on_top_speed_scale = []

func _ready() -> void:
	on_top.connect("body_exited", self, "_on_body_exited")
	on_top.connect("body_entered", self, "_on_body_entered")
	
	visible = false
	base_position = global_position

func _on_body_entered(body: Node):
	if not body.is_in_group("player"):
		return
	
	if bodies_on_top.find(body) == -1:
		bodies_on_top.push_back(body)
		bodies_on_top_speed_scale.push_back(0.0)

func _on_body_exited(body: Node):
	if not body.is_in_group("player"):
		return
	
	yield(Global.timer(0.1), "timeout")
	
	if on_top.overlaps_body(body):
		return
	
	body.current_velocity.x = speed
	
	var index = bodies_on_top.find(body)
	
	if index >= 0:
		bodies_on_top.remove(index)
		bodies_on_top_speed_scale.remove(index)

func start() -> void:
	position.x = base_position.x + start_from
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
	
	position.x += position_diff
	
	for index in range(len(bodies_on_top)):
		var body = bodies_on_top[index]
		var speed_scale = bodies_on_top_speed_scale[index]
		
		body.position.x += position_diff * speed_scale
		
		bodies_on_top_speed_scale[index] = min(1.0, speed_scale + delta)
	
	if base_position.distance_to(self_position) > stop_after:
		stop()
		emit_signal("stopped")

extends Node2D

# Start with an offset
export var start_with_offset: Vector2 = Vector2(0, 0)

# Stop after this amount of movement (no negative numbers) 
export var stop_after: Vector2 = Vector2(0, 1000)

# Speed to move with (this is inverted, when moving back)
export var speed: Vector2 = Vector2(0, 100)

# Optional sounds
onready var door_start = $StartSound
onready var door_move = $MoveSound
onready var door_stop = $StopSound

onready var sprite = $Sprite

var open: bool = false
var moving: bool = false
var direction: float = 0.0
var counter: Vector2 = Vector2.ZERO
var last_movement_diff: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite.position += start_with_offset

func _process(delta: float):
	if not moving:
		return
	
	var smooth = max(0.1, abs(sin((counter.x + counter.y) / (stop_after.x + stop_after.y) * PI)))
	
	last_movement_diff = smooth * direction * speed * delta
	sprite.position += last_movement_diff
	counter += last_movement_diff.abs()
	
	if counter > stop_after:
		counter = Vector2.ZERO
		moving = false
		
		if door_stop:
			door_stop.play()
		
		if door_move:
			door_move.stop()

func open():
	if open or moving:
		return
	
	if door_start:
		door_start.play()
	
	if door_move:
		door_move.play()
	
	yield(Global.timer(1.0), "timeout")
	
	open = true
	moving = true
	direction = 1.0

func close():
	if not open or moving:
		return
	
	if door_start:
		door_start.play()
	
	open = false
	moving = true
	direction = -1.0

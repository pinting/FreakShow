class_name SlidingNode
extends Node2D

# Start with an offset
@export var start_with_offset: Vector2 = Vector2(0, 0)

# Stop after this amount of movement (no negative numbers) 
@export var stop_after: Vector2 = Vector2(0, 1000)

# Speed to move with (this is inverted, when moving back)
@export var speed: Vector2 = Vector2(0, 100)

@onready var door_start: AudioStreamPlayer2D = $StartSound
@onready var door_move: AudioStreamPlayer2D = $MoveSound
@onready var door_stop: AudioStreamPlayer2D = $StopSound

var is_open: bool = false

var close_position: Vector2
var open_position: Vector2
var change_duration: float

func _ready() -> void:
	position += start_with_offset
	
	close_position = position
	open_position = position + stop_after * (speed / speed.abs())
	change_duration = (stop_after / speed.abs()).length()

func open() -> void:
	if is_open or Animator.is_active(self, "position"):
		return
	
	if door_start:
		door_start.play()
	
	if door_move:
		door_move.play()
	
	await Animator.run(self, "position", close_position, open_position, change_duration)
	
	is_open = true

func close() -> void:
	if not is_open or Animator.is_active(self, "position"):
		return
	
	if door_start:
		door_start.play()
	
	await Animator.run(self, "position", close_position, open_position, change_duration)
	
	is_open = false

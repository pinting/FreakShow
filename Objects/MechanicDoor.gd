extends Node2D

export var stop_after: Vector2 = Vector2(0, 1000)
export var speed: Vector2 = Vector2(0, -100)

onready var door_start = $StartSound
onready var door_move = $MoveSound
onready var door_stop = $StopSound
onready var sprite = $Sprite

var base_position: Vector2 = Vector2.ZERO
var open: bool = false
var moving: bool = false
var direction: float = 0.0

func _ready():
	base_position = Vector2(sprite.position.x, sprite.position.y)

func _process(delta: float):
	if not moving:
		
		return
	
	sprite.position += direction * speed * delta
	
	var diff = (sprite.position - base_position).abs()
	
	if (direction == 1 and diff >= stop_after) or (direction == -1 and diff <= Vector2.ZERO):
		moving = false
		
		door_stop.play()
		door_move.stop()

func open():
	if open:
		return
	
	door_start.play()
	door_move.play()
	
	yield(Global.timer(1.0), "timeout")
	
	moving = true
	direction = 1.0
	
	open = true

func close():
	if not open:
		return
	
	door_start.play()
	
	moving = true
	direction = -1.0
	
	open = false

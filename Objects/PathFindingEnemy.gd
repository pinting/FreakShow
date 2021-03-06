class_name Enemy
extends KinematicBody2D

# Speed of the enemy
export var speed: float = 250.0

# Rotation speed of the enemy
export var rotation_speed: float = 10.0

var path : = PoolVector2Array()
var current_speed = speed

var rotation_dest = 0
var current_velocity = 0

func _ready() -> void:
	pass

func path_distance() -> float:
	if not path:
		return 0.0
	
	var previous = global_position
	var sum = 0.0
	
	for i in range(path.size()):
		sum += previous.distance_to(path[i])
		previous = path[i]
	
	return sum

func _physics_process(delta: float) -> void:
	if path.size() == 0:
		return
	
	var distance = global_position.distance_to(path[0])
	var direction = global_position.direction_to(path[0])
	
	if distance < current_speed * delta:
		path.remove(0)
	
	current_velocity = move_and_slide(direction * current_speed)
	rotation_dest = 180 * (direction.angle() / PI)
	
	var rotation_diff = rotation_dest - rotation_degrees
	
	if abs(rotation_diff) > 0:
		var rotation_step = rotation_diff / abs(rotation_diff) * rotation_speed * delta
		
		if abs(rotation_diff) >= abs(rotation_step):
			rotation_degrees += rotation_step
		else:
			rotation_degrees += rotation_diff

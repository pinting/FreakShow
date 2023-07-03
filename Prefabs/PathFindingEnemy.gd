class_name PathFindingEnemy
extends CharacterBody2D

# Navigation node
@export var navigation_node: NodePath

# Target node
@export var target_node: NodePath

# Speed of the enemy
@export var speed: float = 250.0

# Rotation speed of the enemy
@export var rotation_speed: float = 10.0

# How often should the path refreshed
@export var finding_interval: float = 0.5

var path : = PackedVector2Array()
var current_speed = speed

var base_position: Vector2
var base_rotation: float

var finder_counter: float = 0.0
var target_rotation: float = 0.0
var current_velocity: Vector2 = Vector2.ZERO

var target: Node2D
var navigation: Navigation2D

var follows: bool = false
var go_back: bool = false

func _ready() -> void:
	super._ready()

	base_position = global_position
	base_rotation = rotation_degrees
	
	target = get_node(target_node)
	navigation = get_node(navigation_node)
	
	assert(navigation, "Navigation map needs to be set")
	assert(target, "Target needs to be set")

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
	super._physics_process(delta)

	if path.size() == 0:
		return
	
	var distance = global_position.distance_to(path[0])
	var direction = global_position.direction_to(path[0])
	
	if distance < current_speed * delta:
		path.remove(0)
	
	set_velocity(direction * current_speed)
	move_and_slide()
	current_velocity = velocity
	target_rotation = 180 * (direction.angle() / PI)
	
	var rotation_diff = target_rotation - rotation_degrees
	
	if abs(rotation_diff) > 0:
		var rotation_step = rotation_diff / abs(rotation_diff) * rotation_speed * delta
		
		if abs(rotation_diff) > abs(rotation_step):
			rotation_degrees += rotation_step
		else:
			rotation_degrees += rotation_diff

func reset() -> void:
	global_position = base_position
	rotation_degrees = base_rotation
	path = []
	follows = false
	go_back = false

func _process(delta: float) -> void:
	super._process(delta)

	if not follows:
		return
	
	finder_counter += delta
	
	if finder_counter <= finding_interval:
		return
	
	var target_position = target.global_position
	
	if go_back:
		target_position = base_position
	
	path = navigation.get_simple_path(global_position, target_position)
	finder_counter = 0.0

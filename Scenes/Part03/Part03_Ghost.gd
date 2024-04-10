extends Node2D

# Player node to mirror to
export (NodePath) var player_node

# Origo point to mirror with
export (NodePath) var origo_node

onready var animated_sprite = $AnimatedSprite

var player: Player
var origo: Node2D
var radius: float

var last_x: float = 0.0
var avg_delta: float = 0.0

const eps: float = 0.2

func _ready() -> void:
	player = get_node(player_node)
	origo = get_node(origo_node)

	assert(player, "Player node not found")
	assert(origo, "Origo point not found")
	
	radius = animated_sprite.global_position.distance_to(origo.global_position)

func _process(_delta: float) -> void:
	if player.global_position.distance_to(origo.global_position) > radius:
		return
	
	var diff_x = origo.global_position.x - player.global_position.x
	var new_x = origo.global_position.x + diff_x
	var delta_x = new_x - last_x
	var scale_x = animated_sprite.scale.x
	
	avg_delta += delta_x
	avg_delta /= 2
	
	if delta_x:
		scale_x = abs(delta_x) / delta_x
	
	animated_sprite.scale.x = scale_x
	animated_sprite.global_position.x = new_x
	last_x = new_x
	
	if abs(avg_delta) > eps:
		animated_sprite.animation = "walk"
	else:
		animated_sprite.animation = "default"

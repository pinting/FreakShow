extends Node2D

# Player node to follow
export (NodePath) var player_node

# The X diff in which the eye reacts to the player
export var max_diff: float = 2000

onready var eye_ball = $EyeBack/EyeBall

var player: Player

var eye_position = 0

func _ready() -> void:
	player = get_node(player_node)
	
	assert(player, "Player node not found")

func _process(delta: float) -> void:
	var p = eye_position - floor(eye_position)
	
	eye_ball.position.x = 110 - p * 220
	eye_ball.position.y = -1 *(abs(sin(p * PI)) * 30 - 15)

	var diff = global_position - player.global_position
	
	if abs(diff.x) < max_diff and abs(diff.y) < max_diff:
		eye_position = (diff.x + max_diff) / (2 * max_diff)

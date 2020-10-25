extends Node2D

# The X diff in which the eye reacts to the player
export var max_diff: float = 2000

onready var eye_ball = $EyeBack/EyeBall

var eye_position = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var p = eye_position - floor(eye_position)
	
	eye_ball.position.x = 110 - p * 220
	eye_ball.position.y = -1 *(abs(sin(p * PI)) * 30 - 15)
	
	var player = Game.players.back()

	if not player:
		return

	var diff = global_position - player.global_position
	
	if abs(diff.x) < max_diff and abs(diff.y) < max_diff:
		eye_position = (diff.x + max_diff) / (2 * max_diff)

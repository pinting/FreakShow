extends Node2D

export var ball_is_stuck_timeout: float = 6.0

onready var inside_hoop = $InsideHoop

signal ball_in_hoop

func _ready():
	inside_hoop.connect("body_entered", self, "_trigger_in_hoop")

func _trigger_in_hoop(ball: Node) -> void:
	if not ball.is_in_group("ball") or not inside_hoop.visible:
		return
	
	yield(Game.timer(ball_is_stuck_timeout), "timeout")
	
	while ball.held:
		yield(Game.timer(ball_is_stuck_timeout), "timeout")
	
	inside_hoop.visible = false
	ball.global_position = inside_hoop.global_position
	
	ball.disable()
	
	emit_signal("ball_in_hoop")

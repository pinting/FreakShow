extends Node2D

export var ball_is_stuck_timeout: float = 6.0

onready var inside_hoop: Area2D = $InsideHoop

signal ball_in_hoop

func _ready():
	inside_hoop.connect("body_entered", self, "_trigger_in_hoop")

func _trigger_in_hoop(ball: Node) -> void:
	if not ball.is_in_group("_ball") or not inside_hoop.visible:
		return
	
	while ball.held:
		yield(Tools.timer(ball_is_stuck_timeout), "timeout")
	
	yield(Tools.timer(ball_is_stuck_timeout), "timeout")
	
	if not inside_hoop.overlaps_body(ball):
		return
	
	inside_hoop.visible = false
	ball.global_position = inside_hoop.global_position
	
	ball.disable()
	emit_signal("ball_in_hoop")

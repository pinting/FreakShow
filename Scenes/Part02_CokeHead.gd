extends "res://Objects/Enemy.gd"

export var HIGH_SPEED_AFTER: float = 2000.0

export var HIGH_SPEED_SCALE: float = 3.0

func _ready():
	pass

func _physics_process(delta: float):
	var player = Global.player
	
	if path:
		var d = player.position.distance_to(position)
		
		if d > HIGH_SPEED_AFTER:
			current_speed = SPEED * HIGH_SPEED_SCALE
		else:
			current_speed = SPEED

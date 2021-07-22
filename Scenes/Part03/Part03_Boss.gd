extends "res://Prefabs/PathFindingEnemy.gd"

export var high_speed_after_distance: float = 3000.0
export var high_speed_scale: float = 1.5

func _physics_process(_delta: float) -> void:
	var d = path_distance()
	
	if d > high_speed_after_distance:
		current_speed = speed * high_speed_scale
	else:
		current_speed = speed

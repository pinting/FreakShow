extends Node2D

@export var angular_velocity: float = 300

func _process(delta: float) -> void:
	var diff = angular_velocity * delta
	
	rotation_degrees = fmod(rotation_degrees + diff, 360.0)

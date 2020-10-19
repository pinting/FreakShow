extends Node2D

onready var broken_lamp_light = $LampBroken/Lamp/Light

var wait = 0.0

func _ready():
	pass

func _process(delta):
	wait -= delta
	
	if wait <= 0.0:
		broken_lamp_light.visible = not broken_lamp_light.visible
		wait = Game.random_generator.randf_range(0.25, 1.0)

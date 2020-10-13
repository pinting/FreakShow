extends Sprite

onready var red = $Red

var wait = 0.0

func _ready():
	pass

func _process(delta):
	wait -= delta
	
	if wait <= 0.0:
		red.visible = not red.visible
		wait = Global.random_generator.randf_range(0.25, 1.0)

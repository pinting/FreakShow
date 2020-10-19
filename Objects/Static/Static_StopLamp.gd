extends Sprite

onready var red = $Red

var wait: float = 0.0
var disabled: bool = true

func _ready() -> void:
	if disabled:
		red.visible = false

func _process(delta: float) -> void:
	if disabled:
		return
	
	wait -= delta
	
	if wait <= 0.0:
		red.visible = not red.visible
		wait = Game.random_generator.randf_range(0.25, 1.0)

func disable() -> void:
	red.visible = false
	disabled = true

func enable() -> void:
	disabled = false

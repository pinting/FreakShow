extends Sprite2D

@onready var lamp: Sprite2D = $Lamp
@onready var phone: Selectable = $Phone

const zero: float = 0.05

var flashing_phone_light = false
var current_second = 0.0

func _process(delta: float) -> void:
	current_second += delta
	
	if flashing_phone_light and fmod(current_second, randf()) <= zero:
		lamp.visible = not lamp.visible

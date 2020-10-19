extends Sprite

onready var lamp = $Lamp
onready var phone = $Phone

const zero: float = 0.05

var flashing_phone_light = false
var current_second = 0.0

func _ready():
	pass

func _process(delta: float) -> void:
	current_second += delta
	
	if flashing_phone_light and fmod(current_second, randf()) <= zero:
		lamp.visible = not lamp.visible

extends Sprite

# Enable or disable the lamp above the platform
export var lamp_above_platform: bool = true

onready var lamp = $Lamp

func _ready():
	if not lamp_above_platform:
		remove_child(lamp)
		lamp.queue_free()

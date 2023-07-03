extends StaticBody2D

@onready var shutter = $Top/Bottom/RightBlock/Shutter

const duration: float = 2.0

signal shutter_opened

func _ready() -> void:
	super._ready()
	
	shutter.connect("selected", Callable(self, "_on_shutter_selected").bind(), CONNECT_ONE_SHOT)

func _on_shutter_selected() -> void:
	var height = shutter.texture.get_height() * scale.y 
	var from = shutter.position.y
	var to = from - height
	
	await Animator.run(shutter, "position:y", from, to, duration)
	
	emit_signal("shutter_opened")

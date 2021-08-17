extends StaticBody2D

onready var shutter = $Top/Bottom/RightBlock/Shutter

const duration: float = 2.0

signal shutter_opened

func _ready() -> void:
	shutter.connect("selected", self, "_on_shutter_selected", [], CONNECT_ONESHOT)

func _on_shutter_selected() -> void:
	var height = shutter.texture.get_height() * scale.y 
	var from = shutter.position.y
	var to = from - height
	
	yield(Animator.run(shutter, "position:y", from, to, duration), "completed")
	
	emit_signal("shutter_opened")

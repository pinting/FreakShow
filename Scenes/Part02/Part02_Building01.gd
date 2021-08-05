extends StaticBody2D

onready var tween = $Tween
onready var shutter = $Top/Bottom/RightBlock/Shutter

const duration: float = 2.0

signal shutter_opened

func _ready() -> void:
	shutter.connect("selected", self, "_on_shutter_selected", [], CONNECT_ONESHOT)

func _on_shutter_selected() -> void:
	var height = shutter.texture.get_height() * scale.y 
	var from = shutter.position.y
	var to = from - height
	
	tween.interpolate_property(shutter, "position:y", from, to, duration)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	emit_signal("shutter_opened")

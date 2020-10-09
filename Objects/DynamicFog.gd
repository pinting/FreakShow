extends Node

func _ready() -> void:
	if Global.LOW_PERFORMANCE:
		get_parent().remove_child(self)
		queue_free()

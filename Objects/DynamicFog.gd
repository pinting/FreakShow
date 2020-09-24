extends ColorRect

func _ready():
	if Global.LOW_PERFORMANCE:
		get_parent().remove_child(self)
		queue_free()

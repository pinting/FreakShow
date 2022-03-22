extends BaseScene

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var is_accept = VirtualInput.is_action_just_pressed("ui_accept")
	
	if is_accept:
		pass

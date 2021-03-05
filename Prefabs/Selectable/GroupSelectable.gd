class_name GroupSelectable
extends BaseSelectable

var chosen: BaseSelectable

func _ready() -> void:
	pass

func _on_selected() -> void:
	emit_signal("selected")

func disable() -> void:
	if chosen.has_method("disable"):
		chosen.disable()

func hold():
	if chosen.has_method("hold"):
		chosen.hold()

func drop():
	if chosen.has_method("drop"):
		chosen.drop()

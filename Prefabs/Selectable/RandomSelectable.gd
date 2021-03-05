class_name RandomSelectable
extends GroupSelectable

const RandomChild = preload("res://Prefabs/RandomChild.gd")

func _ready() -> void:
	chosen = RandomChild.select_child(self)
	
	if chosen.is_in_group("selectable"):
		chosen.connect("selected", self, "_on_selected")

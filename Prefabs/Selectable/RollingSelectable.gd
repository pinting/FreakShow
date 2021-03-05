class_name RollingSelectable
extends GroupSelectable

export var key: String = "RollingSelectable"

const RandomChild = preload("res://Prefabs/RandomChild.gd")

func _ready() -> void:
	chosen = RandomChild.select_child(self, key)
	
	if chosen.is_in_group("selectable"):
		chosen.connect("selected", self, "_on_selected")

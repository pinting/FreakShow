class_name RollingChild
extends Node2D

export var key = "RollingChild"

func _ready():
	select_child(self, key)

static func select_child(parent: Node, key: String):
	var count = parent.get_child_count()
	
	if not count:
		return
	
	var n = Save.get_value("temp", key, 0)
	
	Save.set_value("temp", key, (n + 1) % count)
	
	return Tools.keep_child_at(parent, n % count)

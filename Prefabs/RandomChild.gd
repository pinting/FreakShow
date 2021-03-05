class_name RandomChild
extends Node2D

func _ready():
	select_child(self)

static func select_child(parent: Node):
	var count = parent.get_child_count()
	
	if not count:
		return
	
	var random_selected = Game.random_generator.randi_range(0, count - 1)
	
	return Tools.keep_child_at(parent, random_selected)

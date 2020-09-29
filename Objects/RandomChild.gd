extends Node

func _ready() -> void:
	var children = get_children()
	var count = get_child_count()
	
	if not count:
		return
	
	var random_selected = Global.random_generator.randi_range(0, count - 1)
	
	for i in range(0, count):
		if i != random_selected:
			var child = children[i]
			
			remove_child(children[i])
			child.queue_free()

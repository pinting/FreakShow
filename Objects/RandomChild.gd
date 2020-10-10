extends Node

signal selected

var selected: Node

func _ready() -> void:
	var children = get_children()
	var count = get_child_count()
	
	if not count:
		return
	
	var random_selected = Global.random_generator.randi_range(0, count - 1)
	
	for i in range(0, count):
		var child = children[i]
		
		if i != random_selected:
			remove_child(children[i])
			child.queue_free()
		else:
			selected = child
	
	# Some components would not work with an extra RandomChild node.
	# To fix this, Selectable and RandomChild have similar interface.
	if selected.is_in_group("selectable"):
		selected.connect("selected", self, "_on_selected")

func _on_selected() -> void:
	emit_signal("selected")

func disable() -> void:
	if selected.is_in_group("selectable"):
		selected.disable()

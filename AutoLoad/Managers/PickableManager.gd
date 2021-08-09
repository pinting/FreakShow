extends Node

var current: Pickable = null

func _ready() -> void:
	for pickable in get_tree().get_nodes_in_group("pickable"):
		pickable.connect("picked", self, "_on_picked")
		pickable.connect("dropped", self, "_on_dropped")

func _on_picked(pickable: Pickable) -> void:
	if not current:
		current = pickable

func _on_dropped(pickable: Pickable) -> void:
	if current == pickable:
		current = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and current and not event.pressed:
		if is_instance_valid(current):
			current.drop(Vector2.ZERO)
		else:
			current = null

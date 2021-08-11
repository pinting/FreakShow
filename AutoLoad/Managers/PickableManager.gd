extends Node

var current: Pickable = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and current and not event.pressed:
		if is_instance_valid(current):
			current.drop(Vector2.ZERO)
		else:
			current = null

func is_held(pickable: Pickable) -> bool:
	return pickable == current

func pick(pickable: Pickable) -> void:
	if not current:
		current = pickable

func drop(pickable: Pickable) -> void:
	if current == pickable:
		current = null

func clear() -> void:
	current = null

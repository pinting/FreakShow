extends Node

var current: Pickable = null

func is_held(pickable: Pickable) -> bool:
	return pickable == current

func pick(pickable: Pickable) -> bool:
	if current or pickable.disabled:
		return false
	
	current = pickable
		
	return true

func drop(pickable: Pickable) -> bool:
	if current != pickable:
		return false
	
	current = null
	
	return true

func clear() -> void:
	current = null

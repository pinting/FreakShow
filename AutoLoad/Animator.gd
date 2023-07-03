extends Node

var tweens: Dictionary = {}

func generate_key(object: Object, path: String):
	return str(object.get_instance_id(), path)

func find_tween(object: Object, path: String) -> Tween:
	var key = generate_key(object, path)
	
	if tweens.has(key):
		return tweens[key]
	else:
		return null

func add_tween(object: Object, path: String) -> Tween:
	var key = generate_key(object, path)
	var tween = find_tween(object, path)
	
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	
	tween.finished.connect(Callable(remove_tween).bind(object, path))
	
	tweens[key] = tween
	
	return tween

func remove_tween(object: Object, path: String) -> void:
	var key = generate_key(object, path)
	var tween = find_tween(object, path)

	if tween:
		tween.kill()
		assert(tweens.erase(key))

func run(object: Object, path: String, from, to, duration: float) -> void:
	var tween: Tween = add_tween(object, path)
	
	if object.has_method(path):
		object.call(path, from)
		tween.tween_method(Callable(object, path), from, to, duration)
	else:
		object.set(path, from)
		tween.tween_property(object, path, to, duration)
	
	await tween.finished

func is_active(object: Object, path: String) -> bool:
	var tween = find_tween(object, path)

	if tween:
		return tween.is_active()
	
	return false


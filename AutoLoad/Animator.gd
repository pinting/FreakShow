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
	if object.has_method(path):
		await tween_method(object, path, from, to, duration)
	else:
		await tween_property(object, path, from, to, duration)

func tween_property(object: Object, prop: String, from, to, duration: float) -> void:
	var tween: Tween = add_tween(object, prop)
	
	object.set(prop, from)
	tween.tween_property(object, prop, to, duration)
	
	await tween.finished

func tween_method(object: Object, method: String, from, to, duration: float) -> void:
	var tween: Tween = add_tween(object, method)
	var callable = Callable(object, method)
	
	callable.call(from)
	tween.tween_method(callable, from, to, duration)
	
	await tween.finished

func tween_material(object: Object, parameter: String, from, to, duration: float) -> void:
	var tween: Tween = add_tween(object, parameter)
	var callable = Callable(self, "_set_shader_parameter").bind(parameter, object.material)

	callable.call(from)
	tween.tween_method(callable, from, to, duration)
	
	await tween.finished

func _set_shader_parameter(value, parameter: String, material: Material):
	material.set_shader_parameter(parameter, value)

func is_active(object: Object, path: String) -> bool:
	var tween = find_tween(object, path)

	if tween:
		return tween.is_running()
	
	return false


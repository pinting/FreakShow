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

func create_tween(object: Object, path: String, auto_destroy: bool = false) -> Tween:
	var key = generate_key(object, path)
	var tween = find_tween(object, path)
	
	if tween:
		tween.stop_all()
	
	if not tween:
		tween = Tween.new()
		
		if auto_destroy:
			tween.connect("tween_all_completed", self, 
				"remove_tween", [object, path])
		
		add_child(tween)

		tweens[key] = tween
	
	return tween

func remove_tween(object: Object, path: String) -> void:
	var key = generate_key(object, path)
	var tween = find_tween(object, path)

	if tween:
		tween.stop_all()
		assert(tweens.erase(key))
		Tools.destroy_node(tween)

func run(object: Object, path: String, from, to, duration: float, trans_type = Tween.TRANS_LINEAR, ease_type = Tween.EASE_IN_OUT, delay = 0.0) -> void:
	var tween = create_tween(object, path, true)
	
	if object.has_method(path):
		object.call(path, from)
		tween.interpolate_method(object, path, from, to, duration, trans_type, ease_type, delay)
	else:
		object.set(path, from)
		tween.interpolate_property(object, path, from, to, duration, trans_type, ease_type, delay)
	
	tween.start()
	
	yield(tween, "tween_all_completed")

func is_active(object: Object, path: String) -> bool:
	var tween = find_tween(object, path)

	if tween:
		return tween.is_active()
	
	return false


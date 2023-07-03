extends Node

var loading_path: String
var count: int = 0

func _process(_delta: float) -> void:
	if loading_path == "":
		return
	
	var progress = [0.0]
	var result = ResourceLoader.load_threaded_get_status(loading_path, progress)
	
	if result == ResourceLoader.THREAD_LOAD_LOADED:
		var resource = ResourceLoader.load_threaded_get(loading_path)
		
		_finish_loading(resource)
	elif result == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		Tools.debug("Loader progress: %f" % progress)
	else:
		Tools.debug("Error during scene loading!")
		
		loading_path = ""

func _finish_loading(scene_resource) -> void:
	count += 1
	
	PlayerManager.clear()
	CameraManager.clear()
	SubtitleManager.clear()
	ViewableManager.clear()
	CursorManager.clear()
	SelectableManager.clear()
	PickableManager.clear()
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	# This is needed to workaround canvas modulate glitches 
	for child in current_scene.get_children():
		if child.get("visible") != null:
			child.visible = false
		
		current_scene.remove_child(child)
		child.queue_free()
	
	current_scene.queue_free()
	
	var next_scene = scene_resource.instantiate()
	
	root.add_child(next_scene)
	
	loading_path = ""

func load_scene(path: String, save_progress: bool = false) -> void:
	if loading_path != "":
		return
	
	if save_progress:
		Save.set_value("game", "current_scene", path)
	
	VirtualInput.test_keys = {}
	
	var err = ResourceLoader.load_threaded_request(path)
	
	if err == OK:
		loading_path = path
	else:
		Tools.debug("Loader failed to initialize!")

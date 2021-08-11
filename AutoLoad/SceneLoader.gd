extends Node

var resource_loader: ResourceInteractiveLoader = null
var count: int = 0

func _process(_delta: float) -> void:
	if not resource_loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + Config.LOADING_TIME_PER_TICK:
		var result = resource_loader.poll()
		
		if result == ERR_FILE_EOF:
			_finish_loading(resource_loader.get_resource())
			break
		elif result == OK:
			var current = resource_loader.get_stage()
			var stage_count = resource_loader.get_stage_count()
			
			Tools.debug(str("Loader progress: ", current + 1, "/", stage_count))
		else:
			Tools.debug("Error during loading!")
			resource_loader = null
			break

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
	
	var next_scene = scene_resource.instance()
	
	root.add_child(next_scene)
	
	resource_loader = null

func load_scene(path: String, save_progress: bool = false) -> void:
	if resource_loader:
		return
	
	if save_progress:
		Save.set_value("game", "current_scene", path)
	
	Tools.report_scene(path)
	
	VirtualInput.test_keys = {}
	
	resource_loader = ResourceLoader.load_interactive(path)
	
	if resource_loader == null:
		Tools.debug("Loader failed to initialize!")

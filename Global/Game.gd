extends Node

var players: Array = []
var current_camera: Camera2D = null
var subtitle_display: Node = null
var viewable_display: CanvasLayer = null

# Disable every selectable object
var disable_selectable: bool = false

var random_generator: RandomNumberGenerator = null
var http_request: HTTPRequest = null
var scene_loader: ResourceInteractiveLoader = null

func _ready() -> void:
	random_generator = RandomNumberGenerator.new()
	http_request = HTTPRequest.new()
	
	random_generator.randomize()
	add_child(http_request)
	
	if Config.no_sound:
		for i in range(AudioServer.bus_count):
			AudioServer.set_bus_volume_db(i, -500)

func timer(duration: float = 1.0) -> SceneTreeTimer:
	return get_tree().create_timer(duration)

func debug(message: String) -> void:
	if Config.DEBUG:
		print(message)

func _process(_delta: float) -> void:
	if not scene_loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + Config.LOADING_TIME_PER_TICK:
		var result = scene_loader.poll()
		
		if result == ERR_FILE_EOF:
			_set_new_scene(scene_loader.get_resource())
			break
		elif result == OK:
			var current = scene_loader.get_stage()
			var count = scene_loader.get_stage_count()
			
			debug(str("Loader progress: ", current + 1, "/", count))
		else:
			debug("Error during loading!")
			scene_loader = null
			break

func _set_new_scene(scene_resource) -> void:
	for player in players:
		player.destroy()
	
	players = []
	
	if current_camera:
		current_camera.destroy()
	
	current_camera = null
	
	if subtitle_display:
		subtitle_display.destroy()
	
	subtitle_display = null
	
	if viewable_display:
		viewable_display.destroy()
	
	viewable_display = null
	
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
	
	scene_loader = null

func load_scene(path: String, save_progress: bool = false) -> void:
	if scene_loader:
		return
	
	if save_progress:
		Save.set_value("game", "current_scene", path)
	
	_report_scene(path)
	
	scene_loader = ResourceLoader.load_interactive(path)
	
	if scene_loader == null:
		debug("Loader failed to initialize!")

func _report_scene(path) -> void:
	var headers = ["Content-Type: application/json"]
	var user_id = str(OS.get_unique_id()).sha1_text()
	var query = JSON.print({
		"userId": user_id,
		"scenePath": path
	})
	
	var result = http_request.request(Config.REPORT_URL, headers, true, HTTPClient.METHOD_POST, query)
	
	debug(str("Reporting with result: ", result, " AND query: ", query))

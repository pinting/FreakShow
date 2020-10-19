extends Node

var current_camera: Camera2D = null
var players: Array = []
var subtitle_display: Node = null
var subtitle: SubtitleManager = null
var viewable_display: CanvasLayer = null
var random_generator: RandomNumberGenerator = null
var http_request: HTTPRequest = null
var loader = null

# Disable every selectable object
var disable_selectable: bool = false

class SubtitleManager:
	var subtitle_queue = []
	
	func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
		if not Game.subtitle_display:
			subtitle_queue.push_back({
				"text": text,
				"speed": speed,
				"timeout": timeout
			})
		else:	
			for s in subtitle_queue:
				Game.subtitle_display.say(s.text, s.speed, s.timeout)
			
			Game.subtitle_display.say(text, speed, timeout)
	
	func describe(key: int, text: String, keep: bool = false) -> void:
		if Game.subtitle_display:
			Game.subtitle_display.describe(key, text, keep)
	
	func describe_remove(key: int, force: bool = false) -> void:
		if Game.subtitle_display:
			Game.subtitle_display.describe_remove(key, force)

func _ready() -> void:
	random_generator = RandomNumberGenerator.new()
	subtitle = SubtitleManager.new()
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

func _process(delta: float) -> void:
	if not loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + Config.LOADING_TIME_PER_TICK:
		var result = loader.poll()
		
		if result == ERR_FILE_EOF:
			_set_new_scene(loader.get_resource())
			break
		elif result == OK:
			var current = loader.get_stage()
			var count = loader.get_stage_count()
			
			debug(str("Loader progress: ", current + 1, "/", count))
		else:
			debug("Error during loading!")
			loader = null
			break

func _set_new_scene(scene_resource) -> void:
	for player in players:
		player.get_parent().remove_child(player)
		player.queue_free()
	
	players = []
	
	if current_camera:
		current_camera.get_parent().remove_child(current_camera)
		current_camera.queue_free()
	
	current_camera = null
	
	if subtitle_display:
		subtitle_display.get_parent().remove_child(subtitle_display)
		subtitle_display.queue_free()
	
	subtitle_display = null
	
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

	loader = null

func load_scene(path) -> void:
	if loader:
		return
	
	Config.last_loaded_scene = path
	
	Config.save_config()
	_report_scene(path)
	
	loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
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

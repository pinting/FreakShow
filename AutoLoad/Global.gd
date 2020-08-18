extends Node

# Enable debug messages
const DEBUG: bool = true

# Disable sounds
const NO_SOUNDS: bool = true

# Disable intro
const NO_INTRO: bool = true

# Max loading time per tick (in msec)
export var MAX_LOADING_TIME: int = 100

var current_camera: Camera2D = null
var player: Player = null
var subtitle_display: SubtitleDisplay = null
var subtitle: SubtitleManager = null

var _loader = null

class SubtitleManager:
	var _subtitle_queue = []
	
	func say(text: String, speed: float = 2.0, timeout: float = 10.0):
		if not Global.subtitle_display:
			_subtitle_queue.push_back({
				"text": text,
				"speed": speed,
				"timeout": timeout
			})
		else:	
			for s in _subtitle_queue:
				Global.subtitle_display.say(s.text, s.speed, s.timeout)
			
			Global.subtitle_display.say(text, speed, timeout)
	
	func describe(key: int, text: String):
		if Global.subtitle_display:
			Global.subtitle_display.describe(key, text)
	
	func describe_remove(key: int):
		if Global.subtitle_display:
			Global.subtitle_display.describe_remove(key)

func _ready():
	subtitle = SubtitleManager.new()

func debug(message):
	if DEBUG:
		print(message)

func _process(delta):
	_process_loading(delta)

func _process_loading(delta):
	if not _loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + MAX_LOADING_TIME:
		var result = _loader.poll()
		
		if result == ERR_FILE_EOF:
			var resource = _loader.get_resource()
			_loader = null
			_set_new_scene(resource)
			break
		elif result == OK:
			var current = _loader.get_stage()
			var count = _loader.get_stage_count()
			
			Global.debug(str("Loader progress: ", current, "/", count))
		else:
			Global.debug("Error during loading!")
			_loader = null
			break

func _set_new_scene(scene_resource):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	var next_scene = scene_resource.instance()
	
	# This is needed to workaround canvas modulate glitches 
	for child in current_scene.get_children():
		if child.get("visible") != null:
			child.visible = false
		
		child.queue_free()
	
	current_scene.queue_free()
	root.add_child(next_scene)

func load_scene(path):
	current_camera = null
	player = null
	subtitle_display = null
	
	_loader = ResourceLoader.load_interactive(path)
	
	if _loader == null:
		Global.debug("Loader failed to initialize!")

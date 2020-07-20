extends Node2D

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 15

# Time after the game fades in
export var FADE_IN_AFTER = 2

# Fade out duration
export var FADE_IN_DURATION = 3

# Max loading time per tick (in msec)
export var MAX_LOADING_TIME = 100

onready var black_screen = $BlackScreen
onready var player = $Player
onready var music_mixer = $MusicMixer

var _held_object = null
var _fade_current = 1
var _fade_duration = 1
var _fade_direction = 0
var _intro_over = false
var _loader = null

var current_second = 0

func _ready():
	black_screen.visible = true
		
	if Global.NO_INTRO:
		_fade_current = 0
		_intro_over = true
	
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("picked", self, "_on_pickable_picked")

func _on_pickable_picked(object):
	if not _held_object:
		_held_object = object
		_held_object.pickup()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if _held_object and not event.pressed:
			_held_object.drop(Input.get_last_mouse_speed())
			_held_object = null

func _process(delta):
	current_second += delta
	
	_process_intro(delta)
	_process_fade(delta)
	_process_loading(delta)

func _process_intro(delta):
	if _intro_over:
		return
	
	if current_second > FADE_IN_AFTER:
		fade_in(FADE_IN_DURATION)
		_intro_over = true

func _process_loading(delta):
	if not _loader:
		return
	
	var now = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < now + MAX_LOADING_TIME:
		var result = _loader.poll()
		
		if result == ERR_FILE_EOF: # load finished
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
	_loader = ResourceLoader.load_interactive(path)
	
	if _loader == null:
		Global.debug("Loader failed to initialize!")

func _process_fade(delta):
	if _fade_direction == 0:
		return
	
	_fade_current += _fade_direction * (delta / _fade_duration)
	_fade_current = min(1.0, max(0.0, _fade_current))
	
	if _fade_current == 0.0 or _fade_current == 1.0:
		_fade_direction = 0
	
	if _fade_current == 0.0:
		black_screen.visible = false
	else:
		black_screen.visible = true
	
	black_screen.modulate = Color(0, 0, 0, _fade_current)

func fade_out(duration = 1):
	assert(duration > 0)
	
	_fade_duration = duration
	_fade_direction = 1

func fade_in(duration = 1):
	assert(duration > 0)
	
	_fade_duration = duration
	_fade_direction = -1

func timer(duration = 1):
	return get_tree().create_timer(duration)

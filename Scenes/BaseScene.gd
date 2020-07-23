extends Node2D

# Time after the game fades in
export var FADE_IN_AFTER = 2

# Fade out duration
export var FADE_IN_DURATION = 3

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 15

onready var black_screen = $BlackScreen
onready var player = $Player
onready var music_mixer = $MusicMixer

var _held_object = null
var _fade_current = 1
var _fade_duration = 1
var _fade_direction = 0
var _intro_started = false
var _intro_over = false

var current_second = 0

signal scene_started
signal fade_out_done
signal fade_in_done
signal intro_over

func _ready():
	black_screen.visible = true
		
	if Global.NO_INTRO:
		_fade_current = 0
		_intro_started = true
		_intro_over = true
		
		emit_signal("intro_over")
	
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
	if current_second == 0:
		emit_signal("scene_started")
	
	current_second += delta
	
	_process_intro(delta)
	_process_fade(delta)

func _process_intro(delta):
	if _intro_started:
		return
	
	if current_second > FADE_IN_AFTER:
		fade_in(FADE_IN_DURATION)
		_intro_started = true

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
	
	if _fade_current == 1.0:
		emit_signal("fade_out_done")
	elif _fade_current == 0.0:
		emit_signal("fade_in_done")
		
		if(not _intro_over):
			_intro_over = true
			
			emit_signal("intro_over")
	
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

extends Node2D

# Size of a trigger point detect field
export var DETECT_THRESHOLD = 15

# Time after the game fades in
export var FADE_IN_AFTER = 2

# Fade out duration
export var FADE_IN_DURATION = 3

onready var black_screen = $BlackScreen
onready var player = $Player

var _held_object = null
var _fade_current = 1
var _fade_length = 1
var _fade_direction = 0
var _intro_over = false

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

func _process_intro(delta):
	if _intro_over:
		return
	
	if current_second > FADE_IN_AFTER:
		fade_in(FADE_IN_DURATION)
		_intro_over = true

func _process_fade(delta):
	if _fade_direction == 0:
		return
	
	_fade_current += _fade_direction * (delta / _fade_length)
	_fade_current = min(1.0, max(0.0, _fade_current))
	
	if _fade_current == 0.0 or _fade_current == 1.0:
		_fade_direction = 0
		
	if _fade_current == 0.0:
		black_screen.visible = false
	else:
		black_screen.visible = true
	
	black_screen.modulate = Color(0, 0, 0, _fade_current)

func fade_out(length = 1):
	assert(length > 0)
	
	_fade_length = length
	_fade_direction = 1

func fade_in(length = 1):
	assert(length > 0)
	
	_fade_length = length
	_fade_direction = -1

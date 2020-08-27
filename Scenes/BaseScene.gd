class_name BaseScene
extends Node2D

# Time after the game fades in
export var fade_in_after: float = 2.0

# Fade out duration
export var fade_in_duration: float = 3.0

# Delay
export var delay: float = 0.0

onready var black_screen = $BlackScreen/ColorRect

var held_object: Object = null
var fade_current: float = 1.0
var fade_duration: float = 1.0
var fade_direction: float = 0.0
var intro_started: bool = false
var intro_over: bool = false
var current_delay: float = 0.0
var current_second: float = 0.0

signal scene_started
signal fade_out_done
signal fade_in_done
signal intro_over

func _ready():
	if Global.NO_INTRO:
		fade_current = 0.0
		intro_started = true
		intro_over = true
		
		emit_signal("intro_over")
	else:
		black_screen.visible = true
	
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("picked", self, "_on_pickable_picked")

func _on_pickable_picked(object: Object):
	if not held_object:
		held_object = object
		held_object.pickup()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and not event.pressed:
			held_object.drop(Input.get_last_mouse_speed())
			held_object = null

func _process(delta: float):
	if current_delay < delay:
		current_delay += delta
		return
	
	if current_second == 0.0:
		emit_signal("scene_started")
	
	current_second += delta
	
	_process_intro(delta)
	_process_fade(delta)

func _process_intro(_delta: float):
	if intro_started:
		return
	
	if current_second > fade_in_after:
		fade_in(fade_in_duration)
		intro_started = true

func _process_fade(delta: float):
	if fade_current == 0.0:
		black_screen.visible = false
	else:
		black_screen.visible = true
	
	if fade_direction == 0.0:
		return
	
	fade_current += fade_direction * (delta / fade_duration)
	fade_current = min(1.0, max(0.0, fade_current))
	
	if fade_current == 0.0 or fade_current == 1.0:
		fade_direction = 0.0
	
	if fade_current == 1.0:
		emit_signal("fade_out_done")
	elif fade_current == 0.0:
		emit_signal("fade_in_done")
		
		if(not intro_over):
			intro_over = true
			
			emit_signal("intro_over")
	
	black_screen.modulate = Color(0.0, 0.0, 0.0, fade_current)

func fade_out(duration = 1.0):
	assert(duration > 0.0)
	
	fade_duration = duration
	fade_direction = 1.0

func fade_in(duration = 1.0):
	assert(duration > 0.0)
	
	fade_duration = duration
	fade_direction = -1.0

func timer(duration = 1.0):
	return get_tree().create_timer(duration)

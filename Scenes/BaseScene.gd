class_name BaseScene
extends Node2D

# Game restart after this amount of seconds if player is idle
export var game_restart_after: float = 120.0

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
var disable_auto_restart: bool = false
var restart_counter: float = 0.0
var restart_button_counter: float = 0.0
var move_in_progress: bool = false

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

func _input(event: InputEvent):
	restart_counter = 0.0
	
	if event is InputEventMouseButton:
		if held_object and not event.pressed:
			held_object.drop(Input.get_last_mouse_speed())
			held_object = null

func _process(delta: float):
	if current_delay < delay:
		current_delay += delta
		return
	
	if current_second == 0.0:
		emit_signal("scene_started")
	
	if not disable_auto_restart:
		if restart_counter >= game_restart_after:
			load_scene(ProjectSettings.get_setting("application/run/main_scene"))
		
		restart_counter += delta
	
	current_second += delta
	
	_process_intro(delta)
	_process_fade(delta)
	_process_restart_button(delta)

func _process_restart_button(delta: float):
	var restart_game = Input.is_action_pressed("restart_game")
	var restart_scene = Input.is_action_pressed("restart_scene")
	
	if restart_game or restart_scene:
		restart_button_counter += delta
		
		if restart_button_counter >= 1.0:
			
			if restart_game:
				load_scene(ProjectSettings.get_setting("application/run/main_scene"))
			elif restart_scene:
				load_scene(get_parent().filename)
	else:
		restart_button_counter += 0

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

func fade_out(duration: float = 1.0):
	assert(duration > 0.0)
	
	fade_duration = duration
	fade_direction = 1.0

func fade_in(duration: float = 1.0):
	assert(duration > 0.0)
	
	fade_duration = duration
	fade_direction = -1.0

func timer(duration: float = 1.0):
	return get_tree().create_timer(duration)

func load_scene(path: String):
	var players = Global.players

	for player in players:
		player.freeze()
		
	fade_out(2.0)
	yield(timer(2.0), "timeout")
	
	Global.load_scene(path)

func move_with_fade(player: Player, next_position: Vector2, sound: AudioStreamPlayer = null):
	if move_in_progress:
		return
	
	move_in_progress = true
	
	var camera = Global.current_camera
	var smoothing_enabled = camera.smoothing_enabled
	
	if sound:
		sound.play()
	
	fade_out(0.9)
	yield(timer(0.9), "timeout")
		
	if camera and smoothing_enabled:
		camera.smoothing_enabled = false
	
	player.position = next_position
	yield(timer(0.2), "timeout")
	
	if camera and smoothing_enabled:
		camera.smoothing_enabled = smoothing_enabled
	
	yield(timer(0.9), "timeout")
	fade_in(0.9)
	
	move_in_progress = false

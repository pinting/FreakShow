class_name BaseScene
extends Node2D

# Game restart after this amount of seconds if player is idle
export var game_restart_after: float = 300.0

# Delay game start
export var delay: float = 0.0

onready var black_screen = $BlackScreen

var held_object: Object = null
var intro_started: bool = false
var current_delay: float = 0.0
var current_second: float = 0.0
var disable_auto_restart: bool = false
var restart_counter: float = 0.0
var restart_button_counter: float = 0.0
var move_in_progress: bool = false
var loading_in_progress: bool = false

signal scene_started

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("picked", self, "_on_pickable_picked")

func _process(delta: float) -> void:
	if current_delay < delay:
		current_delay += delta
		return
	
	if not disable_auto_restart:
		if restart_counter >= game_restart_after:
			load_scene(ProjectSettings.get_setting("application/run/main_scene"))
		
		restart_counter += delta
	
	_process_restart_button(delta)
	
	if current_second == 0.0:
		emit_signal("scene_started")
	
	current_second += delta

func _process_restart_button(delta: float) -> void:
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

func _on_pickable_picked(object: Object) -> void:
	if not held_object:
		held_object = object
		held_object.pickup()

func _input(event: InputEvent) -> void:
	restart_counter = 0.0
	
	if event is InputEventMouseButton:
		if held_object and not event.pressed:
			if is_instance_valid(held_object):
				held_object.drop(Input.get_last_mouse_speed())
			
			held_object = null

func load_scene(path: String) -> void:
	if loading_in_progress:
		return
	
	loading_in_progress = true
	
	var players = Game.players

	for player in players:
		player.freeze()
		
	black_screen.fade_in(2.0)
	yield(Game.timer(2.0), "timeout")
	
	Game.load_scene(path)

func move_with_fade(player: Player, next_position: Vector2, sound: AudioStreamPlayer = null) -> void:
	if move_in_progress:
		return
	
	move_in_progress = true
	
	var camera = Game.current_camera
	var smoothing_enabled = camera.smoothing_enabled
	
	if sound:
		sound.play()
	
	black_screen.fade_in(0.8)
	yield(Game.timer(0.8), "timeout")
		
	if camera and smoothing_enabled:
		camera.smoothing_enabled = false
	
	player.position = next_position

	player.reset()
	
	if camera and smoothing_enabled:
		camera.smoothing_enabled = smoothing_enabled
	
	yield(Game.timer(0.8), "timeout")
	black_screen.fade_out(0.8)
	
	move_in_progress = false

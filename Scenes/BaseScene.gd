class_name BaseScene
extends Node2D

# Game restart after this amount of seconds if player is idle
export var game_restart_after: float = 600.0

# Delay game start
export var delay: float = 0.0

# Fade in and fade out time (2x will used)
export var move_with_fade_timeout: float = 0.8

# Amount of seconds for the cancel button to be held down to escape
export var cancel_button_timeout: float = 1.0

# Color of the subtitles
export var subtitle_color: Color = Color.white

onready var subtitle_display = $SubtitleDisplay
onready var viewable_display = $ViewableDisplay 
onready var black_screen = $BlackScreen

var held_pickable: RigidBody2D = null
var current_delay: float = 0.0
var current_second: float = 0.0

var disable_auto_restart: bool = false
var auto_restart_counter: float = 0.0

var disable_cancel_button: bool = false
var cancel_button_counter: float = 0.0

var move_in_progress: bool = false
var loading_in_progress: bool = false

signal scene_started

func _ready() -> void:
	subtitle_display.set_color(subtitle_color)
	
	for node in get_tree().get_nodes_in_group("pickable"):
		node.connect("picked", self, "_on_pickable_picked")

func _process(delta: float) -> void:
	if current_delay < delay:
		current_delay += delta
		return
	
	if not disable_auto_restart:
		if auto_restart_counter >= game_restart_after:
			load_scene(ProjectSettings.get_setting("application/run/main_scene"))
		
		auto_restart_counter += delta
	
	_process_cancel_button(delta)
	
	if current_second == 0.0:
		emit_signal("scene_started")
	
	current_second += delta

func _process_cancel_button(delta: float) -> void:
	if disable_cancel_button:
		return
	
	var ui_cancel = Input.is_action_pressed("ui_cancel")
	
	if ui_cancel:
		cancel_button_counter += delta
		
		if cancel_button_counter >= cancel_button_timeout:
			yield(black_screen.fade_in(2.0), "animation_finished")
			load_scene(ProjectSettings.get_setting("application/run/main_scene"))
	else:
		cancel_button_counter += 0

func _on_pickable_picked(object: Object) -> void:
	if not held_pickable:
		held_pickable = object
		held_pickable.hold()

func _input(event: InputEvent) -> void:
	auto_restart_counter = 0.0
	
	if event is InputEventMouseButton:
		if held_pickable and not event.pressed:
			if is_instance_valid(held_pickable):
				held_pickable.drop(Vector2.ZERO)
			
			held_pickable = null

func load_scene(path: String, save_progress: bool = false) -> void:
	if loading_in_progress:
		return
	
	loading_in_progress = true
	
	var players = Game.players

	for player in players:
		player.freeze()
	
	Game.load_scene(path, save_progress)

func reload_scene() -> void:
	load_scene(get_parent().filename)

func move_with_fade(player: Player, next_position: Vector2, sound: AudioStreamPlayer = null) -> void:
	if move_in_progress:
		return
	
	move_in_progress = true
	
	if sound:
		sound.play()
	
	
	yield(black_screen.fade_in(move_with_fade_timeout), "animation_finished")
	
	player.position = next_position
	player.reset()
	
	var camera = Game.current_camera
	
	if camera:
		camera.reset(player.global_position)
	
	yield(black_screen.fade_out(move_with_fade_timeout), "animation_finished")
	
	move_in_progress = false

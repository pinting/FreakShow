class_name BaseScene
extends Node2D

# Game restart after this amount of seconds if player is idle
export var game_restart_after: float = 600.0

# Delay game start
export var delay: float = 0.0

# Fade in and fade out time (2x will used)
export var move_player_timeout: float = 0.8

# Amount of seconds for the cancel button to be held down to escape
export var cancel_button_timeout: float = 1.0

# Auto fade out
export var auto_fade_out: bool = true

# Auto show cursor
export var auto_show_cursor: bool = true

# Disable cancel button
export var disable_cancel_button: bool = false

# Disable auto restart
export var disable_auto_restart: bool = false

onready var subtitle_display = $SubtitleDisplay
onready var viewable_display = $ViewableDisplay 
onready var black_screen = $BlackScreen

signal scene_started

var current_delay: float = 0.0
var current_second: float = 0.0

var held_pickable: RigidBody2D = null

var cancel_button_counter: float = 0.0
var auto_restart_counter: float = 0.0

var player_move_in_progress: bool = false

func _ready() -> void:
	if Config.low_performance:
		_low_performance_mode()
	else:
		_high_performance_mode()
	
	var tree = get_tree()
	
	for node in tree.get_nodes_in_group("pickable"):
		node.connect("picked", self, "_on_pickable_picked")
	
	for node in tree.get_nodes_in_group("auto_visible"):
		node.visible = true
	
	VirtualCursorManager.hide(true)

func _low_performance_mode() -> void:
	var tree = get_tree()
	
	for node in tree.get_nodes_in_group("high_performance"):
		Tools.destroy(node)
	
	for node in tree.get_nodes_in_group("light"):
		Tools.destroy(node)
	
	for node in tree.get_nodes_in_group("world_environment"):
		node.environment = load("res://LowEnvironment.tres")

func _high_performance_mode() -> void:
	var tree = get_tree()
	
	for node in tree.get_nodes_in_group("fake_light"):
		Tools.destroy(node)

func _process(delta: float) -> void:
	if current_delay < delay:
		current_delay += delta
		return
	
	_process_auto_restart(delta)
	_process_cancel_button(delta)
	
	if current_second == 0.0:
		VirtualCursorManager.move_to_center()

		if auto_fade_out:
			black_screen.fade_out()
		
		if auto_show_cursor:
			VirtualCursorManager.show()
		
		emit_signal("scene_started")
	
	current_second += delta

func _process_auto_restart(delta: float) -> void:
	if disable_auto_restart:
		return
	
	var main_scene = ProjectSettings.get_setting("application/run/main_scene")
	
	if auto_restart_counter >= game_restart_after:
		SceneLoader.load_scene(main_scene)
	
	auto_restart_counter += delta

func _process_cancel_button(delta: float) -> void:
	if disable_cancel_button:
		return
	
	var ui_cancel = VirtualInput.is_action_pressed("ui_cancel")
	var main_scene = ProjectSettings.get_setting("application/run/main_scene")
	
	if ui_cancel:
		cancel_button_counter += delta
		
		if cancel_button_counter >= cancel_button_timeout:
			yield(black_screen.fade_in(2.0), "tween_completed")
			SceneLoader.load_scene(main_scene)
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

func reload_scene() -> void:
	var current_scene_path = get_parent().filename
	
	SceneLoader.load_scene(current_scene_path)

func load_next_scene(use_fade = true, freeze_player = true) -> void:
	# Freeze any player movement
	if freeze_player:
		PlayerManager.call_each("freeze")
	
	# Fade in the black screen
	if use_fade and not black_screen.is_fading() and not black_screen.is_faded():
		yield(black_screen.fade_in(), "tween_completed")
	
	var current_scene_path = get_parent().filename
	var next_scene_index = Config.SCENES.find(current_scene_path)
	
	if next_scene_index == -1 or next_scene_index == len(Config.SCENES) - 1:
		# If no next is found or the current is the last, load the first
		next_scene_index = 0
	else:
		# Otherwise load the next in the list
		next_scene_index += 1
	
	var next_scene_path = Config.SCENES[next_scene_index]
	
	SceneLoader.load_scene(next_scene_path, true)

func move_player(player: Player, next_position: Vector2, sound: AudioStreamPlayer = null) -> void:
	if player_move_in_progress:
		return
	
	player_move_in_progress = true
	
	if sound:
		sound.play()
	
	yield(black_screen.fade_in(move_player_timeout), "tween_completed")
	
	player.position = next_position
	player.reset()
	
	# A small delay is needed for the camera
	yield(Tools.timer(0.1), "timeout")
	
	var camera = CameraManager.current
	
	if camera:
		camera.reset(player.global_position)
	
	yield(black_screen.fade_out(move_player_timeout), "tween_completed")
	
	player_move_in_progress = false

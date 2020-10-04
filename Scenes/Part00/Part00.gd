extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part01/Part01.tscn"

# Help player after this amount of loops into one direction
export var help_after_index: int = 2

# Open hallway door after this amount of seconds
export var hallway_open_exit_after: float = 20.0

# Start to play hallway music after
export var hallway_waiting_music_after: float = 5.0

# Shake camera in hallway after after
export var hallway_camera_shake_after: float = 10.0

# Max position diff to wait
export var max_position_diff_to_wait: float = 100

onready var player = $Player

onready var flat_door = $Environment/Flat/Inside/Door
onready var random_flat_container = $Environment/RandomFlatContainer

onready var hallway_00 = $Environment/Hallway00
onready var hallway_01 = $Environment/Hallway01
onready var hallway_02 = $Environment/Hallway02

onready var flat_spawn = $Trigger/FlatSpawn
onready var random_flat_spawn = $Trigger/RandomFlatSpawn
onready var hallway_spawn = $Trigger/HallwaySpawn
onready var hallway_begin = $Trigger/HallwayLoopBegin
onready var hallway_end = $Trigger/HallwayLoopEnd

onready var main_music = $Sound/MainMusic
onready var waiting_music  = $Sound/WaitingMusic

onready var knock_sound = $Sound/KnockSound
onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

const random_flat_scene = preload("res://Scenes/Part00/Part00_RandomFlat.tscn")

var hallway_help_complete: bool = false
var hallway_exit_enabled: bool = false
var hallway_exit_open: bool = false
var hallway_exiting: bool = false
var loop_index: int = 0
var old_player: Player = null
var home_index = 4

var music_00: int
var music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(2, 5 * 60, false, 5, 5, -5)
	music_01 = main_music.add_part(30, 5 * 60, true, 5, 5, -5)
	
	waiting_music.add_part(13 * 60 + 35, 15 * 60 + 10, true, 5, 5, 0)
	
	connect("scene_started", self, "_on_scene_started")
	
	flat_door.connect("selected", self, "_on_flat_exit_select")
	
	hallway_00.connect("door_selected", self, "_on_hallway_door_select")
	hallway_01.connect("door_selected", self, "_on_hallway_door_select")
	hallway_02.connect("door_selected", self, "_on_hallway_door_select")
	
	main_music.play()
	
	var camera = Global.current_camera
	
	if camera:
		camera.smoothing_enabled = false

func _on_scene_started() -> void:
	yield(timer(1.5), "timeout")
	Global.subtitle.say(tr("NARRATOR00"))

func _on_flat_exit_select():
	player_in_hallway = true
	
	move_with_fade(player, hallway_spawn.position, door_open_sound)

func _on_hallway_door_select(door, index) -> void:
	player_in_hallway = false
	
	if index == home_index:
		if not hallway_exit_open:
			hallway_spawn.global_position = door.global_position
			
			move_with_fade(player, flat_spawn.position, door_open_sound)
		elif hallway_exit_open and not hallway_exiting:
			hallway_exiting = true
			
			main_music.kill(2.0);
			load_scene(next_scene)
	else:
		for child in random_flat_container.get_children():
			remove_child(child)
			child.queue_free()
		
		var random_flat_instance = random_flat_scene.instance()
		
		random_flat_instance.connect("exit_selected", self, "_on_flat_exit_select")
		random_flat_container.add_child(random_flat_instance)
		
		hallway_spawn.global_position = door.global_position
		
		move_with_fade(player, random_flat_spawn.position, door_open_sound)
		
		# Can only exit the hallway after looked into another room
		hallway_exit_enabled = true

var player_in_hallway: bool = false
var previous_player_hallway_position: float = 0.0
var hallway_wait_counter: float = 0.0

func _reset_hallway_wait() -> void:
	if not waiting_music.stopped:
		waiting_music.kill(0.5)
	
	var camera = Global.current_camera
		
	if camera:
		camera.shake = 0.0

func _process_hallway_wait(delta: float) -> void:
	if hallway_exit_open or not hallway_exit_enabled:
		return
	
	if not player_in_hallway:
		_reset_hallway_wait()
		return
	
	if abs(loop_index) > help_after_index and not hallway_help_complete:
		Global.subtitle.say(tr("NARRATOR01"))
		
		hallway_help_complete = true
	
	var camera = Global.current_camera
	
	var player_position = player.global_position.x
	var previous_position = previous_player_hallway_position
	var position_x_diff = abs(player_position - previous_position)
	
	if position_x_diff < max_position_diff_to_wait:
		hallway_wait_counter += delta
		
		var d = hallway_wait_counter / hallway_open_exit_after
		
		# Play the waiting music sequence
		if hallway_wait_counter > hallway_waiting_music_after:
			if waiting_music.stopped:
				waiting_music.play()
			
			waiting_music.global_level = d + 0.33
		
		# Starts to play effects if the player stands long enough at one place
		if hallway_wait_counter > hallway_camera_shake_after:
			# Start to shake the camera more and more
			camera.shake = pow(d + 1.0, 2.0)
		
		# Open the door
		if hallway_wait_counter > hallway_open_exit_after:
			if camera:
				camera.shake = 0.0
			
			main_music.kill(5.0)
			silent_door_open_sound.play()
			
			home_index = hallway_01.get_closest_door(player.global_position)
			hallway_exit_open = true
			
			hallway_00.open_exit(home_index)
			hallway_01.open_exit(home_index)
			hallway_02.open_exit(home_index)
	else:
		previous_player_hallway_position = player_position
		hallway_wait_counter = 0.0
		
		_reset_hallway_wait()

func _dupe_player() -> Node2D:
	var clone = player.duplicate()
	
	clone.register = false
	
	for n in clone.get_children():
		if n.name == "DefaultCamera":
			clone.remove_child(n)
			n.queue_free()
			break
	
	add_child(clone)
	
	return clone

func _process_hallway_loop(_delta: float) -> void:
	var left_end_position = hallway_begin.global_position
	var right_end_position = hallway_end.global_position
	var player_position = player.global_position
	
	# Left end
	if left_end_position.x > player_position.x:
		old_player = _dupe_player()
		
		var diff = left_end_position.x - player_position.x
		
		player.global_position = Vector2(right_end_position.x - diff, player_position.y)
		loop_index -= 1
	
	# Right end
	if right_end_position.x < player_position.x:
		old_player = _dupe_player()
		
		var diff = player_position.x - right_end_position.x
		
		player.global_position = Vector2(left_end_position.x + diff, player_position.y)
		loop_index += 1

func _process(delta: float) -> void:
	if old_player:
		remove_child(old_player)
		old_player.queue_free()
		old_player = null
	
	_process_hallway_loop(delta)
	_process_hallway_wait(delta)

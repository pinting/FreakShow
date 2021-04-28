extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Part02/Part02.tscn"
export var help_after_index: int = 2
export var hallway_open_exit_after: float = 20.0
export var hallway_waiting_music_after: float = 5.0
export var hallway_camera_shake_after: float = 10.0
export var max_position_diff_to_wait: float = 100.0
export var show_red_stop_lamps_from: int = 3

onready var player = $Player
onready var camera = $GameCamera

onready var flat_door = $Environment/Flat/Inside/Door
onready var random_flat_container = $Environment/RandomFlatContainer
onready var hallway = $Environment/Hallway

onready var flat_spawn = $Trigger/FlatSpawn
onready var hallway_spawn = $Trigger/HallwaySpawn
onready var random_flat_spawn = $Trigger/RandomFlatSpawn

onready var main_music = $Sound/MainMusic
onready var waiting_music  = $Sound/WaitingMusic
onready var knock_sound = $Sound/KnockSound
onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

const random_flat_scene = preload("res://Scenes/Part01/Part01_RandomFlat.tscn")

var hallway_is_player_in: bool = false
var hallway_previous_player_position: float = 0.0
var hallway_wait_counter: float = 0.0
var hallway_help_disabled: bool = false
var hallway_exit_enabled: bool = false
var hallway_exit_open: bool = false
var hallway_exiting: bool = false
var hallway_enter_count: int = 0
var home_index = 4

var music_00: int
var music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(2, 5 * 60, false, 5, 5, -5)
	music_01 = main_music.add_part(30, 5 * 60, true, 5, 5, -5)
	
	waiting_music.add_part(13 * 60 + 35, 15 * 60 + 10, true, 5, 5, 0)
	
	hallway.player = player
	hallway.camera = camera
	
	connect("scene_started", self, "_on_scene_started")
	flat_door.connect("selected", self, "_on_flat_exit_select")
	hallway.connect("looped", self, "_on_loop_index_change")
	hallway.container.connect("door_selected", self, "_on_hallway_door_select")
	hallway.left_mirror.connect("door_selected", self, "_on_hallway_door_select")
	hallway.right_mirror.connect("door_selected", self, "_on_hallway_door_select")

func _on_scene_started() -> void:
	# Some empty waiting for a dramatic start
	yield(Game.timer(2.0), "timeout")
	black_screen.fade_out(3.0)
	yield(Game.timer(1.5), "timeout")
	main_music.play()
	SubtitleManager.say(Text.find("Narrator000"))

func _on_loop_index_change(direction: String):
	if abs(hallway.loop_index) > help_after_index and not hallway_help_disabled:
		SubtitleManager.say(Text.find("Narrator001"))
		
		hallway_help_disabled = true

func _enable_next_traffic_lamp(lamps_to_show: int = 0):
	if lamps_to_show <= 0:
		return
	
	for lamp_index in range(lamps_to_show):
		if lamp_index >= len(hallway.container.lamps):
			break
		
		# Enable in the master and the mirrors too
		hallway.left_mirror.lamps[lamp_index].enable()
		hallway.container.lamps[lamp_index].enable()
		hallway.right_mirror.lamps[lamp_index].enable()

func _on_flat_exit_select():
	hallway_is_player_in = true
	hallway_enter_count += 1
	
	_enable_next_traffic_lamp(hallway_enter_count - show_red_stop_lamps_from)
	move_with_fade(player, hallway_spawn.position, door_open_sound)

func _on_hallway_door_select(door, index) -> void:
	hallway_is_player_in = false
	
	if index == home_index:
		if not hallway_exit_open:
			hallway_spawn.global_position = door.global_position

			move_with_fade(player, flat_spawn.position, door_open_sound)
		elif hallway_exit_open and not hallway_exiting:
			hallway_exiting = true
			
			main_music.kill(3.0)
			black_screen.fade_in(3.0)
			yield(Game.timer(3.0), "timeout")
			load_scene(next_scene, true)
	else:
		Tools.remove_childs(random_flat_container)
		
		Game.random_generator.randomize()
		
		var random_flat_instance = random_flat_scene.instance()
		
		random_flat_instance.connect("exit_selected", self, "_on_flat_exit_select")
		random_flat_container.add_child(random_flat_instance)
		
		hallway_spawn.global_position = door.global_position
		
		move_with_fade(player, random_flat_spawn.position, door_open_sound)
		
		# Can only exit the hallway after looked into another room
		hallway_exit_enabled = true

func _reset_hallway_wait() -> void:
	if not waiting_music.stopped:
		waiting_music.kill(0.5)
	
	camera.shake = 0.0

func _process(delta: float) -> void:
	if hallway_exit_open or not hallway_exit_enabled:
		return
	
	if not hallway_is_player_in:
		_reset_hallway_wait()
		return
	
	var player_position = player.global_position.x
	var previous_position = hallway_previous_player_position
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
			camera.shake = 0.0
			
			main_music.kill(5.0)
			silent_door_open_sound.play()
			
			home_index = hallway.container.get_closest_door(player.global_position)
			hallway_exit_open = true
			
			hallway.left_mirror.open_exit(home_index)
			hallway.container.open_exit(home_index)
			hallway.right_mirror.open_exit(home_index)
			
			for lamp_index in range(len(hallway.container.lamps)):
				# Disable in the master and the mirrors too
				hallway.left_mirror.lamps[lamp_index].disable()
				hallway.container.lamps[lamp_index].disable()
				hallway.right_mirror.lamps[lamp_index].disable()
	else:
		hallway_previous_player_position = player_position
		hallway_wait_counter = 0.0
		
		_reset_hallway_wait()

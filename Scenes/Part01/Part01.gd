extends "res://Game/BaseScene.gd"

export var help_after_index: int = 2
export var hallway_open_exit_after: float = 20.0
export var hallway_waiting_music_after: float = 5.0
export var hallway_camera_shake_after: float = 10.0
export var max_position_diff_to_wait: float = 100.0
export var show_red_stop_lamps_from: int = 3

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var flat_door: Node2D = $Environment/Flat/Inside/Door
onready var random_flat_container: Node2D = $Environment/RandomFlatContainer
onready var hallway: Node2D = $Environment/Hallway

onready var flat_spawn: Node2D = $Trigger/FlatSpawn
onready var hallway_spawn: Node2D = $Trigger/HallwaySpawn
onready var random_flat_spawn: Node2D = $Trigger/RandomFlatSpawn

onready var main_music: MusicMixer = $Sound/MainMusic
onready var waiting_music: MusicMixer  = $Sound/WaitingMusic
onready var knock_sound: AudioStreamPlayer = $Sound/KnockSound
onready var door_open_sound: AudioStreamPlayer = $Sound/DoorOpenSound
onready var silent_door_open_sound: AudioStreamPlayer = $Sound/SilentDoorOpenSound

const random_flat_scene = preload("res://Scenes/Part01/Part01_RandomFlat.tscn")

var player_is_in_hallway: bool = false
var hallway_previous_player_position: float = 0.0
var hallway_wait_counter: float = 0.0
var hallway_help_disabled: bool = false
var hallway_exit_enabled: bool = false
var hallway_exit_open: bool = false
var hallway_exiting: bool = false
var hallway_enter_count: int = 0
var hallway_home_index = 4

var music_00: int
var music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(2, 5 * 60, false, 5, 5, 0)
	music_01 = main_music.add_part(30, 5 * 60, true, 5, 5, -5)
	
	waiting_music.add_part(13 * 60 + 35, 15 * 60 + 10, true, 5, 5, 0)
	
	connect("scene_started", self, "_on_scene_started")
	flat_door.connect("selected", self, "_on_flat_exit_select")
	hallway.connect("looped", self, "_on_loop_index_change")
	
	for container in hallway.containers:
		container.connect("door_selected", self, "_on_hallway_door_select")

func _on_scene_started() -> void:
	yield(Tools.timer(2.0), "timeout")
	main_music.play()
	yield(Tools.timer(1.0), "timeout")
	black_screen.fade_out(5.0)
	SubtitleManager.say(Text.find("Narrator000"))

func _on_loop_index_change(_direction: String) -> void:
	if abs(hallway.loop_index) > help_after_index and not hallway_help_disabled:
		SubtitleManager.say(Text.find("Narrator001"))
		hallway_help_disabled = true

func _enable_next_traffic_lamp(lamps_to_show: int = 0) -> void:
	if not lamps_to_show:
		return
	
	for lamp_index in range(lamps_to_show):
		if lamp_index >= len(hallway.container.lamps):
			break
		
		for lamps in hallway.get_each("lamps"):
			lamps[lamp_index].enable()

func _on_flat_exit_select() -> void:
	player_is_in_hallway = true
	hallway_enter_count += 1

	var next = int(max(0, hallway_enter_count - show_red_stop_lamps_from))

	_enable_next_traffic_lamp(next)
	move_player(player, hallway_spawn.position, door_open_sound)

func _on_hallway_door_select(door, index) -> void:
	player_is_in_hallway = false
	
	if index == hallway_home_index:
		if not hallway_exit_open:
			hallway_spawn.global_position = door.global_position
			move_player(player, flat_spawn.position, door_open_sound)
		elif hallway_exit_open and not hallway_exiting:
			hallway_exiting = true
			main_music.kill(3.0)
			yield(black_screen.fade_in(3.0), "tween_completed")
			load_next_scene()
	else:
		var random_flat_instance = random_flat_scene.instance()
		
		random_flat_instance.connect("exit_selected", self, "_on_flat_exit_select")
		
		Tools.remove_childs(random_flat_container)
		random_flat_container.add_child(random_flat_instance)
		
		hallway_spawn.global_position = door.global_position
		
		move_player(player, random_flat_spawn.position, door_open_sound)
		
		# Can only exit the hallway after looked into another room
		hallway_exit_enabled = true

func _reset_hallway_wait() -> void:
	if not waiting_music.stopped:
		waiting_music.kill(0.5)
	
	camera.shake = 0.0

func _process(delta: float) -> void:
	if hallway_exit_open or not hallway_exit_enabled:
		return
	
	if not player_is_in_hallway:
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
			
			hallway_home_index = hallway.container.get_closest_door(player.global_position)
			hallway_exit_open = true
			
			hallway.call_each("open_exit", [hallway_home_index])
			
			for lamp_index in range(len(hallway.container.lamps)):
				for lamps in hallway.get_each("lamps"):
					lamps[lamp_index].disable()
	else:
		hallway_previous_player_position = player_position
		hallway_wait_counter = 0.0
		
		_reset_hallway_wait()

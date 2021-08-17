extends "res://Game/BaseScene.gd"

export var random_flat = preload("res://Scenes/Part01/Part01_RandomFlat.tscn")

const default_home_index: int = 4
const help_after_index: int = 2
const show_red_stop_lamps_from: int = 3
const max_position_diff_to_wait: float = 100.0

const hallway_waiting_music_after: float = 5.0
const hallway_camera_shake_after: float = 10.0
const hallway_open_exit_after: float = 20.0

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var flat_door: Node2D = $Environment/Flat/Inside/Floor/Door
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

var player_is_in_hallway: bool = false
var home_index: int = default_home_index
var previous_player_position: Vector2 = Vector2.ZERO
var wait_counter: float = 0.0
var help_disabled: bool = false
var can_exit_open: bool = false
var is_exit_open: bool = false
var enter_count: int = 0
var exiting: bool = false

var music_00: int
var music_01: int

var waiting_music_00: int
var waiting_music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(2, 5 * 60, false, 5, 5, 0)
	music_01 = main_music.add_part(30, 5 * 60, true, 5, 5, -5)
	
	waiting_music_00 = waiting_music.add_part(13 * 60 + 35, 15 * 60 + 10, false, 10, 5, 0)
	waiting_music_01 = waiting_music.add_part(13 * 60 + 35, 15 * 60 + 10, true, 5, 5, -10)
	
	connect("scene_started", self, "_on_scene_started", [], CONNECT_ONESHOT)
	flat_door.connect("selected", self, "_on_flat_exit_selected")
	hallway.connect("looped", self, "_on_loop_index_change")
	
	for container in hallway.containers:
		container.connect("door_selected", self, "_on_hallway_door_selected")

func _on_scene_started() -> void:
	yield(Tools.timer(2.0), "timeout")
	main_music.play()
	yield(Tools.timer(1.0), "timeout")
	black_screen.fade_out(5.0)
	SubtitleManager.say(Text.find("Narrator000"))

func _on_loop_index_change(_direction: String) -> void:
	if abs(hallway.loop_index) > help_after_index and not help_disabled:
		SubtitleManager.say(Text.find("Narrator001"))
		help_disabled = true

func _enable_next_traffic_lamp(lamps_to_show: int = 0) -> void:
	if not lamps_to_show:
		return
	
	for lamp_index in range(lamps_to_show):
		if lamp_index >= len(hallway.container.lamps):
			break
		
		for lamps in hallway.get_each("lamps"):
			lamps[lamp_index].enable()

func _on_flat_exit_selected() -> void:
	player_is_in_hallway = true
	enter_count += 1

	var next = int(max(0, enter_count - show_red_stop_lamps_from))

	_enable_next_traffic_lamp(next)
	move_player(player, hallway_spawn.position, door_open_sound)

func _on_hallway_door_selected(door, index) -> void:
	player_is_in_hallway = false
	
	_reset_hallway_wait()
	
	if index == home_index:
		if not is_exit_open:
			hallway_spawn.global_position = door.global_position
			move_player(player, flat_spawn.position, door_open_sound)
		elif is_exit_open and not exiting:
			exiting = true
			waiting_music.kill(3.0)
			yield(black_screen.fade_in(3.0), "completed")
			load_next_scene()
	else:
		Tools.random_generator.randomize()
		
		var random_flat_instance = random_flat.instance()
		
		random_flat_instance.connect("exit_selected", self, "_on_flat_exit_selected")
		
		Tools.remove_childs(random_flat_container)
		random_flat_container.add_child(random_flat_instance)
		
		hallway_spawn.global_position = door.global_position
		
		move_player(player, random_flat_spawn.position, door_open_sound)
		
		# Can only exit the hallway after looked into another room
		can_exit_open = true

func _reset_hallway_wait() -> void:
	wait_counter = 0.0
	
	if not is_exit_open and not waiting_music.stopped:
		waiting_music.kill(1.0)
	
	if camera.shake > 0.0:
		camera.change_shake(0.0, 1.0)

func _process(delta: float) -> void:
	if is_exit_open or not can_exit_open:
		return
	
	if not player_is_in_hallway:
		return
	
	var position_x_diff = abs(player.global_position.x - previous_player_position.x)
	
	if position_x_diff < max_position_diff_to_wait:
		wait_counter += delta
		
		# Open the door
		if wait_counter > hallway_open_exit_after:
			camera.change_shake(0.0, 1.0)
			main_music.kill(5.0)
			silent_door_open_sound.play()
			
			home_index = hallway.container.get_closest_door(player.global_position)
			is_exit_open = true
			
			hallway.call_each("open_exit", [home_index])
			
			for lamp_index in range(len(hallway.container.lamps)):
				for lamps in hallway.get_each("lamps"):
					lamps[lamp_index].disable()
		
		# Start to play shake effect
		elif wait_counter > hallway_camera_shake_after:
			camera.change_shake(10.0, 2.0)
		
		# Play the waiting music sequence
		elif wait_counter > hallway_waiting_music_after:
			if waiting_music.stopped:
				waiting_music.play()
	else:
		previous_player_position = player.global_position
		
		_reset_hallway_wait()

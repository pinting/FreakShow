extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part01/Part01.tscn"

# Help player after this amount of loops into one direction
export var help_after_index: int = 2

onready var player = $Player
onready var music_mixer = $MusicMixer

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

onready var knock_sound = $Sound/KnockSound
onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

const random_flat_scene = preload("res://Scenes/Part00/Part00_RandomFlat.tscn")
const home_index = 4

var hallway_help_complete: bool = false
var hallway_stage_00: bool = true
var hallway_stage_01: bool = false
var loop_direction: float = 0.0
var loop_index: int = 0
var hallway_exit_open: bool = false
var hallway_exiting: bool = false
var old_player = null

var music_00: int
var music_01: int

func _ready():
	music_00 = music_mixer.add_part(2, 5 * 60, false, 5, 5, -5)
	music_01 = music_mixer.add_part(30, 5 * 60, true, 5, 5, -5)
	
	connect("scene_started", self, "_on_scene_started")
	
	flat_door.connect("selected", self, "_on_flat_exit_select")
	
	hallway_00.connect("door_selected", self, "_on_hallway_door_select")
	hallway_01.connect("door_selected", self, "_on_hallway_door_select")
	hallway_02.connect("door_selected", self, "_on_hallway_door_select")
	
	music_mixer.play()
	
	var camera = Global.current_camera
	
	if camera:
		camera.smoothing_enabled = false

func _on_scene_started():
	yield(timer(1.5), "timeout")
	Global.subtitle.say(tr("NARRATOR00"))

func _on_flat_exit_select():
	move_with_fade(player, hallway_spawn.position, door_open_sound)

func _on_hallway_door_select(door, index):
	if index == home_index:
		if not hallway_exit_open:
			hallway_spawn.global_position = door.global_position
			
			move_with_fade(player, flat_spawn.position, door_open_sound)
		elif hallway_exit_open and not hallway_exiting:
			hallway_exiting = true
			
			music_mixer.kill(2.0);
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

func _process_hallway_door(_delta: float):
	if hallway_exit_open:
		return
	
	if abs(loop_index) > help_after_index and not hallway_help_complete:
		Global.subtitle.say(tr("NARRATOR01"))
		
		hallway_help_complete = true
	
	if hallway_stage_00 and abs(loop_direction) == 1:
		hallway_stage_00 = false
		hallway_stage_01 = true
	
	if hallway_stage_01 and loop_direction == 0:
		silent_door_open_sound.play()
		hallway_01.open_exit(home_index)
		hallway_exit_open = true

func _dupe_player():
	var clone = player.duplicate()
	
	var duplicate_camera = null
	
	for n in clone.get_children():
		if n.name == "DefaultCamera":
			duplicate_camera = n
			break
	
	clone.remove_child(duplicate_camera)
	duplicate_camera.queue_free()
	add_child(clone)
	
	return clone

func _process_hallway_loop(_delta: float):
	var left_end_position = hallway_begin.global_position
	var right_end_position = hallway_end.global_position
	var player_position = player.global_position
	
	# Left end
	if left_end_position.x > player_position.x:
		old_player = _dupe_player()
		
		var diff = left_end_position.x - player_position.x
		
		player.global_position = Vector2(right_end_position.x - diff, player_position.y)
		loop_index -= 1
		loop_direction -= 1
		loop_direction = max(loop_direction, -1)
	
	# Right end
	if right_end_position.x < player_position.x:		
		old_player = _dupe_player()
		
		var diff = player_position.x - right_end_position.x
		
		player.global_position = Vector2(left_end_position.x + diff, player_position.y)
		loop_index += 1
		loop_direction += 1
		loop_direction = min(loop_direction, 1)

func _process(delta: float):
	if old_player:
		remove_child(old_player)
		old_player.queue_free()
	
	_process_hallway_loop(delta)
	_process_hallway_door(delta)

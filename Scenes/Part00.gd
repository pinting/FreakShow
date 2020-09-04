extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part01.tscn"

# Help player after this amount of loops into one direction
export var help_after_index: int = 2

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var flat_door = $Environment/Flat/Inside/Door
onready var hallway_door = $Environment/Hallway/Inside/Door04

onready var flat_spawn = $Trigger/FlatSpawn
onready var hallway_spawn = $Trigger/HallwaySpawn
onready var hallway_begin = $Trigger/HallwayLoopBegin
onready var hallway_end = $Trigger/HallwayLoopEnd

onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

var hallway_help_complete: bool = false
var hallway_stage_00: bool = true
var hallway_stage_01: bool = false
var loop_direction: float = 0.0
var loop_index: int = 0
var exiting: bool = false

var music_00: int

func _ready():
	music_00 = music_mixer.add_part(2, 5 * 60, true, 5, 5, -5)
	
	flat_door.connect("selected", self, "_on_flat_exit_select")
	hallway_door.connect("selected", self, "_on__hallway_door_select")
	connect("scene_started", self, "_on_scene_started")
	
	music_mixer.play()
	
	hallway_door.knocking = false

func _open_door(next_position):
	door_open_sound.play()
	fade_out(1.0)
	yield(timer(1.5), "timeout")
	player.position = next_position
	fade_in(1.0)

func _on_scene_started():
	yield(timer(1.5), "timeout")
	Global.subtitle.say(tr("NARRATOR00"))

func _on_flat_exit_select():
	_open_door(hallway_spawn.position)

func _on__hallway_door_select():
	if hallway_door.locked and not hallway_door.knocking:
		_open_door(flat_spawn.position)
	elif not hallway_door.locked and not exiting:
		exiting = true
		
		music_mixer.kill(2.0);
		
		load_scene(next_scene)

func _process__hallway_door(_delta: float):
	if not hallway_door.locked:
		return
	
	if abs(loop_index) > help_after_index and not hallway_help_complete:
		Global.subtitle.say(tr("NARRATOR01"))
		
		hallway_help_complete = true
	
	if hallway_stage_00 and abs(loop_direction) == 1:
		hallway_stage_00 = false
		hallway_stage_01 = true
	
	if hallway_stage_01 and loop_direction == 0:
		silent_door_open_sound.play()
		hallway_door.open()

func _process_hallway_loop(_delta: float):
	var left_end_position = hallway_begin.global_position
	var right_end_position = hallway_end.global_position
	var player_position = player.global_position
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
		loop_index -= 1
		loop_direction -= 1
		loop_direction = max(loop_direction, -1)
		hallway_door.knocking = true
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)
		loop_index += 1
		loop_direction += 1
		loop_direction = min(loop_direction, 1)
		hallway_door.knocking = true

func _process(delta: float):
	_process_hallway_loop(delta)
	_process__hallway_door(delta)

extends "res://Scenes/BaseScene.gd"

# Next scene
export var NEXT_SCENE: String = "res://Scenes/Part01.tscn"

# Help player after this amount of loops into one direction
export var HELP_AFTER_INDEX: int = 3

onready var flat_exit_door = $Environment/Flat/Inside/Door
onready var hallway_exit = $Environment/Hallway/Inside/Door04

onready var hallway_spawn = $Points/HallwaySpawn
onready var hallway_loop_begin = $Points/HallwayLoopBegin
onready var hallway_loop_end = $Points/HallwayLoopEnd

onready var door_sound = $Sounds/DoorSound

var hallway_exit_visible: bool = false
var hallway_stage_00: bool = true
var hallway_stage_01: bool = false
var loop_direction: int = 0
var loop_index: int = 0
var exiting: bool = false

var music_00: int

func _ready():
	music_00 = music_mixer.add_part(2, 5 * 60, true, 5, 5, -5)
	
	flat_exit_door.connect("selected", self, "_on_flat_exit_select")
	connect("scene_started", self, "_on_scene_started")
	
	if not Global.NO_SOUNDS:
		music_mixer.play()

func _on_scene_started():
	yield(timer(1.5), "timeout")
	Global.subtitle.say(tr("NARRATOR00"))

func _on_flat_exit_select():
	if not Global.NO_SOUNDS:
		door_sound.play()
	
	fade_out(1.0)
	yield(timer(1.5), "timeout")
	player.position = hallway_spawn.position
	fade_in(1.0)

func _on_hallway_exit_select():
	if exiting:
		return
	
	exiting = true
	
	music_mixer.kill(2.0);
	fade_out(1.0)
	yield(timer(2.0), "timeout")
	
	Global.load_scene(NEXT_SCENE)

func _process_hallway_exit(_delta: float):
	if hallway_exit_visible:
		return
	
	if abs(loop_index) > HELP_AFTER_INDEX:
		Global.subtitle.say(tr("NARRATOR01"))
	
	if hallway_stage_00 and abs(loop_direction) == 1:
		hallway_stage_00 = false
		hallway_stage_01 = true
	
	if hallway_stage_01 and loop_direction == 0:
		hallway_exit.open()
		hallway_exit.connect("selected", self, "_on_hallway_exit_select")
		
		hallway_exit_visible = true

func _process_hallway_loop(_delta: float):
	var left_end_position = hallway_loop_begin.global_position
	var right_end_position = hallway_loop_end.global_position
	var player_position = player.global_position
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
		loop_index -= 1
		loop_direction -= 1
		loop_direction = max(loop_direction, -1)
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)
		loop_index += 1
		loop_direction += 1
		loop_direction = min(loop_direction, 1)

func _process(delta: float):
	_process_hallway_loop(delta)
	_process_hallway_exit(delta)

extends "res://Scenes/BaseScene.gd"

# Next scene
export var NEXT_SCENE = "res://Scenes/Part01.tscn"

# How many hallway loops the player needs to pass
export var HALLWAY_LOOP = 1

onready var flat_exit_door = $Environment/Flat/Inside/Door
onready var hallway_exit = $Environment/Hallway/Inside/Door04

onready var hallway_spawn = $Points/HallwaySpawn
onready var loop_begin = $Points/LoopBegin
onready var loop_end = $Points/LoopEnd

onready var door_sound = $Sounds/DoorSound

var hallway_exit_visible = false
var loop_counter = 0

var music_00

func _ready():
	music_00 = music_mixer.add_part(0, 5 * 60, true, 5, 5, -5)
	
	flat_exit_door.connect("select", self, "_on_flat_exit_select")
	
	if not Global.NO_SOUNDS:
		music_mixer.play()

func _on_flat_exit_select():
	fade_out(1)
	door_sound.play()
	yield(timer(1.5), "timeout")
	player.position = hallway_spawn.position
	fade_in(1)

func _on_hallway_exit_select():
	music_mixer.kill(2);
	fade_out(1)
	yield(timer(2), "timeout")
	load_scene(NEXT_SCENE)

func _process_hallway_exit(delta):
	if hallway_exit_visible or abs(loop_counter) < HALLWAY_LOOP:
		return
	
	hallway_exit.open()
	hallway_exit.connect("select", self, "_on_hallway_exit_select")
	
	hallway_exit_visible = true

func _process_loop(delta):
	var left_end_position = loop_begin.get_global_position()
	var right_end_position = loop_end.get_global_position()
	var player_position = player.get_global_position()
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
		loop_counter -= 1
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)
		loop_counter += 1

func _process(delta):
	_process_loop(delta)
	_process_hallway_exit(delta)

extends "res://Scenes/BaseScene.gd"

# Next scene
export var NEXT_SCENE = "res://Scenes/Part01.tscn"

onready var flat_exit_door = $Environment/Flat/Inside/Door
onready var hallway_exit = $Environment/Hallway/Inside/Door04

onready var hallway_spawn = $Points/HallwaySpawn
onready var hallway_loop_begin = $Points/HallwayLoopBegin
onready var hallway_loop_end = $Points/HallwayLoopEnd

onready var door_sound = $Sounds/DoorSound

var hallway_exit_visible = false
var hallway_stage_00 = true
var hallway_stage_01 = false
var loop_index = 0
var exiting = false

var music_00

func _ready():
	music_00 = music_mixer.add_part(0, 5 * 60, true, 5, 5, -5)
	
	flat_exit_door.connect("select", self, "_on_flat_exit_select")
	connect("intro_over", self, "_on_intro_over")
	
	if not Global.NO_SOUNDS:
		music_mixer.play()

func _on_intro_over():
	Global.subtitle.say(tr("NARRATOR00"))

func _on_flat_exit_select():
	fade_out(1)
	door_sound.play()
	yield(timer(1.5), "timeout")
	player.position = hallway_spawn.position
	fade_in(1)

func _on_hallway_exit_select():
	if exiting:
		return
	
	exiting = true
	
	music_mixer.kill(2);
	fade_out(1)
	yield(timer(2), "timeout")
	Global.load_scene(NEXT_SCENE)

func _process_hallway_exit(delta):
	if hallway_exit_visible:
		return
	
	if hallway_stage_00 and abs(loop_index) == 1:
		hallway_stage_00 = false
		hallway_stage_01 = true
		
		Global.subtitle.say(tr("NARRATOR01"))
	
	if hallway_stage_01 and loop_index == 0:
		hallway_exit.open()
		hallway_exit.connect("select", self, "_on_hallway_exit_select")
		
		hallway_exit_visible = true

func _process_hallway_loop(delta):
	var left_end_position = hallway_loop_begin.get_global_position()
	var right_end_position = hallway_loop_end.get_global_position()
	var player_position = player.get_global_position()
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
		loop_index -= 1
		loop_index = max(loop_index, -1)
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)
		loop_index += 1
		loop_index = min(loop_index, 1)

func _process(delta):
	_process_hallway_loop(delta)
	_process_hallway_exit(delta)

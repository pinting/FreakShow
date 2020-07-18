extends "res://Scenes/BaseScene.gd"

# Environment
onready var flat_door = $Environment/Flat/Inside/Door
onready var hallway_door = $Environment/Hallway/Floor/Door00/Door

# Points
onready var hallway_spawn = $Points/HallwaySpawn
onready var loop_begin = $Points/LoopBegin
onready var loop_end = $Points/LoopEnd

func _ready():
	flat_door.connect("select", self, "_on_flat_door_select")

func _on_flat_door_select():
	fade_out(0.5)
	yield(get_tree().create_timer(0.5), "timeout")
	player.position = hallway_spawn.position
	fade_in(0.5)

func _process_loop(delta):
	var left_end_position = loop_begin.get_global_position()
	var right_end_position = loop_end.get_global_position()
	var player_position = player.get_global_position()
	
	# Left end
	if left_end_position.x > player_position.x:
		var diff = left_end_position.x - player_position.x
		
		player.position = Vector2(right_end_position.x - diff, player_position.y)
	
	# Right end
	if right_end_position.x < player_position.x:
		var diff = player_position.x - right_end_position.x
		
		player.position = Vector2(left_end_position.x + diff, player_position.y)

func _process(delta):
	_process_loop(delta)

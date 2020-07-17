extends "res://Scenes/BaseScene.gd"

# Environment
onready var flat_door = $Environment/Flat/Inside/Door
onready var hallway_door_00 = $Environment/Hallway/Floor/Door00/Door

# Loop
onready var loop_begin = $Triggers/LoopBegin
onready var loop_end = $Triggers/LoopEnd

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

extends Node2D

onready var hallway_door_00 = $Inside/Door00
onready var hallway_door_01 = $Inside/Door01
onready var hallway_door_02 = $Inside/Door02
onready var hallway_door_03 = $Inside/Door03
onready var hallway_door_04 = $Inside/Door04
onready var hallway_door_05 = $Inside/Door05
onready var hallway_door_06 = $Inside/Door06
onready var hallway_door_07 = $Inside/Door07

signal door_selected

var doors

func _ready():
	doors = [
		hallway_door_00,
		hallway_door_01,
		hallway_door_02,
		hallway_door_03,
		hallway_door_04,
		hallway_door_05,
		hallway_door_06,
		hallway_door_07
	]
	
	for i in range(len(doors)):
		doors[i].connect("selected", self, "_on_hallway_door_select", [doors[i], i])

func _on_hallway_door_select(door: Node2D, index: int):
	emit_signal("door_selected", door, index)

func open_exit(index: int):
	doors[index].open()

func get_closest_door(target: Vector2) -> int:
	var min_distance = INF
	var index = 0
	
	for i in range(len(doors)):
		var d =  target.distance_to(doors[i].global_position)
		
		if min_distance > d:
			min_distance = d
			index = i
	
	return index

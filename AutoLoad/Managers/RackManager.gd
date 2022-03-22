extends Node

const GdRackClient = preload("res://gdnative/gdrackclient.gdns")
const SIZE = 8

onready var client = GdRackClient.new()

var previous = []

func _ready() -> void:
	for index in range(SIZE):
		previous.push_back(0.0);

func send_data(index: int, voltage: float):
	assert(index < SIZE and index >= 0)
	
	voltage = min(max(-10.0, voltage), 10.0)
	
	if previous[index] == voltage:
		return
	
	previous[index] = voltage;
	
	var data = "{index};{voltage}".format({
		"index": index, 
		"voltage": voltage 
	})
	
	client.send_data(data)

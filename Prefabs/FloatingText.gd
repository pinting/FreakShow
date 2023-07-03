extends Node2D

@export var child: PackedScene = preload("res://Prefabs/FloatingTextChild.tscn")
@export var labels: Array = []
@export var delay_between: float = 5.0
@export var auto_start: bool = false

var current_index: int = 0
var started: bool = false

func _ready() -> void:
	if auto_start:
		start()

func start() -> void:
	if started or not len(labels):
		return
	
	started = true
	
	while started:
		var instance = child.instantiate()

		instance.label_text = labels[current_index % len(labels)]
		current_index += 1
		
		_insert_effect(instance)
		
		await Tools.wait(delay_between)

func stop() -> void:
	started = false

func _insert_effect(instance) -> void:
	self.add_child(instance)

	await Tools.wait(instance.particle.lifetime)

	# TODO
	# Tools.destroy_node(instance)

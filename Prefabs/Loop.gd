class_name Loop
extends Node2D

export var create_dupe_for_pickables: bool = false

onready var container: Node2D = $Container
onready var area_shape: CollisionShape2D = $Area/Shape

var left_mirror: Node2D = null
var right_mirror: Node2D = null
var loop_begin: Vector2 = Vector2.ZERO
var loop_end: Vector2 = Vector2.ZERO

var player: Player = null
var camera: Camera2D = null
var pickables_index: Dictionary = {}

var loop_index: int = 0
var copies: Array = []

signal looped

func _ready() -> void:
	assert(area_shape.shape is RectangleShape2D, "Area shape is missing")

	var extents = area_shape.shape.extents

	loop_begin = global_position - Vector2(extents.x, 0)
	loop_end = global_position + Vector2(extents.x, 0)
	
	_init_left()
	_init_right()

func register_pickable(pickable: Pickable) -> void:
	pickables_index[pickable.get_instance_id()] = loop_index

func _init_left():
	var extents = area_shape.shape.extents
	
	left_mirror = container.duplicate()
	left_mirror.position.x -= 2 * extents.x
	
	add_child(left_mirror)

func _init_right():
	var extents = area_shape.shape.extents
	
	right_mirror = container.duplicate()
	right_mirror.position.x += 2 * extents.x
	
	add_child(right_mirror)

# When reaching the end of the loop the player is teleported to the
# beginning, but a shallow clone stays at the old position for one
# tick. This solves a flickering issue.
func _dupe(clone, parent) -> void:
	copies.push_back(clone)
	parent.add_child(clone)

func _process_copies(_delta: float) -> void:
	for object in copies:
		object.get_parent().remove_child(object)
		object.queue_free()
	
	copies = []

func _turn(d: int) -> void:
	var ids = pickables_index.keys()

	for id in ids:
		var pickable = instance_from_id(id)
		var index = pickables_index[id]
		
		if index == loop_index:
			if loop_begin.x > pickable.position.x:
				pickables_index[id] -= 1
			elif loop_end.x < pickable.position.x:
				pickables_index[id] += 1
	
	loop_index += d

func _update_pickables(d: int) -> void:
	var ids = pickables_index.keys()
	var extents = area_shape.shape.extents

	for id in ids:
		var index = pickables_index[id]
		var index_diff = abs(loop_index - index)
		var pickable = instance_from_id(id)
		var diff = Vector2(d * 2 * extents.x, 0)
		
		if index_diff > 1:
			pickable.disable()
			pickable.visible = false
			return

		if pickable.disabled:
			pickable.enable()
			pickable.visible = true
		else:
			if create_dupe_for_pickables:
				var dupe_00 = pickable.create_clone()
				var dupe_01 = pickable.create_clone()
				
				dupe_01.global_position += diff
				dupe_00.disable()
				dupe_01.disable()

				_dupe(dupe_00, pickable)
				_dupe(dupe_01, pickable)

			pickable.reset(diff, 0, false, false)
		

func _process_player(_delta: float) -> void:
	assert(player, "Player is not set")
	assert(camera, "Camera is not set")
	
	var player_position = player.global_position
	var camera_position = camera.global_position
	
	if loop_begin.x > player_position.x:
		_dupe(player.create_clone(), player.get_parent())
		
		var loop_diff = loop_begin.x - player_position.x
		var camera_diff = player_position - camera_position
		
		player.global_position = Vector2(loop_end.x - loop_diff, player_position.y)
		camera.global_position = player.global_position - camera_diff
		
		_turn(-1)
		_update_pickables(1)
		emit_signal("looped", "left")
	
	if loop_end.x < player_position.x:
		_dupe(player.create_clone(), player.get_parent())
		
		var loop_diff = player_position.x - loop_end.x
		var camera_diff = player_position - camera_position
		
		player.global_position = Vector2(loop_begin.x + loop_diff, player_position.y)
		camera.global_position = player.global_position - camera_diff
		
		_turn(1)
		_update_pickables(-1)
		emit_signal("looped", "right")

func _process(delta: float) -> void:
	_process_copies(delta)
	_process_player(delta)

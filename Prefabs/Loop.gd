class_name Loop
extends Node2D

# Player node path
export (NodePath) var player_node

# Area shape node path
export (NodePath) var area_shape_node

# Container node path
export (NodePath) var container_node

# Loop both, left or right sides
export (String, "both", "left", "right") var loop_mode = "both"

# Copy the container to both, left or right sides
export (String, "both", "left", "right") var mirror_mode = "both"

var player: Player
var area_shape: CollisionShape2D
var area: Area2D
var container: Node2D

var loop_top_left: Vector2
var loop_bottom_right: Vector2

var containers = []

var node_index_store: Dictionary = {}
var loop_index: int = 0
var copies: Array = []

signal looped

func _ready() -> void:
	player = get_node(player_node)
	area_shape = get_node(area_shape_node)
	area = area_shape.get_parent()

	assert(player, "Player is not set")
	assert(area_shape.shape is RectangleShape2D, "Shape is not RectangleShape2D")
	assert(area.position == Vector2.ZERO, "Area2D relative position needs to be zero")
	assert(area_shape.position == Vector2.ZERO, "RectangleShape2D relative position needs to be zero")

	var extents = area_shape.shape.extents

	loop_top_left = global_position - Vector2(extents.x, extents.y)
	loop_bottom_right = global_position + Vector2(extents.x, extents.y)
	
	if container_node:
		container = get_node(container_node)
		
		_mirror()

func _mirror():
	if not container:
		return
	
	containers.push_back(container)
	
	if mirror_mode == "left" or mirror_mode == "both":
		_mirror_left()
	
	if mirror_mode == "right" or mirror_mode == "both":
		_mirror_right()

func _mirror_left():
	var extents = area_shape.shape.extents
	var left_mirror = container.duplicate()
	
	left_mirror.position.x -= 2 * extents.x
	
	containers.push_front(left_mirror)
	add_child(left_mirror)

func _mirror_right():
	var extents = area_shape.shape.extents
	var right_mirror = container.duplicate()
	
	right_mirror.position.x += 2 * extents.x
	
	containers.push_back(right_mirror)
	add_child(right_mirror)

# When reaching the end of the loop the player is teleported to the
# beginning, but a shallow clone stays at the old position for one
# tick. This solves a flickering issue.
func _dupe(node: Node2D) -> void:
	var parent = node.get_parent()
	var clone

	if node.has_method("create_clone"):
		clone = node.create_clone()
	else:
		clone = node.duplicate()
	
	copies.push_back(clone)
	parent.add_child(clone)

func _update_player(d: int) -> void:
	assert(d == -1 or d == 1, "Difference needs to be minus or plus one")
	
	var camera = CameraManager.current
	var cursor_display = VirtualCursorManager.display
	
	assert(camera, "GameCamera is not registered")
	assert(cursor_display, "VirtualCursorManager is not registered")
	
	var camera_diff = player.global_position - camera.global_position
	
	var tl = loop_top_left
	var br = loop_bottom_right
	
	if d == -1:
		player.global_position.x = br.x - (tl.x - player.global_position.x)
	elif d == 1:
		player.global_position.x = tl.x + (player.global_position.x - br.x)
	
	camera.reset(player.global_position - camera_diff, false)

func _update_node_index_store() -> void:
	var ids = node_index_store.keys()

	for id in ids:
		var pickable = instance_from_id(id)
		var index = node_index_store[id]
		
		if index == loop_index:
			if loop_top_left.x > pickable.position.x:
				node_index_store[id] -= 1
			elif loop_bottom_right.x < pickable.position.x:
				node_index_store[id] += 1

func _enable_node(node: Node2D) -> void:
	if node.is_in_group("pickable") or node.is_in_group("selectable"):
		node.enable()

	node.visible = true

func _disable_node(node: Node2D) -> void:
	if node.is_in_group("pickable") or node.is_in_group("selectable"):
		node.disable()
	
	node.visible = false

func _apply_diff(node: Node2D, d: int) -> void:
	var extents = area_shape.shape.extents
	var diff = Vector2(d * 2 * extents.x, 0)
	
	if node.is_in_group("pickable"):
		# Position of a RigidBody cannot be manipulated directly
		node.reset(diff, 0, false, true)
	else:
		node.global_position += diff

func _update_looped_nodes(d: int) -> void:
	var ids = node_index_store.keys()

	for id in ids:
		var node = instance_from_id(id)
		
		# Index of the item in store
		var index = node_index_store[id]
		
		# Difference between the current and the item index
		var index_diff = abs(loop_index - index)
		
		if index_diff > 1:
			_disable_node(node)
		elif not node.visible:
			_enable_node(node)
		else:
			_apply_diff(node, d)

func _turn(d: int) -> void:
	assert(d == -1 or d == 1, "Difference needs to be minus or plus one")
	
	_update_player(d)
	_update_node_index_store()
	
	loop_index += d
	
	_update_looped_nodes(-1 * d)

func _process_copies(_delta: float) -> void:
	for object in copies:
		object.get_parent().remove_child(object)
		object.queue_free()
	
	copies = []

func _process_loop(_delta: float) -> void:
	var bellow_top = player.global_position.y > loop_top_left.y
	var above_bottom = player.global_position.y < loop_bottom_right.y
	
	if not bellow_top or not above_bottom:
		return
	
	var before_left = loop_top_left.x > player.global_position.x
	var after_right = loop_bottom_right.x < player.global_position.x
	
	var left_enabled = loop_mode == "both" or loop_mode == "left"
	var right_enabled = loop_mode == "both" or loop_mode == "right"
	
	if left_enabled and before_left:
		_dupe(player)
		_turn(-1)
		emit_signal("looped", "left")
	
	if right_enabled and after_right:
		_dupe(player)
		_turn(1)
		emit_signal("looped", "right")

func _process(delta: float) -> void:
	_process_copies(delta)
	_process_loop(delta)

func register_pickable(node: Node2D, index_offset: int = 0) -> void:
	node_index_store[node.get_instance_id()] = loop_index + index_offset

func get_each(key: String):
	var result = []
	
	for c in containers:
		result.push_back(c.get(key))
	
	return result

func set_each(key: String, value) -> void:
	for c in containers:
		c.set(key, value)

func call_each(key: String, parameters: Array = []) -> void:
	for c in containers:
		c.callv(key, parameters)

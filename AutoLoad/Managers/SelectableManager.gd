extends Node

var disable: bool = false

var viewport_selection: PureSelectable = null
var world_selection: PureSelectable = null

signal cursor_entered(selectable)
signal cursor_exited(selectable)

func can_hover(selectable: PureSelectable) -> bool:
	var selectable_id = selectable.get_instance_id()

	return \
		not disable and \
		not selectable.disabled and \
		selectable.visible and \
		CursorManager.is_free(selectable_id)

func is_hovering(selectable: PureSelectable, mouse_position: Vector2) -> bool:
	if can_hover(selectable):
		var rect = selectable.get_selection_area()
		
		if rect.has_point(selectable.to_local(mouse_position)):
			return true
	
	return false

func get_absolute_z_index(target: Node2D) -> int:
	var node = target
	var z_index = 0

	while node and node is Node2D:
		z_index += node.z_index

		if !node.z_as_relative:
			break

		node = node.get_parent()
	
	return z_index

func get_top(mouse_position: Vector2, viewport_based: bool) -> PureSelectable:
	var tree = get_tree()
	var selectable_group = tree.get_nodes_in_group("selectable")
	
	var result = null
	var result_z_index = -INF
	
	for selectable in selectable_group:
		if selectable.viewport_based_cursor != viewport_based:
			continue
		
		var selectable_z_index = get_absolute_z_index(selectable)
		
		var is_selected = is_hovering(selectable, mouse_position)
		var is_front = selectable_z_index > result_z_index
		var is_visible = selectable.visible
		
		if is_selected and is_front and is_visible:
			result = selectable
			result_z_index = selectable_z_index
	
	return result

func is_selected(selectable: PureSelectable) -> bool:
	if selectable.viewport_based_cursor:
		return selectable == viewport_selection
	
	return selectable == world_selection

func _process(_delta: float) -> void:
	if SceneLoader.resource_loader:
		return
	
	if not is_instance_valid(world_selection):
		world_selection = null
	
	if not is_instance_valid(viewport_selection):
		viewport_selection = null
	
	if not world_selection or not world_selection.lock:
		var prev_world_selection = world_selection
		var world_cursor_position = CursorManager.get_position(false)
		
		world_selection = get_top(world_cursor_position, false)
		
		if prev_world_selection != world_selection:
			if prev_world_selection != null:
				emit_signal("cursor_exited", prev_world_selection)
			
			emit_signal("cursor_entered", world_selection)
	
	if not viewport_selection or not viewport_selection.lock:
		var prev_viewport_selection = viewport_selection
		var viewport_cursor_position = CursorManager.get_position(true)
		
		viewport_selection = get_top(viewport_cursor_position, true)
		
		if prev_viewport_selection != viewport_selection:
			if prev_viewport_selection != null:
				emit_signal("cursor_exited", prev_viewport_selection)
			
			emit_signal("cursor_entered", viewport_selection)

func _input(event: InputEvent) -> void:
	if SceneLoader.resource_loader:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if world_selection:
			world_selection.select()
		
		if viewport_selection:
			viewport_selection.select()

func clear() -> void:
	world_selection = null
	viewport_selection = null

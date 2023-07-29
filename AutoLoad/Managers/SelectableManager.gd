extends Node

var disable: bool = false

var viewport_cursor_hovering: PureSelectable = null
var world_cursor_hovering: PureSelectable = null

var viewport_selection: PureSelectable = null
var world_selection: PureSelectable = null

signal cursor_entered(selectable)
signal cursor_exited(selectable)
signal selected(selectable)
signal released(selectable)

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
	var selectable_group = get_tree().get_nodes_in_group("selectable")
	
	var result = null
	
	var max_z_index = -INF
	var max_tree_index = -INF
	
	for i in range(len(selectable_group)):
		var selectable = selectable_group[i]
		
		if selectable.viewport_based_cursor != viewport_based:
			continue
			
		if not selectable.visible:
			continue
		
		var hovering = is_hovering(selectable, mouse_position)
		
		if hovering:
			var z_index = get_absolute_z_index(selectable)
			
			var tree_front = z_index == max_z_index and i > max_tree_index
			var z_front = z_index > max_z_index
			
			if tree_front or z_front:
				max_z_index = z_index
				max_tree_index = i
				
				result = selectable
	
	return result

func is_cursor_hovering(selectable: PureSelectable) -> bool:
	if selectable.viewport_based_cursor:
		return selectable == viewport_cursor_hovering
	
	return selectable == world_cursor_hovering

func is_selected(selectable: PureSelectable) -> bool:
	if selectable.viewport_based_cursor:
		return selectable == viewport_selection
	
	return selectable == world_selection

func _process_hovering(current: PureSelectable, viewport_based: bool) -> PureSelectable:
	if not is_instance_valid(current):
		current = null
	
	if current and current.hover_lock:
		return current
	
	var cursor_position = CursorManager.get_position(viewport_based)
	var next = get_top(cursor_position, viewport_based)
	
	if next != current:
		if current != null:
			emit_signal("cursor_exited", current)

			current.on_cursor_exited()
		
		if next != null:
			emit_signal("cursor_entered", next)

			next.on_cursor_entered()
	
		return next
	
	return current

func _process(_delta: float) -> void:
	world_cursor_hovering = _process_hovering(world_cursor_hovering, false)
	viewport_cursor_hovering = _process_hovering(viewport_cursor_hovering, true)

func _handle_select(current: PureSelectable, hovering: PureSelectable, mouse_pressed: bool) -> PureSelectable:
	if mouse_pressed:
		if hovering:
			hovering.on_selected()
			
			emit_signal("selected", hovering)
			
			return hovering
	elif current:
		current.on_released()

		emit_signal("released", current)

	return null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		viewport_selection = _handle_select(viewport_selection, viewport_cursor_hovering, event.pressed)
		world_selection = _handle_select(world_selection, world_cursor_hovering, event.pressed)

func clear() -> void:
	viewport_cursor_hovering = null
	world_cursor_hovering = null

	viewport_selection = null
	world_selection = null

	disable = false

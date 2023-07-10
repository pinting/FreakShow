extends Node

signal display_changed

var display: InventoryDisplay = null

func set_display(inventory_display: InventoryDisplay) -> void:
	if not inventory_display:
		return
	
	display = inventory_display
	
	Tools.debug("Inventory display changed")
	emit_signal("display_changed")

func clear() -> void:
	if not display:
		Tools.debug("InventoryDisplay not exists, but clear was called")
		return
	
	Tools.destroy_node(display)
	
	display = null

func pick(pickable: Pickable) -> void:
	if not display:
		return
	
	display.inventory.pick(pickable)

class_name Viewable
extends Selectable

# Zoom of the enlarged sprite
export var inner_description_key = ""

# Zoom of the enlarged sprite
export var enlarged_zoom = 0.75

# Z-Index of the enlarged sprite
export var enlarged_z_index = 99

func _ready() -> void:
	assert(is_in_group("viewable"), "Viewable not in group of 'viewable'")

	connect("selected", self, "_on_selected")
	SelectableManager.connect("cursor_entered", self, "set_cursor")
	SelectableManager.connect("cursor_exited", self, "reset_cursor")

func _on_selected():
	emit_signal("cursor_exited")

	var description_key = get("inner_description_key")
	var description_text = Text.find(description_key)
	
	ViewableManager.show(self, enlarged_zoom, description_text)

func set_cursor(target: PureSelectable) -> void:
	if target != self:
		return
	
	CursorManager.set_icon("view", get_instance_id())

func reset_cursor(target: PureSelectable) -> void:
	if target != self:
		return
	
	CursorManager.reset_icon(get_instance_id())

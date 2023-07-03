class_name Viewable
extends Selectable

# Zoom of the enlarged sprite
@export var inner_description_key = ""

# Zoom of the enlarged sprite
@export var enlarged_zoom = 0.75

# Z-Index of the enlarged sprite
@export var enlarged_z_index = 99

func _ready() -> void:
	assert(is_in_group("viewable"), "Viewable not in group of 'viewable'")

	connect("selected", Callable(self, "_on_selected"))
	SelectableManager.connect("cursor_entered", Callable(self, "set_cursor"))
	SelectableManager.connect("cursor_exited", Callable(self, "reset_cursor"))

func _on_selected():
	emit_signal("cursor_exited")

	var inner_description_key_value = get("inner_description_key")
	var inner_description_text = Text.find(inner_description_key_value)
	
	ViewableManager.appear(self, enlarged_zoom, inner_description_text)

func set_cursor(target: PureSelectable) -> void:
	if target != self:
		return
	
	CursorManager.set_icon("view", get_instance_id())

func reset_cursor(target: PureSelectable) -> void:
	if target != self:
		return
	
	CursorManager.reset_icon(get_instance_id())

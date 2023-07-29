class_name Viewable
extends Selectable

# Zoom of the enlarged sprite
@export var inner_description_key = ""

# Zoom of the enlarged sprite
@export var enlarged_zoom = 0.75

# Z-Index of the enlarged sprite
@export var enlarged_z_index = 99

func _ready() -> void:
	super()
	
	assert(is_in_group("viewable"), "Viewable not in group of 'viewable'")

func on_selected():
	super.on_selected()

	on_cursor_exited()

	var inner_description_key_value = get("inner_description_key")
	var inner_description_text = Text.find(inner_description_key_value)
	
	ViewableManager.appear(self, enlarged_zoom, inner_description_text)

func on_cursor_entered() -> void:
	super.on_cursor_entered()
	
	CursorManager.set_icon("view", get_instance_id())

func on_cursor_exited() -> void:
	super.on_cursor_exited()
	
	CursorManager.reset_icon(get_instance_id())

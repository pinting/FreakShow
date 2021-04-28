class_name Viewable
extends Selectable

# Zoom of the enlarged sprite
export var enlarged_zoom = 0.75

# Z-Index of the enlarged sprite
export var enlarged_z_index = 99

func _ready() -> void:
	connect("selected", self, "_on_selected")
	connect("cursor_inside", self, "_set_cursor")
	connect("cursor_outside", self, "_reset_cursor")

func _on_selected():
	var camera = Game.current_camera
	var display = Game.viewable_display
	
	if not camera or not display:
		return
	
	emit_signal("cursor_outside")

	var description_key = get("description")
	var description_text = ""

	if description_key and len(description_key):
		description_text = Text.find(description_key)
	
	display.show(self, enlarged_zoom, description_text)

func _set_cursor():
	Cursor.set_icon("view", get_instance_id())

func _reset_cursor():
	Cursor.reset_icon(get_instance_id())

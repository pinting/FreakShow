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
	
	if display.current.visible:
		return
	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	var texture_size = texture.get_size()
	var ratio = project_size / texture_size
	var child_scale = min(ratio.x, ratio.y) * enlarged_zoom
	
	emit_signal("cursor_outside")
	display.add(texture, tr(get("description")), child_scale)

func _set_cursor():
	Cursor.set_icon("view", get_instance_id())

func _reset_cursor():
	Cursor.reset_icon(get_instance_id())

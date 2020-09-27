extends "res://Objects/Selectable/Selectable.gd"

# Zoom of the enlarged sprite
export var enlarged_zoom = 0.75

# Z-Index of the enlarged sprite
export var enlarged_z_index = 99

func _ready():
	connect("selected", self, "_on_selected")

func _on_selected():
	var camera = Global.current_camera
	var display = Global.viewable_display
	
	if not camera or not display:
		return
	
	if display.current.visible:
		return
	
	var players = Global.players
	
	for player in players:
		player.freeze()
	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	var texture_size = texture.get_size()
	var ratio = project_size / texture_size
	var child_scale = min(ratio.x, ratio.y) * enlarged_zoom
	
	display.add(texture, tr(get("description")), child_scale)

extends "res://Objects/Selectable/Selectable.gd"

# Zoom of the enlarged sprite
export var enlarged_zoom = 0.8

# Z-Index of the enlarged sprite
export var enlarged_z_index = 99

const viewable_child = preload("res://Objects/Viewable/ViewableChild.gd")

var enlarged_sprite: Sprite

func _ready():
	connect("selected", self, "_on_selected")

func _on_selected():
	if enlarged_sprite:
		return
	
	var camera = Global.current_camera
	var container = Global.viewable_display
	
	if not camera or not container:
		return
	
	var player = Global.player
	
	if player:
		player.freeze()
	
	var sprite = Sprite.new()
	var viewport_size = get_viewport().size
	var texture_size = texture.get_size()
	var real_scale = viewport_size / texture_size
	var min_scale = min(real_scale.x, real_scale.y)
	var final_scale = min_scale * enlarged_zoom
	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	sprite.texture = texture.duplicate()
	sprite.scale = Vector2(final_scale, final_scale)
	sprite.position = Vector2(project_width / 2, project_height / 2)
	sprite.centered = true
	
	sprite.set_script(viewable_child)
	container.add_child(sprite)
	
	Global.subtitle.describe(sprite.get_instance_id(), tr(get("description")), true)
	
	enlarged_sprite = sprite

func _process(delta):
	if enlarged_sprite and not enlarged_sprite.visible:
		enlarged_sprite = null

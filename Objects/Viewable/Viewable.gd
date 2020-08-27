extends "res://Objects/Selectable/Selectable.gd"

# Zoom of the enlarged sprite
export var enlarged_zoom = 0.4

# Z-Index of the enlarged sprite
export var enlarged_z_index = 99

const selectable = preload("res://Objects/Selectable/Selectable.gd")

var enlarged_sprite: Sprite

func _ready():
	connect("selected", self, "_on_selected")

func _process(_delta: float):
	if not enlarged_sprite:
		return
	
	var camera = Global.current_camera
	
	if not camera:
		return
	
	enlarged_sprite.position = camera.get_camera_screen_center()

func _on_selected():
	if enlarged_sprite:
		return
	
	var camera = Global.current_camera
	
	if not camera:
		return
	
	var player = Global.player
	
	if player:
		player.freeze()
	
	var sprite = Sprite.new()
	var screen_size = OS.get_screen_size() * camera.zoom
	var texture_size = texture.get_size()
	var real_scale = (screen_size / texture_size) * enlarged_zoom
	var min_scale = min(real_scale.x, real_scale.y)
	
	sprite.texture = texture.duplicate()
	sprite.scale = Vector2(min_scale, min_scale)
	sprite.centered = true
	sprite.position = camera.get_camera_screen_center()
	sprite.rotation_degrees = 0
	sprite.z_as_relative = false
	sprite.z_index = enlarged_z_index
	sprite.light_mask = pow(2, 19)
	
	sprite.add_to_group("selectable")
	sprite.set_script(selectable)
	sprite.set("description", get("description"))
	sprite.connect("selected", self, "_on_enlarged_sprite_selected")
	
	get_viewport().add_child(sprite)
	
	enlarged_sprite = sprite

func _on_enlarged_sprite_selected():
	if not enlarged_sprite:
		return
	
	var player = Global.player
	
	if player:
		player.unfreeze()
	
	enlarged_sprite.remove_description()
	get_viewport().remove_child(enlarged_sprite)
	
	enlarged_sprite = null

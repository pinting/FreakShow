extends "res://Objects/Selectable/Selectable.gd"

export var ZOOM = 0.4

const selectable = preload("res://Objects/Selectable/Selectable.gd")

var enlarged_sprite

func _ready():
	connect("selected", self, "_on_selected")

func _process(_delta):
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
		player.freeze = true
	
	var sprite = Sprite.new()
	var screen_size = OS.get_screen_size() * camera.zoom
	var texture_size = texture.get_size()
	var real_scale = (screen_size / texture_size) * ZOOM
	var min_scale = min(real_scale.x, real_scale.y)
	
	sprite.texture = texture.duplicate()
	sprite.scale = Vector2(min_scale, min_scale)
	sprite.centered = true
	sprite.position = camera.get_camera_screen_center()
	sprite.rotation_degrees = 0
	sprite.z_as_relative = false
	sprite.z_index = 99
	sprite.light_mask = pow(2, 19)
	
	sprite.add_to_group("selectable")
	sprite.set_script(selectable)
	sprite.set("DESCRIPTION", get("DESCRIPTION"))
	sprite.connect("selected", self, "_on_enlarged_sprite_selected")
	
	get_viewport().add_child(sprite)
	
	enlarged_sprite = sprite

func _on_enlarged_sprite_selected():
	if not enlarged_sprite:
		return
	
	var player = Global.player
	
	if player:
		player.freeze = false
	
	enlarged_sprite.remove_description()
	get_viewport().remove_child(enlarged_sprite)
	
	enlarged_sprite = null

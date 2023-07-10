extends Inventory
class_name InventoryWheel

# Radius of the inventory wheel
@export var wheel_radius = 650.0

# Inventory wheel item radius
@export var item_radius = 60.0

# Item scale inside the wheel
@export var item_scale = Vector2.ONE

# Background
@onready var background = $Background

# Container of the items
@onready var container = $Container

# Light 
@onready var light = $Light

# Refresh inventory duration
const refresh_inventory_duration = 1.0

# Rotation per seconds in radian
const rotation_deg_per_s = 10

func _ready() -> void:
	var r = wheel_radius
	
	background.size = Vector2(2 * r, 2 * r)
	background.position = Vector2(-r, -r)
	
	var w = item_radius / r
	
	background.material.set_shader_parameter("width", w)
	
	var light_size = light.texture.get_size() 
	
	light.scale = background.size / light_size

func _process(delta: float) -> void:
	_process_rotate(delta)

func _process_rotate(delta: float) -> void:
	container.rotation_degrees += delta * rotation_deg_per_s
	
	for item in container.get_children():
		item.rotation_degrees = -container.rotation_degrees

func pick(pickable: Pickable) -> void:
	var item: PureSelectable = pickable.selectable.create_clone()
	
	item.scale = Vector2.ONE / scale
	item.light_mask = light.light_mask
	
	container.add_child(item)
	
	item.global_position = pickable.global_position
	
	pickable.disable()
	pickable.disappear()
	
	refresh_inventory_layout()

func refresh_inventory_layout() -> void:
	var items = container.get_children()
	var count = len(items)
	
	for i in range(count):
		var item = items[i]
		var direction = Vector2.from_angle(float(i) / float(count) * PI * 2.0)
		var offset = direction * (wheel_radius - item_radius)

		var texture_size = item.texture.get_size()
		var length = texture_size.length()
		var fit_scale = 2 * item_radius / length
		var new_scale = Vector2(fit_scale * item_scale.x, fit_scale * item_scale.y)

		var tween = get_tree().create_tween()
		
		tween.parallel().tween_property(item, "position", offset, refresh_inventory_duration)
		tween.parallel().tween_property(item, "scale", new_scale, refresh_inventory_duration)

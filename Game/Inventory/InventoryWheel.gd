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
	pickable.enable_float()
	pickable.drop()
	
	var item = RemoteTransform2D.new()
	var selectable: PureSelectable = pickable.selectable
	
	selectable.item_selected = Callable(self, "item_selected").bind(pickable, item)
	selectable.connect("selected", selectable.item_selected)
	
	container.add_child(item)
	
	item.global_position = pickable.global_position
	item.global_scale = pickable.global_scale
	item.global_rotation = pickable.global_rotation
	item.use_global_coordinates = true
	item.remote_path = pickable.get_path()
	
	refresh_inventory_layout()

func item_selected(pickable: Pickable, item: RemoteTransform2D) -> void:
	var selectable: PureSelectable = pickable.selectable
	
	selectable.disconnect("selected", selectable.item_selected)
	
	selectable.item_released = Callable(self, "item_released").bind(pickable)
	
	selectable.connect("released", selectable.item_released)
	
	item.get_parent().remove_child(item)
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(pickable, "scale", Vector2.ONE, refresh_inventory_duration)
	
	pickable.disable_float()

func item_released(pickable: Pickable) -> void:
	var selectable: PureSelectable = pickable.selectable
	
	selectable.disconnect("released", selectable.item_released)

func refresh_inventory_layout() -> void:
	var items = container.get_children()
	var count = len(items)
	
	for i in range(count):
		var item = items[i]
		
		var direction = Vector2.from_angle(float(i) / float(count) * PI * 2.0)
		var offset = direction * (wheel_radius - item_radius)

		var pickable = get_node(item.remote_path)
		var selectable = pickable.selectable
		
		var texture_size = selectable.texture.get_size()
		var length = texture_size.length()
		var fit_scale = 2 * item_radius / length
		var new_scale = Vector2(fit_scale * item_scale.x, fit_scale * item_scale.y)

		var tween = get_tree().create_tween()
		
		tween.parallel().tween_property(item, "position", offset, refresh_inventory_duration)
		tween.parallel().tween_property(item, "scale", new_scale, refresh_inventory_duration)

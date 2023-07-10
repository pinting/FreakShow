extends Node2D
class_name InventoryDisplay

@export var margin: Vector2 = Vector2(100.0, 100.0)

@onready var container = $Container
@onready var inventory: Inventory = $Container/Inventory

func _ready() -> void:
	InventoryManager.set_display(self)

func _process(_delta: float) -> void:
	var camera = CameraManager.current

	if not camera:
		return
	
	var project_size = VirtualInput.get_project_size()
	var camera_center = camera.get_screen_center_position()
	var actual_size = project_size / camera.zoom

	var top_left = camera_center - actual_size / 2 + margin / 2
	
	container.global_position = top_left

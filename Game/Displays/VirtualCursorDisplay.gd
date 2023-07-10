class_name VirtualCursorDisplay
extends Node2D

# Disable VirtualCursorDisplay, do not register and destroy instantly
@export var disable: bool = false

# Margin of the cursor area (positive pair of numbers)
@export var margin: Vector2 = Vector2(100.0, 100.0)

# Scale up the cursor by this value
@export var cursor_scale: float = 0.66

@onready var cursor: Sprite2D = $Cursor

func _ready():
	assert(margin.x > 0 and margin.y > 0, "Negative margin")

	if disable:
		Tools.destroy_node(self, true)
	else:
		CursorManager.set_display(self)

func is_hidden() -> bool:
	return not cursor.visible

func appear(duration: float = 0.5) -> void:
	cursor.visible = true
	
	await Animator.run(cursor, "modulate:a",
		cursor.modulate.a, 1.0, duration)

func disappear(duration: float = 0.5) -> void:
	await Animator.run(cursor, "modulate:a",
		cursor.modulate.a, 0.0, duration)
	
	if cursor.modulate.a == 0.0:
		cursor.visible = false

func move_to_center() -> void:
	var camera = CameraManager.current
	
	assert(camera, "No GameCamera is registered")

	cursor.global_position = camera.get_screen_center_position()

func correct_position() -> void:
	var camera = CameraManager.current

	if not camera:
		return
	
	var project_size = VirtualInput.get_project_size()
	var camera_center = camera.get_screen_center_position()
	var actual_size = project_size / camera.zoom

	var top_left = camera_center - actual_size / 2 + margin / 2
	var bottom_right = camera_center + actual_size / 2 - margin / 2

	if cursor.global_position.x < top_left.x:
		cursor.global_position.x = top_left.x
	elif cursor.global_position.x > bottom_right.x:
		cursor.global_position.x = bottom_right.x
	
	if cursor.global_position.y < top_left.y:
		cursor.global_position.y = top_left.y
	elif cursor.global_position.y > bottom_right.y:
		cursor.global_position.y = bottom_right.y
	
	cursor.scale = (Vector2.ONE / camera.zoom) * cursor_scale

func get_viewport_position() -> Vector2:
	var camera = CameraManager.current

	assert(camera, "No GameCamera is registered")
	
	var project_size = VirtualInput.get_project_size()
	var world_position = cursor.global_position
	var camera_center = camera.get_screen_center_position()
	var diff = world_position - camera_center

	return (project_size / 2) + (diff * camera.zoom)

func _process(_delta: float) -> void:
	correct_position()

func reset(from: Vector2, to: Vector2) -> void:
	var diff = from - cursor.global_position
	
	correct_position()
	
	cursor.global_position = to - diff

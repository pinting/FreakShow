extends BaseScene

onready var rack_area = $RackArea
onready var rack_area_shape = $RackArea/CollisionShape2D
onready var player = $Player

func _ready() -> void:
	pass

func _process_player(_delta: float) -> void:
	var extents = rack_area_shape.shape.extents
	
	var half = Vector2(extents.x, extents.y)
	var size = 2 * half
	var tl = rack_area.global_position - half
	var bl = rack_area.global_position + half
	
	if player.global_position >= tl and player.global_position <= bl:
		var relative = tl - player.global_position
		var scale = relative / size
		var voltage = scale.abs() * 10.0
		
		RackManager.send_data(0, voltage.x)
		RackManager.send_data(1, voltage.y)

func _process_cursor(_delta: float) -> void:
	var cursor = CursorManager.get_position(true)
	var project_size = VirtualInput.get_project_size()
	var scaled = cursor / project_size
	var voltage = scaled * 10.0
	
	RackManager.send_data(2, voltage.x)
	RackManager.send_data(3, voltage.y)

func _process_speed(delta: float) -> void:
	var speed = VirtualInput.move_speed.length() * delta
	var voltage = speed * 10.0

	RackManager.send_data(4, voltage)

func _process(delta: float) -> void:
	_process_player(delta)
	_process_cursor(delta)
	_process_speed(delta)

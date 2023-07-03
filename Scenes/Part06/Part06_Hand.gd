extends SlidingNode

@onready var detect_area = $Sprite2D/DetectArea
@onready var body = $Sprite2D/Body

signal player_on_palm

var player_standing_on_palm: Player = null
var in_palm_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	
	Tools.set_shapes_disabled(body, true)
	Tools.set_shapes_disabled(detect_area, true)
	
	detect_area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(player: Node) -> void:
	if not player.is_in_group("player") and not player_standing_on_palm:
		return
	
	player.freeze(true)
	
	await Tools.wait(1.0)
	
	player_standing_on_palm = player
	in_palm_position = player.global_position - detect_area.global_position
	
	emit_signal("player_on_palm", player)
	close()

func _process(delta: float) -> void:
	super._process(delta)
	
	if player_standing_on_palm:
		player_standing_on_palm.global_position = detect_area.global_position + in_palm_position

func open() -> void:
	super.open()
	
	Tools.set_shapes_disabled(body, false)
	Tools.set_shapes_disabled(detect_area, false)

func close() -> void:
	super.close()
	
	if not player_standing_on_palm:
		Tools.set_shapes_disabled(body, true)
		Tools.set_shapes_disabled(detect_area, true)

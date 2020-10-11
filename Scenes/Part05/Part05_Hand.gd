extends "res://Objects/MechanicDoor.gd"

onready var detect_area = $Sprite/DetectArea
onready var detect_area_shape = $Sprite/DetectArea/CollisionShape
onready var body_shape = $Sprite/Body/CollisionShape

signal player_on_palm

var player_standing_on_palm: Player = null
var in_palm_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_shape.disabled = true
	detect_area_shape.disabled = true
	
	detect_area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(player: Node) -> void:
	if not player.is_in_group("player") and not player_standing_on_palm:
		return
	
	player_standing_on_palm = player
	in_palm_position = player.global_position - detect_area_shape.global_position
	
	emit_signal("player_on_palm", player)
	player.freeze()
	close()

func _process(delta: float) -> void:
	._process(delta)
	
	if player_standing_on_palm:
		player_standing_on_palm.global_position = detect_area_shape.global_position + in_palm_position

func open() -> void:
	.open()
	
	body_shape.disabled = false
	detect_area_shape.disabled = false

func close() -> void:
	.close()
	
	if not player_standing_on_palm:
		body_shape.disabled = true
		detect_area_shape.disabled = true

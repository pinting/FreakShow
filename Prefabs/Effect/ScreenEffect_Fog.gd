extends CanvasLayer

export var speed_div: Vector2 = Vector2(6666.0, 6666.0)
export var color: Color = Color(1.0, 1.0, 0.6, 0.3)

onready var canvas = $Canvas

func _ready() -> void:
	canvas.visible = true
	canvas.material.set_shader_param("color", color)

func _process(_delta: float) -> void:
	if len(Game.players) > 0:
		var master_player = Game.players[0]
		var offset = master_player.global_position / speed_div
		
		canvas.material.set_shader_param("offset", offset)

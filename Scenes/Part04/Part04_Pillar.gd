extends Sprite

export var y_move_diff: float = 100.0
export var time_scale: float = 5.0

onready var hit_area = $HitArea

var current_second = 0.0
var base_position = Vector2.ZERO

func _ready():
	base_position = global_position
	
	hit_area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	body.kill()

func _process(delta):
	current_second += delta
	position.y += sin(base_position.x + time_scale * current_second) * y_move_diff * delta

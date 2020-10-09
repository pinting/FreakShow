extends Sprite

export var y_move_diff: float = 100.0
export var time_scale: float = 5.0

onready var hit_area = $HitArea

var current_second = 0.0
var base_position = Vector2.ZERO

func _ready():
	base_position = global_position
	
	hit_area.connect("body_entered", self, "_on_player_enter")

func _on_player_enter(player: Node) -> void:
	if not player.is_in_group("player"):
		return
	
	player.kill()

func _process(delta):
	current_second += delta
	position.y += sin(base_position.x + time_scale * current_second) * y_move_diff * delta

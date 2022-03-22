extends Sprite

export var movement_scale: Vector2 = Vector2(0, 10.0);

var time: float = 0.0;
var base_position: Vector2;

func _ready() -> void:
	base_position = position;


func _process(delta: float) -> void:
	time += delta;
	position += base_position +  movement_scale * sin(time);

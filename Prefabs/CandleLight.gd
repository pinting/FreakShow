extends Light2D

# Min energy level
export var min_energy: float = 0.95

# Max energy level
export var max_energy: float = 1.0

# Speed of the effect
export var speed: float = 0.5

const p = Vector2(100.0, 100.0)

var current_second: float = 0.0
var base_energy: float

func _ready() -> void:
	base_energy = energy

func _process(delta: float) -> void:
	current_second += speed * delta
	
	var x = p.x * cos(current_second) - p.y * sin(current_second)
	var y = p.y * cos(current_second) + p.y * sin(current_second)
	
	var n = Tools.noise.get_noise_2d(x, y)
	
	energy = min(max_energy, max(min_energy, energy + n))

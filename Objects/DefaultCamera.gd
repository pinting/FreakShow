extends Camera2D
class_name DefaultCamera 

# Maximum shake in pixels.
export var max_offset = Vector2(100, 75)

# Maximum rotation in radians
export var max_roll = 0.1

var noise: OpenSimplexNoise = OpenSimplexNoise.new()
var shake: float = 0.0
var offset_y = 0

func _ready():
	Global.current_camera = self
	
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func _process(delta):
	if not shake:
		return
	
	offset_y += delta
	
	rotation = max_roll * shake * noise.get_noise_2d(noise.seed, offset_y)
	offset.x = max_offset.x * shake * noise.get_noise_2d(noise.seed * 2, offset_y)
	offset.y = max_offset.y * shake * noise.get_noise_2d(noise.seed * 3, offset_y)

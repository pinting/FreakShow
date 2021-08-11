extends CanvasModulate

func _ready():
	color *= Config.gamma
	color.r = max(0.0, min(1.0, color.r))
	color.g = max(0.0, min(1.0, color.g))
	color.b = max(0.0, min(1.0, color.b))

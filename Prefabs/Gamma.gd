extends CanvasModulate

func _ready():
	color *= Config.gamma
	
	color.clamp()

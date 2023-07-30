extends StaticBody2D

@onready var red_figure = $StopLamp/RedFigure

var wait: float = 0.0
var disabled: bool = true

func _ready() -> void:
	if disabled:
		red_figure.visible = false

func _process(delta: float) -> void:
	if disabled:
		return
	
	wait -= delta
	
	if wait <= 0.0:
		red_figure.visible = not red_figure.visible
		wait = Tools.random_float(0.25, 1.0)

func disable() -> void:
	red_figure.visible = false
	disabled = true

func enable() -> void:
	disabled = false

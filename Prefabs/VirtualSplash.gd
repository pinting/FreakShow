extends CanvasLayer

# Hide the splash after this amount of seconds
@export var hide_after: float = 1.0

# Duration of the hide animation
@export var hide_duration: float = 1.0

@onready var container = $Container
@onready var color_rect = $Container/ColorRect

var complete: bool = false

func _ready():
	if SceneLoader.count > 0:
		done()
	else:
		play()

func play():
	color_rect.color = ProjectSettings.get_setting("application/boot_splash/bg_color")
	container.visible = true
	
	await Tools.wait(hide_after)
	await Animator.run(container, "modulate:a", 1.0, 0.0, hide_duration)
	
	done()

func done():
	complete = true

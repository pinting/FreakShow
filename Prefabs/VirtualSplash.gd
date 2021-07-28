extends CanvasLayer

# Hide the splash after this amount of seconds
export var hide_after: float = 1.0

# Duration of the hide animation
export var hide_duration: float = 1.0

onready var tween = $Tween
onready var container = $Container
onready var color_rect = $Container/ColorRect

var complete: bool = false

func _ready():
	if SceneLoader.scene_count > 0:
		done()
	else:
		play()

func play():
	color_rect.color = ProjectSettings.get_setting("application/boot_splash/bg_color")
	container.visible = true
	
	yield(Tools.timer(hide_after), "timeout")

	tween.interpolate_property(
		container,
		"modulate:a",
		1.0,
		0.0,
		hide_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	done()

func done():
	complete = true

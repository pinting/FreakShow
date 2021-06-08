extends BaseScene

onready var tween = $Tween
onready var ghost = $Environment/Ghost

func _ready():
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started() -> void:
	print("tween start")
	tween.interpolate_property(
		ghost,
		"position:x",
		3700.0,
		-260,
		30.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

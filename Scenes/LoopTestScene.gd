extends BaseScene

onready var player = $Player
onready var camera = $GameCamera
onready var ball = $Environment/Ball
onready var loop = $Environment/Loop

func _ready():
	connect("scene_started", self, "_on_scene_started")

	loop.player = player
	loop.camera = camera
	
	loop.register_pickable(ball)

func _on_scene_started() -> void:
	black_screen.fade_out()

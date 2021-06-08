extends BaseScene

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var ball: Pickable = $Environment/Ball
onready var loop: Loop = $Environment/Loop

func _ready():
	loop.register_pickable(ball)
	
	VirtualCursorManager.hide()
	
	VirtualInput.test_mode = true
	VirtualInput.test_keys = ["move_right"]
	
	disable_auto_restart = true

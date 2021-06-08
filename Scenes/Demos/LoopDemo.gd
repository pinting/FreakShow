extends BaseScene

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var ball: Pickable = $Environment/Ball
onready var loop: Loop = $Environment/Loop
onready var hoop: Node2D = $Environment/Hoop

func _ready():
	loop.register_pickable(ball)
	loop.register_pickable(hoop)

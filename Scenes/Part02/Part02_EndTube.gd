extends Node2D

export var speed = 200
export var length = 160

onready var meat = $Meat
onready var tooth_left = $Meat/Tooth00
onready var tooth_right = $Meat/Tooth01

var open_mouth: bool = false
var between: float = 0

func _ready():
	if Global.LOW_PERFORMANCE:
		meat.material = null
	
	between = (tooth_left.position.x + tooth_right.position.x) / 2

func _process(delta):
	if not open_mouth:
		return
	
	var diff = speed * delta
	
	tooth_left.position.x = max(tooth_left.position.x - diff, between - length)
	tooth_right.position.x = min(tooth_right.position.x + diff, between + length)

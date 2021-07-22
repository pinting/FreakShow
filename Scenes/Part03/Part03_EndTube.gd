extends Node2D

export var speed: float = 200.0
export var length: float = 160.0

onready var meat = $Meat
onready var tooth_left = $Meat/Tooth00
onready var tooth_right = $Meat/Tooth01

var open_mouth: bool = false
var between: float = 0.0

func _ready() -> void:
	between = (tooth_left.position.x + tooth_right.position.x) / 2

func _process(delta: float) -> void:
	if not open_mouth:
		return
	
	var diff = speed * delta
	
	tooth_left.position.x = max(tooth_left.position.x - diff, between - length)
	tooth_right.position.x = min(tooth_right.position.x + diff, between + length)

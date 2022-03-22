extends Node2D

export var label_text: String = ""

onready var label: Label = $Viewport/Label
onready var particle: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	label.text = label_text

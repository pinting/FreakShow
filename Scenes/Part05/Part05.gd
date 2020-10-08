extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Credits.tscn"

onready var player = $Player

onready var door = $Environment/Bottom/Door

func _ready() -> void:
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started() -> void:
	yield(timer(2.0), "timeout")
	#door.open()

extends Node2D

onready var totem_00 = $Island00/Totem
onready var totem_01 = $Island01/Totem
onready var totem_02 = $Island02/Totem

func _ready():
	totem_00.connect("selected", self, "_on_totem_selected", [])
	totem_01.connect("selected", self, "_on_totem_selected", [])
	totem_02.connect("selected", self, "_on_totem_selected", [])

func _on_totem_selected() -> void:
	pass

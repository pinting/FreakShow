extends Node2D

@onready var totem_00 = $Island00/Totem
@onready var totem_01 = $Island01/Totem
@onready var totem_02 = $Island02/Totem

func _ready():
	totem_00.connect("selected", Callable(self, "_on_totem_selected").bind())
	totem_01.connect("selected", Callable(self, "_on_totem_selected").bind())
	totem_02.connect("selected", Callable(self, "_on_totem_selected").bind())

func _on_totem_selected() -> void:
	pass

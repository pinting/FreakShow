extends CanvasLayer

onready var cursor = $Cursor

func _ready() -> void:
	Global.virtual_cursor = self

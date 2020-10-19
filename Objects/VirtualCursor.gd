extends CanvasLayer

onready var cursor = $Cursor

func _ready() -> void:
	VirtualInput.virtual_cursor = self

extends CanvasLayer

onready var cursor = $Cursor

func _ready():
	Global.virtual_cursor = self

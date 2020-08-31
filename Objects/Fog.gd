extends CanvasLayer

onready var fake_fog = $FakeFog
onready var dynamic_fog = $DynamicFog

func _ready():
	if Global.LOW_PERFORMANCE:
		remove_child(dynamic_fog)
		fake_fog.visible = true
	else:
		remove_child(fake_fog)
		dynamic_fog.visible = true

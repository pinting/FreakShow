extends Node2D

# Process user input after this amount of seconds
export var REGISTER_INPUT_AFTER = 0.25

var current_second = 0.0

func _ready():
	pass

func _process(delta):
	current_second += delta

func _input(event):
	if not (event is InputEventMouseButton) or not event.button_index == BUTTON_LEFT or not event.pressed:
		return
	
	if current_second < REGISTER_INPUT_AFTER:
		return
	
	var player = Global.player
	
	if not player:
		return
	
	if player:
		player.unfreeze()
	
	visible = false
	
	get_parent().remove_child(self)
	Global.subtitle.describe_remove(self.get_instance_id())

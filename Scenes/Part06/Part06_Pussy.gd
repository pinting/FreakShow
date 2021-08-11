extends Selectable

onready var inside = $Inside
onready var filled = $Filled
onready var light = $Light

signal dildo_inside

func _ready() -> void:
	inside.connect("body_entered", self, "_on_body_entered")
	
	visible = false
	filled.visible = false

func _on_body_entered(body: Node):
	if not body.is_in_group("dildo"):
		return
	
	Tools.set_shapes_disabled(inside, true);
	Tools.destroy_node(body)
	
	filled.visible = true
	
	emit_signal("dildo_inside")

func enable():
	Tools.set_shapes_disabled(inside, false);
	
	visible = true
	filled.visible = false

func disable():
	Tools.set_shapes_disabled(inside, true);
	
	visible = false
	filled.visible = false

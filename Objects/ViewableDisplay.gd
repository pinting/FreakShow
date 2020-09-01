extends CanvasLayer

# Process user input after this amount of seconds
export var REGISTER_INPUT_AFTER = 0.25

onready var current: Sprite = $Current

var visible_since: float = 0.0

func _ready():
	Global.viewable_display = self

func add(texture: Texture, description: String, child_scale: float = 1.0):	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	visible_since = 0.0
	
	current.texture = texture.duplicate()
	current.scale = Vector2(child_scale, child_scale)
	current.position = Vector2(project_width / 2, project_height / 2)
	current.centered = true
	current.visible = true
	
	Global.subtitle.describe(current.get_instance_id(), description, true)

func _process(delta):
	if current.visible:
		visible_since += delta

func _input(event):
	if not current.visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	
	if visible_since < REGISTER_INPUT_AFTER:
		return
	
	var player = Global.player
	
	if not player:
		return
	
	if player:
		player.unfreeze()
	
	current.visible = false
	
	Global.subtitle.describe_remove(current.get_instance_id())

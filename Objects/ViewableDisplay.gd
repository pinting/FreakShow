extends CanvasLayer

# Process user input after this amount of seconds
export var INPUT_DELAY = 0.2

onready var current: Sprite = $Current

var visible_since: float = 0.0
var queue_remove: bool = false
var remove_after: float = 0.0

func _ready() -> void:
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
	
	Global.disable_selectable = true
	Global.subtitle.describe(current.get_instance_id(), description, true)

func _process(delta: float) -> void:
	if current.visible:
		visible_since += delta
	
	if queue_remove:
		remove_after += delta
		
		if remove_after > INPUT_DELAY:
			var players = Global.players
			
			for player in players:
				if player:
					player.unfreeze()
			
			current.visible = false
			
			Global.disable_selectable = false
			Global.subtitle.describe_remove(current.get_instance_id())
	
			queue_remove = false
			remove_after = 0.0

func _input(event: InputEvent) -> void:
	if not current.visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	
	if visible_since > INPUT_DELAY:
		queue_remove = true

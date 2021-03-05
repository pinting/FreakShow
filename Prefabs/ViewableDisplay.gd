class_name ViewableDisplay
extends CanvasLayer

# Process user input after this amount of seconds, so the user cannot click through stuff
export var INPUT_DELAY = 0.1

onready var current: Sprite = $Current

var visible_since: float = 0.0
var queue_remove: bool = false
var remove_after: float = 0.0

func _ready() -> void:
	Game.viewable_display = self
	current.visible = false

func add(texture: Texture, description: String, child_scale: float = 1.0):	
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	
	visible_since = 0.0
	
	current.texture = texture.duplicate()
	current.scale = Vector2(child_scale, child_scale)
	current.position = Vector2(project_width / 2, project_height / 2)
	current.centered = true
	current.visible = true
	
	Game.disable_selectable = true
	SubtitleManager.describe_reset(-1, true)
	SubtitleManager.describe(current.get_instance_id(), description, true)

	Cursor.hide()
	
	var players = Game.players
	
	for player in players:
		player.freeze(true)

func _process(delta: float) -> void:
	if current.visible:
		visible_since += delta
	
	if not queue_remove:
		return
	
	remove_after += delta
	
	if remove_after > INPUT_DELAY:
		var players = Game.players
		
		for player in players:
			if player:
				player.unfreeze()
		
		current.visible = false

		Game.disable_selectable = false
		SubtitleManager.describe_reset(current.get_instance_id(), true)
		
		Cursor.show()

		queue_remove = false
		remove_after = 0.0

func _input(event: InputEvent) -> void:
	if not current.visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	
	remove_after = 0.0
	
	if visible_since > INPUT_DELAY:
		queue_remove = true

func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()

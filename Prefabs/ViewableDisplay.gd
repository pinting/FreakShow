class_name ViewableDisplay
extends CanvasLayer

# Process user input after this amount of seconds, so the user cannot click through stuff
export var INPUT_DELAY = 0.1

onready var container: Node2D = $Container
onready var background_light: Sprite = $BackgroundLight

var queue_remove: bool = false
var visible_since: float = 0.0
var remove_after: float = 0.0

func _ready() -> void:
	Game.viewable_display = self
	
	container.visible = false
	background_light.visible = false

func show(viewable: Viewable, enlarged_zoom: float, description_text: String):
	# Calculate the right child scale and center position
	var project_width = ProjectSettings.get_setting("display/window/size/width")
	var project_height = ProjectSettings.get_setting("display/window/size/height")
	var project_size = Vector2(project_width, project_height)
	
	var texture_size = viewable.texture.get_size()

	if viewable.region_enabled:
		texture_size = viewable.region_rect.size

	var ratio = project_size / texture_size
	var child_scale = min(ratio.x, ratio.y) * enlarged_zoom
	var center_position = Vector2(project_width / 2, project_height / 2)
	
	# Create a duplicate from the incoming Viewable and set the correct parameters
	var dupe = viewable.duplicate()

	if viewable.material:
		dupe.material = viewable.material.duplicate()
	
	dupe.scale = Vector2(child_scale, child_scale)
	dupe.rotation_degrees = 0.0
	dupe.position = Vector2.ZERO
	dupe.z_index = 0

	# Add the duplicate to the container
	container.add_child(dupe)

	# Hide cursor
	Cursor.hide()

	# Force reset the description text and set it to the new value
	SubtitleManager.reset_describe(-1, true)
	SubtitleManager.set_describe(container.get_instance_id(), description_text, true)
	
	# Disable every selectable
	Game.disable_selectable = true
	
	# Freeze players
	for player in Game.players:
		player.freeze(true)
	
	# Show background light
	background_light.position = center_position
	background_light.visible = true

	# Show container
	container.position = center_position
	container.visible = true

	# Reset the counter to zero
	visible_since = 0.0

func _process(delta: float) -> void:
	if container.visible:
		visible_since += delta
	
	# Wait for the removal trigger
	if not queue_remove:
		return
	
	remove_after -= delta
	
	# Wait for the removal timer
	if remove_after > 0:
		return
	
	# Unfreeze players
	for player in Game.players:
		player.unfreeze()
	
	# Hide container and background light
	container.visible = false
	background_light.visible = false
	
	# Remove children of the container
	Tools.remove_childs(container)

	# Reset describe text
	SubtitleManager.reset_describe(container.get_instance_id(), true)

	# Show cursor
	Cursor.show()

	# Enable selectables
	Game.disable_selectable = false

	# Reset removal trigger
	queue_remove = false

func _input(event: InputEvent) -> void:
	if not container.visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	
	if visible_since < INPUT_DELAY:
		return
	
	# Queue the removal
	remove_after = INPUT_DELAY
	queue_remove = true

func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()

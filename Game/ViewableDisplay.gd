class_name ViewableDisplay
extends Node

# Selectable script
export (Script) var selectable_script = preload("res://Prefabs/Selectable/PureSelectable.gd")

# Display material
export (ShaderMaterial) var display_material = preload("res://Materials/ViewableDisplayMaterial.tres")

# Effect name
export var effect_key: String = "amount"

# Effect fade in and fade out speed
export var effect_duration: float = 0.5

# Effect minimum (fade-in: min to max, fade-out: max to min) 
export var effect_min: float = 0.0

# Effect maximum
export var effect_max: float = 20.0

# Process user input after this amount of seconds, so the user cannot click through stuff
export var input_delay: float = 0.1

onready var inner_display: Node2D = $InnerDisplay
onready var container: Node2D = $InnerDisplay/Container
onready var background_light: Sprite = $InnerDisplay/BackgroundLight

var visible_since: float = 0.0

func _ready() -> void:
	ViewableManager.set_display(self)

func _set_effect(value: float) -> void:
	inner_display.modulate.a = value

	var effect_value = effect_min + (1.0 - value) * (effect_max - effect_min)

	for child in container.get_children():
		child.material.set_shader_param(effect_key, effect_value)

func show(viewable: Viewable, enlarged_zoom: float, description_text: String):
	# Calculate the right child scale and center position
	var project_size = VirtualInput.get_project_size()
	var texture_size = viewable.texture.get_size()
	var center_position = project_size / 2

	if viewable.region_enabled:
		texture_size = viewable.region_rect.size

	var ratio = project_size / texture_size
	var child_scale = min(ratio.x, ratio.y) * enlarged_zoom
	
	# Create a duplicate from the incoming Viewable and set the correct parameters
	var dupe = viewable.duplicate()
	
	dupe.set_script(selectable_script)
	dupe.material = display_material
	dupe.material.set_shader_param(effect_key, effect_max)
	dupe.scale = Vector2(child_scale, child_scale)
	dupe.rotation_degrees = 0.0
	dupe.position = Vector2.ZERO
	dupe.z_index = 0

	# Add the duplicate to the container
	container.add_child(dupe)

	# Hide cursor
	CursorManager.hide(0.0)
	
	# Disable motion input
	VirtualInput.disable_motion = true
	
	# Disable every selectable
	SelectableManager.disable = true
	
	# Freeze players
	PlayerManager.call_each("freeze")

	# Play effect
	Animator.run(self, "_set_effect", 0.0, 1.0, effect_duration)
	
	# Show inner display
	inner_display.position = center_position
	inner_display.visible = true

	# Reset the counter to zero
	visible_since = 0.0

	# Force reset the description text and set it to the new value
	SubtitleManager.set_describe(container.get_instance_id(), description_text, true)

func hide() -> void:
	# Reset describe text
	SubtitleManager.reset_describe(container.get_instance_id(), true)
	
	# Play effect
	yield(Animator.run(self, "_set_effect",
		1.0, 0.0, effect_duration), "completed")
	
	# Unfreeze players
	PlayerManager.call_each("unfreeze")
	
	# Hide inner display
	inner_display.visible = false
	
	# Remove children of the container
	Tools.remove_childs(container)
	
	# Enable motion input
	VirtualInput.disable_motion = false

	# Show cursor
	CursorManager.show()

	# Enable selectables
	SelectableManager.disable = false

func _process(delta: float) -> void:
	if inner_display.visible:
		visible_since += delta

func _input(event: InputEvent) -> void:
	var is_button_event = event is InputEventMouseButton

	if not inner_display.visible or not is_button_event or not event.pressed:
		return
	
	var is_tween_active = Animator.is_active(self, "_set_effect")
	
	if is_tween_active or visible_since < input_delay:
		return
	
	hide()

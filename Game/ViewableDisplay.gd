class_name ViewableDisplay
extends Node

# Selectable script
export (Script) var selectable_script = preload("res://Prefabs/Selectable/PureSelectable.gd")

# Display material
export (ShaderMaterial) var display_material = preload("res://Materials/ViewableDisplayMaterial.tres")

# Effect name
export var effect_key: String = "amount"

# Effect fade in and fade out speed
export var effect_speed: float = 0.33

# Effect minimum (fade-in: min to max, fade-out: max to min) 
export var effect_min: float = 0.0

# Effect maximum
export var effect_max: float = 20.0

# Process user input after this amount of seconds, so the user cannot click through stuff
export var input_delay: float = 0.1

onready var tween: Tween = $Tween
onready var display: Node2D = $Display
onready var container: Node2D = $Display/Container
onready var background_light: Sprite = $Display/BackgroundLight

var visible_since: float = 0.0

func _ready() -> void:
	ViewableManager.set_display(self)
	
	display.visible = false

func _set_effect(amount: float) -> void:
	for child in container.get_children():
		child.material.set_shader_param(effect_key, amount)

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
	VirtualCursorManager.hide()
	
	# Disable every selectable
	VirtualInput.disable_selectable = true
	
	# Freeze players
	PlayerManager.call_each("freeze")
	
	# Show display
	display.position = center_position
	display.visible = true
	display.modulate.a = 0.0

	# Reset the counter to zero
	visible_since = 0.0
	
	# Play effect
	tween.interpolate_property(
		display,
		"modulate:a",
		0.0,
		1.0,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.interpolate_method(
		self,
		"_set_effect",
		effect_max,
		effect_min,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

	# Force reset the description text and set it to the new value
	SubtitleManager.set_describe(container.get_instance_id(), description_text, true)

func hide() -> void:
	# Play effect
	tween.interpolate_property(
		display,
		"modulate:a",
		1.0,
		0.0,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.interpolate_method(
		self,
		"_set_effect",
		effect_min,
		effect_max,
		effect_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()

	# Reset describe text
	SubtitleManager.reset_describe(container.get_instance_id(), true)
	
	yield(tween, "tween_all_completed")
	
	# Unfreeze players
	PlayerManager.call_each("unfreeze")
	
	# Hide display
	display.visible = false
	
	# Remove children of the container
	Tools.remove_childs(container)

	# Show cursor
	VirtualCursorManager.show()

	# Enable selectables
	VirtualInput.disable_selectable = false

func _process(delta: float) -> void:
	if display.visible:
		visible_since += delta

func _input(event: InputEvent) -> void:
	if not display.visible or not (event is InputEventMouseButton) or not event.pressed:
		return
	
	if tween.is_active() or visible_since < input_delay:
		return
	
	hide()

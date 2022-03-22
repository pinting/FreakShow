extends Node

var random_generator: RandomNumberGenerator
var noise: OpenSimplexNoise

const SILENT: float = -100.0

func _ready() -> void:
	random_generator = RandomNumberGenerator.new()
	noise = OpenSimplexNoise.new()
	
	random_generator.randomize()
	
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

	if Config.no_sound:
		# Mute each audio server
		for i in range(AudioServer.bus_count):
			AudioServer.set_bus_volume_db(i, SILENT)

func _process(_delta: float) -> void:
	# Process toggle fullscreen button
	if VirtualInput.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

# Destroy an object, remove it from its parent and mark for garbage collection
func destroy_node(object: Object, deferred: bool = false):
	if not is_instance_valid(object):
		return
	
	var parent = object.get_parent()

	if parent:
		if deferred:
			parent.call_deferred("remove_child", object)
		else:
			parent.remove_child(object)
	
	object.set_script(null)
	object.queue_free()

func play_packed_particles(instance: Node2D, parent: Node2D, timeout: float = 0.0) -> void:
	assert(instance is Particles2D or instance is CPUParticles2D,
		"Only Particles2D or CPUParticles2D are supported")
	
	parent.add_child(instance)
	
	instance.emitting = true
	
	if timeout <= 0.0:
		timeout = instance.lifetime
	
	yield(Tools.wait(timeout), "completed")
	Tools.destroy_node(instance)

# Animate the volume of AudioStreamPlayer
func animate_volume(player, from_db: float, to_db: float, duration: float = 2.0) -> void:
	Animator.run(player, "volume_db", from_db, to_db, duration)

# Animate the pitch of AudioStreamPlayer
func animate_pitch(player, from_pitch: float, to_pitch: float, duration: float = 2.0) -> void:
	Animator.run(player, "pitch_scale", from_pitch, to_pitch, duration)

# Generate a random integer
func random_int(min_value: int, max_value: int) -> int:
	return random_generator.randi_range(min_value, max_value)

# Generate a random float
func random_float(min_value: float, max_value: float) -> float:
	return random_generator.randf_range(min_value, max_value)

# Generate N number of random bytes
func random_bytes(n: int):
	var r = []
	
	for _index in range(0, n):
		r.append(random_int(0, 256))
	
	return r

# Generate a binary UUID
func uuid_bin():
	var b = random_bytes(16)
	
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	
	return b

# Generate an UUID
func uuid():
	var b = uuid_bin()
	
	var l = "%02x%02x%02x%02x" % [b[0], b[1], b[2], b[3]]
	var m = "%02x%02x" % [b[4], b[5]]
	var h = "%02x%02x" % [b[6], b[7]]
	var c = "%02x%02x" % [b[8], b[9]]
	var n = "%02x%02x%02x%02x%02x%02x" % [b[10], b[11], b[12], b[13], b[14], b[15]]
	
	return "%s-%s-%s-%s-%s" % [l, m, h, c, n]

# Disable every shape of a collision object
func set_shapes_disabled(body: CollisionObject2D, disabled: bool) -> void:
	for child in body.get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			child.disabled = disabled

# Change body visibility and disable/enable the shapes
func set_body_visibility(body: CollisionObject2D, state: float) -> void:
	body.visible = state
	
	set_shapes_disabled(body, not state)
	
	# Sometimes the first disabled change is ignored
	yield(Tools.wait(0.1), "completed")
	set_shapes_disabled(body, not state)

# Remove every child not, except one with the given index
func keep_child_at(parent: Node, index: int):
	var children = parent.get_children()
	var count = parent.get_child_count()
	var chosen = null
	
	assert(index < count, "Index greater or equal than count")
	
	for i in range(count, 0, -1):
		var child = children[i - 1]
		
		if i - 1 != index:
			parent.remove_child(child)
			child.queue_free()
		else:
			chosen = child
	
	return chosen

# Change group visibility and disable/enable the shapes
func set_group_visibility(name: String, state: bool, with_shapes: bool = false) -> void:
	var nodes = get_tree().get_nodes_in_group(name)
	
	for node in nodes:
		node.visible = state
		
		if with_shapes:
			set_shapes_disabled(node, not state)

# Remove every child node
func remove_childs(parent: Node):
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

# Get the longest line from a string with line breaks
func get_longest_line(text: String) -> String:
	var lines = text.split("\n")
	
	var current_max = 0
	var selected_line = ""
	
	for line in lines:
		var length = len(line)
		
		if current_max < length:
			current_max = length
			selected_line = line
	
	return selected_line

# Convert number to string with padding
func pad_number(number: int, count: int, c: String = "0") -> String:
	var str_number = str(number)
	var pad_count = max(0, count - len(str_number))
	var result = str_number

	for _i in range(pad_count):
		result = c + result
	 
	return result

# Wait for the given duration in seconds
func wait(duration: float = 1.0) -> void:
	yield(get_tree().create_timer(duration), "timeout")

# Print a debug message (if enabled in the Config)
func debug(message: String) -> void:
	if Config.DEBUG:
		print(message)

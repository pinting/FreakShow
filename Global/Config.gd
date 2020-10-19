extends Node

# Max loading time per tick (in msec)
const LOADING_TIME_PER_TICK: int = 100

# Enable debug messages
const DEBUG: bool = true

# Report endpoint
const REPORT_URL = "https://j82k55n66d.execute-api.us-east-1.amazonaws.com/prod/report"

# Disable intro
var no_intro: bool = false

# Disable sounds
var no_sound: bool = false

# Only use the virtual mouse
var only_virtual_mouse: bool = false

# Virtual cursor instead of the windows one
var virtual_cursor: bool = false

# Virtual mouse speed
var virtual_mouse_speed: Vector2 = Vector2(3, 3)

# Last loaded scene
var last_loaded_scene = null

func _ready() -> void:
	if not DEBUG:
		_read_config()
	
	save_config()
	
	if no_sound:
		for i in range(AudioServer.bus_count):
			AudioServer.set_bus_volume_db(i, -500)

func _read_config() -> void:
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")

	if error != OK:
		return
	
	if config.has_section_key("game", "no_sounds"):
		no_sound = config.get_value("game", "no_sounds")
	
	if config.has_section_key("game", "no_intro"):
		no_sound = config.get_value("game", "no_intro")
	
	if config.has_section_key("game", "last_loaded_scene"):
		last_loaded_scene = config.get_value("game", "last_loaded_scene")
		
	if config.has_section_key("input", "virtual_cursor"):
		virtual_cursor = config.get_value("game", "virtual_cursor")
	
	if config.has_section_key("input", "only_virtual_mouse"):
		only_virtual_mouse = config.get_value("game", "only_virtual_mouse")
	
	if config.has_section_key("input", "virtual_mouse_speed"):
		virtual_mouse_speed = config.get_value("game", "virtual_mouse_speed")

func save_config() -> void:
	var config = ConfigFile.new()
	
	config.set_value("game", "no_sounds", no_sound)
	config.set_value("game", "no_intro", no_intro)
	config.set_value("game", "last_loaded_scene", last_loaded_scene)
	config.set_value("input", "virtual_cursor", virtual_cursor)
	config.set_value("input", "only_virtual_mouse", only_virtual_mouse)
	config.set_value("input", "virtual_mouse_speed", virtual_mouse_speed)

	config.save("user://settings.cfg")

extends Node

# Enable debug messages
const DEBUG: bool = true

# Report endpoint
const REPORT_URL: String = "https://j82k55n66d.execute-api.us-east-1.amazonaws.com/prod/report"

# Path to the configuration file
const CONFIG_PATH: String = "user://config.cfg"

# Max loading time per tick (in msec)
const LOADING_TIME_PER_TICK: int = 100

# Start scene
const FIRST_SCENE: String = "res://Scenes/Part01/Part01.tscn"

# Credits scene
const CREDITS_SCENE: String = "res://Scenes/Credits.tscn"

# Disable sounds
var no_sound: bool = true

# Save file path
var save_path: String = "user://default.save"

# Only use the virtual mouse
var virtual_mouse_only: bool = false

# Virtual mouse speed
var virtual_mouse_speed: Vector2 = Vector2(3, 3)

func _ready() -> void:
	if not _exists():
		save()
	elif not DEBUG:
		_load()

func _exists() -> bool:
	return File.new().file_exists(CONFIG_PATH)

func _load() -> void:
	if not _exists():
		return
	
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	
	no_sound = config.get_value("game", "no_sound", no_sound)
	save_path = config.get_value("game", "save_path", save_path)
	virtual_mouse_only = config.get_value("input", "virtual_mouse_only", virtual_mouse_only)
	virtual_mouse_speed = config.get_value("input", "virtual_mouse_speed", virtual_mouse_speed)
	
	# If config exists, but corrupted, fix it
	if error != OK:
		save()

func save() -> void:
	var config = ConfigFile.new()
	
	config.set_value("game", "no_sound", no_sound)
	config.set_value("game", "save_path", save_path)
	config.set_value("input", "virtual_mouse_only", virtual_mouse_only)
	config.set_value("input", "virtual_mouse_speed", virtual_mouse_speed)

	config.save(CONFIG_PATH)

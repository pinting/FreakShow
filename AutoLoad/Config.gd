extends Node

# Enable debug messages
const DEBUG: bool = false

# Report endpoint
const REPORT_URL: String = "https://j82k55n66d.execute-api.us-east-1.amazonaws.com/prod/report"

# Path to the configuration file
const CONFIG_PATH: String = "user://config.cfg"

# Max loading time per tick (in msec)
const LOADING_TIME_PER_TICK: int = 100

# Order of scenes
const SCENES = [
	"res://Scenes/Part00/Part00.tscn",
	"res://Scenes/Part01/Part01.tscn",
	"res://Scenes/Part02/Part02.tscn",
	"res://Scenes/Part03/Part03.tscn",
#	"res://Scenes/Part04/Part04.tscn",
#	"res://Scenes/Part05/Part05.tscn",
#	"res://Scenes/Part06/Part06.tscn",
	"res://Scenes/Credits.tscn"
]

# Disable sounds
var no_sound: bool = false

# Gamma
var gamma: float = 1.35

# Save file path
var save_path: String = "user://default.save"

# Lock mouse in the window
var lock_mouse: bool = true

# Virtual mouse speed
var virtual_mouse_speed: Vector2 = Vector2(2, 2)

# Low performance
var low_performance: bool = false

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
	gamma = config.get_value("game", "gamma", gamma)
	save_path = config.get_value("game", "save_path", save_path)
	low_performance = config.get_value("game", "low_performance", low_performance)
	lock_mouse = config.get_value("input", "lock_mouse", lock_mouse)
	virtual_mouse_speed = config.get_value("input", "virtual_mouse_speed", virtual_mouse_speed)
	
	# If config exists, but corrupted, fix it
	if error != OK:
		save()

func save() -> void:
	var config = ConfigFile.new()
	
	config.set_value("game", "no_sound", no_sound)
	config.set_value("game", "gamma", gamma)
	config.set_value("game", "save_path", save_path)
	config.set_value("game", "low_performance", low_performance)
	config.set_value("input", "lock_mouse", lock_mouse)
	config.set_value("input", "virtual_mouse_speed", virtual_mouse_speed)

	config.save(CONFIG_PATH)

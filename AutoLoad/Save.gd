extends Node

# Encryption password
const ENCRYPTION_PASS = "JUD5Tv26ARc4UQVfWzFXgDrjwWbczEgWzVgSxUeHf4qEyHFK"

var current: ConfigFile = null
var temp: Dictionary = {}

func _ready() -> void:
	_prepare()
	_load()

func _prepare() -> void:
	current = ConfigFile.new()
	temp = {}

func _exists() -> bool:
	return File.new().file_exists(Config.save_path)

func remove() -> void:
	Directory.new().remove(Config.save_path)

func clear() -> void:
	remove()
	_prepare()
	save()

func _load() -> void:
	if not _exists():
		return
	
	var error = current.load_encrypted_pass(Config.save_path, ENCRYPTION_PASS)
	
	if error != OK:
		Tools.debug("Loading SAVE failed")

func save() -> void:
	var error = current.save_encrypted_pass(Config.save_path, ENCRYPTION_PASS)

	if error != OK:
		Tools.debug("Saving SAVE failed")

func get_value(section: String, key: String, default = null):
	if not current.has_section(section):
		return default
	
	return current.get_value(section, key, default)

func set_value(section: String, key: String, value) -> void:
	Tools.debug(str("Setting ", section, "/", key, " to ", value))
	current.set_value(section, key, value)
	save()

func set_temp(key: String, value) -> void:
	temp[key] = value

func get_temp(key: String, default = null):
	if temp.has(key):
		return temp[key]
	else:
		return default

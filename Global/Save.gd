extends Node

# Encryption password
const ENCRYPTION_PASS = "JUD5Tv26ARc4UQVfWzFXgDrjwWbczEgWzVgSxUeHf4qEyHFK"

var current: ConfigFile = null

func _ready() -> void:
	_prepare()
	_load()

func _prepare() -> void:
	current = ConfigFile.new()

func _exists() -> bool:
	return File.new().file_exists(Config.save_path)

func _remove() -> void:
	Directory.new().remove(Config.save_path)

func clear() -> void:
	_remove()
	_prepare()
	save()

func _load() -> void:
	if not _exists():
		return
	
	var error = current.load_encrypted_pass(Config.save_path, ENCRYPTION_PASS)
	
	if error != OK:
		Game.debug("Loading SAVE failed")

func save() -> void:
	if not Config.DEBUG:
		current.erase_section("temp")
	
	var error = current.save_encrypted_pass(Config.save_path, ENCRYPTION_PASS)

	if error != OK:
		Game.debug("Saving SAVE failed")

func get_value(section: String, key: String, default = null):
	return current.get_value(section, key, default)

func set_value(section: String, key: String, value) -> void:
	Game.debug(str("Setting ", section, "/", key, " to ", value))
	current.set_value(section, key, value)
	save()

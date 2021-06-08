extends Node

var external_text_cache: Dictionary = {}

func _ready() -> void:
	pass

func _get_external_text(path: String) -> String:
	if external_text_cache.has(path):
		return external_text_cache[path]
	
	var file = File.new()
	var error = file.open("res://" + path, File.READ)
	
	if error != OK:
		Tools.debug(str("Loading external text failed for '", path, "'"))
		return ""

	var content = file.get_as_text()

	external_text_cache[path] = content
	
	file.close()
	
	return content

func find(key: String) -> String:
	if not key or not len(key):
		return ""
	
	var value = tr(key)
	var length = len(value)

	if not length or value == key:
		Tools.debug(str("Translation for key '", key, "' was not found."))
		return ""
	
	# If translation value contains a path surrended by
	# less-than and greater-than symbols, the path will be
	# given to the external text loader.
	if value[0] == "<" and value[length - 1] == ">":
		var path = value.substr(1, length - 2)

		return _get_external_text(path)
	
	return value

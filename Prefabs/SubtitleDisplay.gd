class_name SubtitleDisplay
extends Node2D

# Debug the subtitle display (Config.debug needs to be true)
export var debug: bool = false

onready var top = $Top/Top
onready var bottom = $Bottom/Bottom

var current_describe_owner = null
var keep_describe = false
var lines = []

func _ready() -> void:
	Game.subtitle_display = self
	
	top.text = ""
	bottom.text = ""

func _process(delta: float) -> void:
	var text = ""
	var marked = []
	var i = 0
	
	for line in lines:
		var position = floor(len(line.text) * line.show_percentage)
		
		text += line.text.left(position) + "\r\n"
		
		var speed = line.speed if line.speed > 0 else 0.001
		
		line.show_percentage += delta / speed
		line.show_percentage = min(1, line.show_percentage)
		line.timeout -= delta
		
		if line.timeout <= 0.0:
			marked.push_front(i)
		
		i += 1
	
	for n in marked:
		lines.remove(n)
	
	bottom.text = text
	
func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
	lines.push_back({
		"text": text,
		"speed": speed,
		"timeout": timeout,
		"show_percentage": 0 if speed > 0 else 100
	})

func describe(owner: int, text: String, keep: bool = false) -> void:
	_debug(str("Set describe for ", owner, " and KEEP" if keep else ""))

	if keep_describe:
		return
	
	top.text = text
	current_describe_owner = owner
	keep_describe = keep

func describe_reset(owner: int, force: bool = false) -> void:
	_debug(str("Remove describe for ", owner, " with FORCE" if force else ""))

	if current_describe_owner == owner or force:
		top.text = ""
		current_describe_owner = null
		keep_describe = false

func _debug(message: String) -> void:
	if debug:
		Game.debug(message)

func destroy() -> void:
	get_parent().remove_child(self)
	queue_free()

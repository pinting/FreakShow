class_name SubtitleDisplay
extends Node2D

onready var top = $Top/Top
onready var bottom = $Bottom/Bottom

var current_describe_key = null
var keep_describe = false
var lines = []

func _ready():
	Global.subtitle_display = self
	
	top.text = ""
	bottom.text = ""

func _process(delta: float):
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
	
func say(text: String, speed: float = 2.0, timeout: float = 10.0):
	lines.push_back({
		"text": text,
		"speed": speed,
		"timeout": timeout,
		"show_percentage": 0 if speed > 0 else 100
	})

func describe(key: int, text: String, keep: bool = false):
	if keep_describe:
		return
	
	top.text = text
	current_describe_key = key
	keep_describe = keep

func describe_remove(key: int, force: bool = false):
	if current_describe_key == key or force:
		top.text = ""
		current_describe_key = null
		keep_describe = false

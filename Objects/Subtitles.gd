extends Node2D

onready var top = $Top
onready var bottom = $Bottom

var lines = []

func _ready():
	Global.subtitles = self

func _process(delta):
	var text = ""
	var marked = []
	var i = 0
	
	for line in lines:
		var position = floor(len(line.text) * line.show_percentage)
		
		text += line.text.left(position) + "\r\n"
		
		line.show_percentage += delta / line.speed
		line.show_percentage = min(1, line.show_percentage)
		line.timeout -= delta
		
		if line.timeout <= 0:
			marked.push_front(i)
		
		i += 1
	
	for i in marked:
		lines.remove(i)
	
	bottom.text = text
	
func say(text, speed = 2, timeout = 10):
	lines.push_back({
		"text": text,
		"speed": speed,
		"timeout": timeout,
		"show_percentage": 0 if speed > 0 else 100
	})

func describe(text, remove = false):
	if remove:
		if top.text == text:
			top.text = ""
	else:
		top.text = text

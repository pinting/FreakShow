extends Node2D

onready var top = $Top
onready var bottom = $Bottom

var current_describe_key = null
var lines = []

func _ready():
	Global.subtitle_display = self

func _process_text(delta):
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

func _process_position(_delta):
	var camera = Global.current_camera
	
	if camera != null:
		position = camera.get_camera_screen_center()

func _process(delta):
	_process_text(delta)
	_process_position(delta)
	
func say(text, speed = 2, timeout = 10):
	lines.push_back({
		"text": text,
		"speed": speed,
		"timeout": timeout,
		"show_percentage": 0 if speed > 0 else 100
	})

func describe(key, text):
	top.text = text
	current_describe_key = key

func describe_remove(key):
	if current_describe_key == key:
		top.text = ""
		current_describe_key = null

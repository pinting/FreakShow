class_name SubtitleDisplay
extends Node

# Debug the subtitle display (Config.debug needs to be true)
export var debug: bool = false

# Line break
export var line_break: String = "\r\n"

onready var tween: Tween = $Tween

onready var top_label: Label = $TopLabel
onready var bottom_label: Label = $BottomLabel
onready var center_label: Label = $CenterLabel

var current_describe_owner = null
var keep_describe = false
var lines = []

signal line_timeout

func _ready() -> void:
	SubtitleManager.set_display(self)
	
	top_label.text = ""
	bottom_label.text = ""
	center_label.text = ""

	top_label.visible = true
	bottom_label.visible = true
	center_label.visible = true
	
	center_label.modulate.a = 0.0

func _process(delta: float) -> void:
	var text = ""
	var marked = []
	var i = 0
	
	for line in lines:
		var s = line.speed
		var p = line.show_percentage

		var position = floor(len(line.text) * p)
		
		text += line.text.left(position) + line_break
		
		if s > 0.0 and p < 1.0:
			line.show_percentage = min(1.0, p + delta / s)
		else:
			line.show_percentage = 1.0
		
		line.timeout -= delta
		
		if line.timeout <= 0.0:
			marked.push_front(i)
		
		i += 1
	
	for n in marked:
		lines.remove(n)
		emit_signal("line_timeout")
	
	bottom_label.text = text

func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
	lines.push_back({
		"text": text,
		"speed": speed,
		"timeout": timeout,
		"show_percentage": 0.0 if speed > 0.0 else 1.0
	})

func set_describe(owner: int, text: String, keep: bool = false, duration: float = 0.33) -> void:
	_debug(str("Set describe for '", owner, "'", " and keep" if keep else ""))

	if keep_describe:
		return
	
	top_label.text = text
	current_describe_owner = owner
	keep_describe = keep
	
	tween.stop(top_label, "modulate:a")
	tween.interpolate_property(top_label, "modulate:a", top_label.modulate.a, 1.0, duration)
	tween.start()

func reset_describe(owner: int, force: bool = false, duration: float = 0.33) -> void:
	_debug(str("Remove describe for '", owner, "'", " with force" if force else ""))

	if current_describe_owner != owner and not force:
		return
	
	current_describe_owner = null
	keep_describe = false

	tween.stop(top_label, "modulate:a")
	tween.interpolate_property(top_label, "modulate:a", top_label.modulate.a, 0.0, duration)
	tween.start()
	
	yield(tween, "tween_completed")
	
	if current_describe_owner == null:
		top_label.text = ""

func show_quote(text: String, duration: float = 5.0) -> void:
	center_label.text = text
	
	tween.stop(center_label, "modulate:a")
	tween.interpolate_property(center_label, "modulate:a", center_label.modulate.a, 1.0, duration)
	tween.start()

func hide_quote(duration: float = 5.0) -> void:	
	tween.stop(center_label, "modulate:a")
	tween.interpolate_property(center_label, "modulate:a", center_label.modulate.a, 0.0, duration)
	tween.start()

func _debug(message: String) -> void:
	if debug:
		Tools.debug(message)

extends Node

signal display_changed

var display: SubtitleDisplay = null
var say_queue = []

const describe_duration = 0.33

func set_display(subtitle_display: SubtitleDisplay) -> void:
	if not subtitle_display:
		return
	
	display = subtitle_display

	for say in say_queue:
		display.say(say.text, say.speed, say.timeout)
	
	Tools.debug("Subtitle display changed")
	emit_signal("display_changed")

func clear() -> void:
	if not display:
		Tools.debug("SubtitleDisplay not exists, but clear was called")
		return
	
	Tools.destroy_node(display)
	
	display = null

func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
	if not display:
		say_queue.push_back({ "text": text, "speed": speed, "timeout": timeout })
	else:
		display.say(text, speed, timeout)
	
	yield(Tools.timer(timeout), "timeout")

func set_describe(owner: int, text: String, keep: bool = false) -> void:
	if not display:
		Tools.debug("SubtitleDisplay not exists, but set_describe was called")
		return
	
	display.set_describe(owner, text, keep, describe_duration)

func reset_describe(owner: int, force: bool = false) -> void:
	if not display:
		Tools.debug("SubtitleDisplay not exists, but reset_describe was called")
		return
	
	display.reset_describe(owner, force, describe_duration)

func show_quote(text: String) -> void:
	if not display:
		Tools.debug("SubtitleDisplay not exists, but show_quote was called")
		return
	
	display.show_quote(text)
func hide_quote() -> void:
	if not display:
		Tools.debug("SubtitleDisplay not exists, but hide_quote was called")
		return
	
	display.hide_quote()

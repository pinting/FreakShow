extends Node

var say_queue = []
	
func say(text: String, speed: float = 2.0, timeout: float = 10.0) -> void:
    if not Game.subtitle_display:
        say_queue.push_back({
            "text": text,
            "speed": speed,
            "timeout": timeout
        })
    else:	
        for s in say_queue:
            Game.subtitle_display.say(s.text, s.speed, s.timeout)
        
        Game.subtitle_display.say(text, speed, timeout)

func describe(owner: int, text: String, keep: bool = false) -> void:
    if Game.subtitle_display:
        Game.subtitle_display.describe(owner, text, keep)

func describe_reset(owner: int, force: bool = false) -> void:
    if Game.subtitle_display:
        Game.subtitle_display.describe_reset(owner, force)
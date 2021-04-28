extends Viewable

# Text to fill up the Label node with inside
export var text: String = ""

# Auto adujst the size to the text
export var auto_size: bool = false

# Scale auto size 
export var auto_size_scale: float = 1.2

onready var inner_text: Label = $InnerText

func _ready():
	inner_text.text = Text.find(text)
	
	if auto_size:
		_calculate_auto_height()

func _calculate_auto_height() -> void:
	var content = inner_text.text
	
	var font = inner_text.get_font("font")
	var line_count = inner_text.get_line_count()
	var longest_line = Tools.get_longest_line(content)
	var longest_line_size = font.get_string_size(longest_line)
	
	var w = longest_line_size.x
	var h = line_count * longest_line_size.y
	
	var sw = w * auto_size_scale
	var sh = h * auto_size_scale
	
	region_enabled = true
	region_rect = Rect2(0, 0, sw, sh)
	
	inner_text.margin_left = w / -2
	inner_text.margin_top = sh / -2
	inner_text.margin_right = sw / 2
	inner_text.margin_bottom = sh / 2

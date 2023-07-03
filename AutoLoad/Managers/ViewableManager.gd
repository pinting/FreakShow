extends Node

signal display_changed

var display: ViewableDisplay = null

func set_display(viewable_display: ViewableDisplay) -> void:
	if not viewable_display:
		return
	
	display = viewable_display

	Tools.debug("Viewable display changed")
	emit_signal("display_changed")

func clear() -> void:
	if not display:
		Tools.debug("ViewableDisplay not exists, but clear was called")
		return
	
	Tools.destroy_node(display)
	
	display = null

func appear(viewable: Viewable, enlarged_zoom: float, description_text: String):
	if not display:
		Tools.debug("ViewableDisplay not exists, but show was called")
		return
	
	display.appear(viewable, enlarged_zoom, description_text)

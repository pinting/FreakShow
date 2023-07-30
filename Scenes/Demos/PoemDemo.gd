extends BaseScene

@onready var player: Player = $Player
@onready var poem = $Environment/Poem

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	
	var accept_pressed = VirtualInput.is_action_just_pressed("ui_accept")
	
	if accept_pressed:
		poem.appear()

extends Sprite2D

@export var time_scale = 2.0
@export var extra_energy = 0.25

@onready var glow_light_00 = $Glow/Light00
@onready var glow_light_01 = $Glow/Light01
@onready var glow_light_02 = $Glow/Light02

@onready var door = $Door

@onready var bass_sound = $BassSound

signal door_selected

var current_second: float = 0.0
var base_energy: float = 1.0

func _ready() -> void:
	super._ready()
	
	base_energy = glow_light_00.energy
	
	door.connect("selected", Callable(self, "_on_door_selected"))

func _process(delta: float) -> void:
	super._process(delta)

	current_second += delta
	
	var extra = abs(sin(current_second * time_scale)) * extra_energy
	
	glow_light_00.energy = base_energy + extra
	glow_light_01.energy = base_energy + extra
	glow_light_02.energy = base_energy + extra

func _on_door_selected():
	emit_signal("door_selected")

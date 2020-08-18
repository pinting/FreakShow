extends "res://Scenes/BaseScene.gd"

onready var navigation = $Environment/Navigation2D
onready var enemy = $Environment/Enemy

onready var debug_line = $Environment/DebugLine

onready var connect_sound = $Sound/ConnectSound

var music_00: int
var music_01: int

var find_path_tick: float = 0.0

func _ready():
	music_00 = music_mixer.add_part(0, 4 * 60 + 10, false, 0, 20, 0)
	music_01 = music_mixer.add_part(10, 3 * 60 + 20, true, 20, 20, -5)
	
	connect("scene_started", self, "_on_scene_started")

func _on_scene_started():
	if not Global.NO_SOUNDS:
		connect_sound.play()

func _process(delta: float):
	find_path_tick += delta
	
	if find_path_tick > 1.0:
		var raw_path = navigation.get_simple_path(enemy.global_position, player.global_position)
		#var path = enemy.smooth_path(raw_path)
		
		enemy.path = raw_path
		debug_line.points = raw_path
		find_path_tick = 0.0

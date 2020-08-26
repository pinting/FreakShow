extends "res://Scenes/BaseScene.gd"

# How fast should the path finding update
export var PATH_FINDING_INTERVAL = 1.0

# Increase zoom by this amount
export var CAMERA_ZOOM_INCREASE = 10

# Speed of zoom
export var CAMERA_ZOOM_SPEED = 1.0

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var navigation = $Environment/Navigation2D
onready var enemy = $Environment/Enemy
onready var enemy_mouth = $Environment/Enemy/MouthArea
onready var debug_line = $Environment/DebugLine

onready var fall_to_death = $Trigger/FallToDeath
onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd

onready var wall_after_enter = $Environment/HiddenWalls/AfterEnter
onready var wall_after_leave = $Environment/HiddenWalls/AfterLeave

onready var connect_sound = $Sound/ConnectSound

var music_00: int
var music_01: int

var path_finder_fire: float = 0.0
var game_playing: bool = false

func _ready():
	music_00 = music_mixer.add_part(0, 4 * 60 + 10, false, 0, 20, 0)
	music_01 = music_mixer.add_part(10, 3 * 60 + 20, true, 20, 20, -5)
	
	connect("scene_started", self, "_on_scene_started")
	fall_to_death.connect("body_entered", self, "_kill_player")
	enemy_mouth.connect("body_entered", self, "_kill_player")
	game_begin.connect("body_entered", self, "_start_game")
	game_end.connect("body_entered", self, "_end_game")

func _restart_scene():
	player.visible = false
	player.freeze = true
	
	fade_in(0.1)
	yield(timer(1.0), "timeout")
	get_tree().reload_current_scene()

func _kill_player(body: Node):
	if not body.is_in_group("player"):
		return
	
	music_mixer.kill(2.0);
	_restart_scene()

func _start_game(body: Node):
	if not body.is_in_group("player") or game_playing:
		return
	
	game_playing = true
	wall_after_enter.disabled = false
	
	connect_sound.stop()
	player.enable_avatar_mode()
	music_mixer.play()

func _end_game(body: Node):
	if not body.is_in_group("player") or not game_playing:
		return
	
	player.disable_avatar_mode()
	game_playing = false
	wall_after_leave.disabled = false
	
	music_mixer.kill(2.0);

func _on_scene_started():
	connect_sound.play()

func _process(delta: float):
	_process_enemy_path_finding(delta)
	_enlarge_camera_zoom(delta)

func _enlarge_camera_zoom(delta):
	if not game_playing:
		return
	
	var camera = Global.current_camera
	
	if not camera:
		return
	
	if max(camera.zoom.x, camera.zoom.y) < CAMERA_ZOOM_INCREASE:
		var step = delta / CAMERA_ZOOM_SPEED * CAMERA_ZOOM_INCREASE
		
		camera.zoom.x += step
		camera.zoom.y += step

func _process_enemy_path_finding(delta):
	if not game_playing:
		return
	
	path_finder_fire += delta
	
	if path_finder_fire <= PATH_FINDING_INTERVAL:
		return
	
	var path = navigation.get_simple_path(enemy.global_position, player.global_position)
	
	enemy.path = path
	debug_line.points = path
	path_finder_fire = 0.0

extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part00.tscn"

# Next scene after failing
export var fail_scene: String = "res://Scenes/Part02.tscn"

# How fast should the path finding update
export var path_finding_interval: float = 0.5

# Increase zoom by this amount
export var camera_zoom_increase: float = 10.0

# Speed of zoom
export var camera_zoom_speed: float = 1.0

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var debug_line = $Environment/DebugLine
onready var navigation = $Environment/Navigation2D
onready var enemy = $Environment/Enemy
onready var enemy_mouth = $Environment/Enemy/MouthArea
onready var wall_after_enter = $Environment/HiddenWalls/AfterEnter
onready var wall_after_leave = $Environment/HiddenWalls/AfterLeave
onready var removable_line_00 = $Environment/Maze/RemovableLine00
onready var removable_line_01 = $Environment/Maze/RemovableLine01
onready var removable_line_02 = $Environment/Maze/RemovableLine02
onready var removable_line_03 = $Environment/Maze/RemovableLine03
onready var exit_door = $Environment/Maze/WallBlock/ExitDoor

onready var fall_to_death = $Trigger/FallToDeath
onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd
onready var boss_go_back_00 = $Trigger/BossGoBack00
onready var boss_go_back_01 = $Trigger/BossGoBack01

onready var connect_sound = $Sound/ConnectSound
onready var wind_sound = $Sound/WindSound
onready var door_open_sound = $Sound/DoorOpenSound

var music_00: int
var music_01: int

var path_finder_fire: float = 0.0
var game_playing: bool = false

func _ready():
	music_00 = music_mixer.add_part(0, 4 * 60 + 10, false, 0, 20, 0)
	music_01 = music_mixer.add_part(10, 3 * 60 + 20, true, 20, 20, -5)
	
	connect("scene_started", self, "_on_scene_started")
	fall_to_death.connect("body_entered", self, "_fail_game")
	enemy_mouth.connect("body_entered", self, "_fail_game")
	game_begin.connect("body_entered", self, "_start_game")
	game_end.connect("body_entered", self, "_end_game")
	exit_door.connect("selected", self, "_on_exit")
	
	var random_line = Utils.random_int(0, 2, true)
	
	if random_line == 0:
		removable_line_01.remove()
	elif random_line == 1:
		removable_line_02.remove()
	elif random_line == 2:
		removable_line_03.remove()

func _fail_game(body: Node):
	if not body.is_in_group("player"):
		return
	
	if player.dead:
		return
	
	player.kill()
	yield(timer(3.0), "timeout")
	
	fade_out(1.0)
	yield(timer(1.5), "timeout")
	music_mixer.kill(2.0);
	Global.load_scene(fail_scene)

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
	
	enemy.kill()
	player.disable_avatar_mode()
	game_playing = false
	wall_after_leave.disabled = false
	
	music_mixer.kill(2.0);
	wind_sound.play()

func _on_exit():
	door_open_sound.play()
	fade_out(1.0)
	yield(timer(5.0), "timeout")
	wind_sound.stop();
	Global.load_scene(next_scene)

func _on_scene_started():
	connect_sound.play()

func _process(delta: float):
	_process_enemy_path_finding(delta)
	_process_enlarge_camera_zoom(delta)

func _process_enlarge_camera_zoom(delta):
	if not game_playing:
		return
	
	var camera = Global.current_camera
	
	if not camera:
		return
	
	if max(camera.zoom.x, camera.zoom.y) < camera_zoom_increase:
		var step = delta / camera_zoom_speed * camera_zoom_increase
		
		camera.zoom.x += step
		camera.zoom.y += step

func _process_enemy_path_finding(delta):
	if not game_playing or enemy.dead:
		return
	
	path_finder_fire += delta
	
	if path_finder_fire <= path_finding_interval:
		return
	
	var dest = player.global_position
	
	if player.dead:
		var d_00 = player.global_position.distance_to(boss_go_back_00.global_position)
		var d_01 = player.global_position.distance_to(boss_go_back_01.global_position) 
		
		if d_00 > d_01:
			dest = boss_go_back_00.global_position
		else:
			dest = boss_go_back_01.global_position
	
	var path = navigation.get_simple_path(enemy.global_position, dest)
	
	enemy.path = path
	debug_line.points = path
	path_finder_fire = 0.0

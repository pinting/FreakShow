extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part03/Part03.tscn"

# How fast should the path finding update
export var path_finding_interval: float = 0.5

# Default camera zoom
export var camera_zoom_base: float = 6.0

# Increase zoom by this amount
export var camera_zoom_game: float = 10.0

# Speed of zoom
export var camera_zoom_speed: float = 1.0

# Teleport player to the end
export var teleport_player_to_end: bool = false

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var debug_line = $Environment/DebugLine
onready var navigation = $Environment/Navigation2D
onready var exit_door = $Environment/Maze/SteelBlock/WallBlock/ExitDoor
onready var end_tube = $Environment/Maze/EndTube

onready var enemy = $Environment/Enemy
onready var enemy_mouth = $Environment/Enemy/MouthArea

onready var wall_after_enter = $Environment/HiddenWalls/AfterEnter
onready var wall_after_leave = $Environment/HiddenWalls/AfterLeave
onready var wall_ending_bottom = $Environment/HiddenWalls/EndingBottom

onready var removable_line_00 = $Environment/Maze/RemovableLine00
onready var blocking_line_00 = $Environment/Maze/BlockingLine00
onready var blocking_line_01 = $Environment/Maze/BlockingLine01
onready var blocking_line_02 = $Environment/Maze/BlockingLine02

onready var random_line_00 = $Environment/Maze/RandomLine00
onready var random_line_01 = $Environment/Maze/RandomLine01
onready var random_line_02 = $Environment/Maze/RandomLine02
onready var random_line_03 = $Environment/Maze/RandomLine03
onready var random_line_04 = $Environment/Maze/RandomLine04

onready var fall_to_death = $Trigger/FallToDeath
onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd
onready var boss_go_back_00 = $Trigger/BossGoBack00
onready var boss_go_back_01 = $Trigger/BossGoBack01
onready var end_door_area = $Trigger/EndDoorArea
onready var teleport_player = $Trigger/TeleportPlayer

onready var connect_sound = $Sound/ConnectSound
onready var wind_sound = $Sound/WindSound
onready var door_locked_sound = $Sound/DoorLockedSound
onready var falling_sound = $Sound/FallingSound
onready var not_close_enough_sound = $Sound/NotCloseEnoughSound

var music_00: int
var music_01: int

var path_finder_fire: float = 0.0
var game_started: bool = false
var game_playing: bool = false
var not_close_enough_help: bool = true

func _ready():
	music_00 = music_mixer.add_part(0, 4 * 60 + 0.7, false, 0, 0, 0)
	music_01 = music_mixer.add_part(4 * 60 + 0.7, 4 * 60 + 25, true, 0.5, 0.5, -1)
	
	connect("scene_started", self, "_on_scene_started")
	fall_to_death.connect("body_entered", self, "_fail_game")
	enemy_mouth.connect("body_entered", self, "_fail_game")
	game_begin.connect("body_entered", self, "_start_game")
	game_end.connect("body_entered", self, "_end_game")
	exit_door.connect("selected", self, "_on_exit")
	
	var blocking_lines = [blocking_line_00, blocking_line_01, blocking_line_02]
	
	blocking_lines[Utils.random_int(0, len(blocking_lines))].remove()
	
	var random_lines = [random_line_00, random_line_01, random_line_02, random_line_03, random_line_04]
	
	for n in range(Utils.random_int(0, len(random_lines))):
		var i = Utils.random_int(0, len(random_lines))
		
		random_lines[i].remove()
		random_lines.remove(i)
	
	var camera = Global.current_camera
	
	if camera:
		camera.zoom = Vector2(camera_zoom_base, camera_zoom_base)

func _fail_game(body: Node):
	if not body.is_in_group("player"):
		return
	
	if player.dead:
		return
	
	player.kill()
	yield(timer(3.0), "timeout")
	
	music_mixer.kill(2.0);
	
	load_scene(get_parent().filename)

func _start_game(body: Node):
	if not body.is_in_group("player") or game_playing:
		return
	
	wall_after_enter.disabled = false
	
	if not teleport_player_to_end:
		player.enable_avatar_mode()
	
		connect_sound.stop()
		music_mixer.play()
		
		Global.subtitle.say(tr("NARRATOR05"), 0.5, 3.0)
		yield(timer(2.0), "timeout")
	
	game_playing = true
	game_started = true

func _end_game(body: Node):
	if not body.is_in_group("player") or not game_playing:
		return
	
	player.disable_avatar_mode()
	game_playing = false
	wall_after_leave.disabled = false
	
	music_mixer.kill(2.0);
	wind_sound.play()

func _on_exit():
	if not end_door_area.visible:
		return false
	
	if not end_door_area.overlaps_body(player):
		if not_close_enough_help:
			Global.subtitle.say(tr("NARRATOR06"))
			
			not_close_enough_help = false
		
		not_close_enough_sound.play()
		return;
	
	end_door_area.visible = false
	
	player.freeze(true)
	door_locked_sound.play()
	
	yield(timer(0.75), "timeout")
	
	falling_sound.play()
	
	end_tube.open_mouth = true
	
	yield(timer(0.25), "timeout")
	
	wall_ending_bottom.disabled = true
	
	yield(timer(1.0), "timeout")
	Global.subtitle.say(tr("NARRATOR07"))
	fade_out(2.0)
	yield(timer(5.0), "timeout")
	
	load_scene(next_scene)

func _on_scene_started():
	if teleport_player_to_end:
		_start_game(player)
		_end_game(player)
		
		player.position = teleport_player.position
	else:
		connect_sound.play()

func _process(delta: float):
	_process_enemy_path_finding(delta)
	_process_camera_zoom(delta)

func _process_camera_zoom(delta):
	var camera = Global.current_camera
	
	if not camera:
		return
	
	var step = 0
	
	if game_playing and max(camera.zoom.x, camera.zoom.y) < camera_zoom_game:
		step = delta / camera_zoom_speed * (camera_zoom_game - camera_zoom_base)
	
	if not game_playing and max(camera.zoom.x, camera.zoom.y) > camera_zoom_base:
		step = delta / camera_zoom_speed * (camera_zoom_base - camera_zoom_game)
		
	camera.zoom.x += step
	camera.zoom.y += step

func _process_enemy_path_finding(delta):
	if not game_started or enemy.dead:
		return
	
	path_finder_fire += delta
	
	if path_finder_fire <= path_finding_interval:
		return
	
	var dest = player.global_position
	
	if player.dead or not game_playing:
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

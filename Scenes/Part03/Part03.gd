extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Part04/Part04.tscn"
export var path_finding_interval: float = 0.5
export var teleport_player_to_end: bool = false

onready var player = $Player
onready var camera = $Player/GameCamera

onready var debug_line = $Environment/DebugLine
onready var navigation = $Environment/Navigation2D
onready var exit_door = $Environment/EndPlatform/SteelBlock/WallBlock/ExitDoor
onready var end_tube = $Environment/EndPlatform/EndTube

onready var boss = $Environment/Boss
onready var boss_mouth = $Environment/Boss/MouthArea

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

onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd
onready var end_door_area = $Trigger/EndDoorArea
onready var player_respawn_00 = $Trigger/PlayerRespawn00
onready var player_respawn_01 = $Trigger/PlayerRespawn01
onready var player_respawn_02 = $Trigger/PlayerRespawn02

onready var main_music = $Sound/MainMusic
onready var connect_sound = $Sound/ConnectSound
onready var wind_sound = $Sound/WindSound
onready var door_locked_sound = $Sound/DoorLockedSound
onready var falling_sound = $Sound/FallingSound
onready var not_close_enough_sound = $Sound/NotCloseEnoughSound

var music_00: int
var music_01: int

var path_finder_fire: float = 0.0
var boss_follows: bool = false
var game_playing: bool = false
var not_close_enough_help: bool = true
var boss_base_position: Vector2
var boss_base_rotation: float

func _ready() -> void:
	music_00 = main_music.add_part(0, 4 * 60 + 0.7, false, 0, 0, 0)
	music_01 = main_music.add_part(4 * 60 + 0.7, 4 * 60 + 25, true, 0.5, 0.5, -1)
	
	connect("scene_started", self, "_on_scene_started")
	boss_mouth.connect("body_entered", self, "_kill_player")
	game_begin.connect("body_entered", self, "_start_game")
	game_end.connect("body_entered", self, "_end_game")
	exit_door.connect("selected", self, "_on_exit")
	player.connect("died", self, "_reset_game")
	player.connect("reseted", self, "_on_player_reset")
	
	var blocking_lines = [blocking_line_00, blocking_line_01, blocking_line_02]
	
	blocking_lines[Tools.random_int(0, len(blocking_lines))].remove()
	
	var random_lines = [random_line_00, random_line_01, random_line_02, random_line_03, random_line_04]
	
	for n in range(Tools.random_int(0, len(random_lines))):
		var i = Tools.random_int(0, len(random_lines))
		
		random_lines[i].remove()
		random_lines.remove(i)
	
	boss_base_position = boss.global_position
	boss_base_rotation = boss.rotation_degrees

func _kill_player(player: Node) -> void:
	if not player.is_in_group("player"):
		return
	
	player.kill()

func _start_game(player: Node) -> void:
	if not player.is_in_group("player") or game_playing:
		return
	
	wall_after_enter.disabled = false
	game_playing = true
	
	# If the actual game is turned off, for debug purposes
	if not teleport_player_to_end:
		camera.zoom_action()
		player.enable_avatar_mode()
		connect_sound.stop()
		main_music.play()
		SubtitleManager.say(tr("NARRATOR04"), 0.5, 3.0)
		yield(Game.timer(2.0), "timeout")
	
	boss_follows = true

func _on_player_reset() -> void:
	boss.path = []
	boss.global_position = boss_base_position
	boss.rotation_degrees = boss_base_rotation

func _reset_game() -> void:
	# Small fix so the player does not show death animation before entering the game
	if not game_playing:
		player.reset()
	else:
		yield(Game.timer(2.0), "timeout")
	
	main_music.kill(0.5)
	
	if game_playing and boss_follows:
		game_playing = false
		boss_follows = false
		
		move_with_fade(player, player_respawn_01.global_position)
	elif not game_playing and not boss_follows:
		move_with_fade(player, player_respawn_00.global_position)
	elif not game_playing and boss_follows:
		move_with_fade(player, player_respawn_02.global_position)

func _end_game(player: Node) -> void:
	if not player.is_in_group("player") or not game_playing:
		return
	
	if not teleport_player_to_end:
		camera.zoom_base()
		player.disable_avatar_mode()

		game_playing = false
		wall_after_leave.disabled = false
	
		main_music.kill(5.0);
	
	wind_sound.play()

func _on_exit() -> void:
	if not end_door_area.visible:
		return false
	
	if not end_door_area.overlaps_body(player):
		if not_close_enough_help:
			SubtitleManager.say(tr("NARRATOR05"))
			not_close_enough_help = false
		
		not_close_enough_sound.play()
		return;
	
	end_door_area.visible = false
	player.freeze(true)
	door_locked_sound.play()
	yield(Game.timer(0.75), "timeout")
	
	falling_sound.play()
	end_tube.open_mouth = true
	yield(Game.timer(0.25), "timeout")

	wall_ending_bottom.disabled = true
	yield(Game.timer(1.0), "timeout")

	black_screen.fade_in(2.0)
	yield(Game.timer(5.0), "timeout")
	
	load_scene(next_scene, true)

func _on_scene_started() -> void:
	black_screen.fade_out(2.0)

	if teleport_player_to_end:
		_start_game(player)
		_end_game(player)
		
		player.position = player_respawn_02.position
	else:
		connect_sound.play()

func _process(delta: float) -> void:
	_process_enemy_path_finding(delta)

func _process_enemy_path_finding(delta) -> void:
	if not boss_follows or boss.dead:
		return
	
	path_finder_fire += delta
	
	if path_finder_fire <= path_finding_interval:
		return
	
	var dest = player.global_position
	
	if player.dead or not game_playing:
		dest = boss_base_position
	
	var path = navigation.get_simple_path(boss.global_position, dest)
	
	boss.path = path
	debug_line.points = path
	path_finder_fire = 0.0

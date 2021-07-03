extends "res://Game/BaseScene.gd"

export var teleport_player_to_end: bool = false
export var path_finding_interval: float = 0.5

onready var player = $Player
onready var camera = $GameCamera
onready var animation_player = $AnimationPlayer
onready var debug_line = $DebugLine

onready var entry_block = $Environment/Maze/EntryBlock

onready var navigation = $Environment/Maze/Navigation
onready var boss = $Environment/Maze/Boss
onready var boss_mouth = $Environment/Maze/Boss/MouthArea

onready var blocking_line_00 = $Environment/Maze/BlockingLine00
onready var blocking_line_01 = $Environment/Maze/BlockingLine01
onready var blocking_line_02 = $Environment/Maze/BlockingLine02

onready var random_line_00 = $Environment/Maze/RandomLine00
onready var random_line_01 = $Environment/Maze/RandomLine01
onready var random_line_02 = $Environment/Maze/RandomLine02
onready var random_line_03 = $Environment/Maze/RandomLine03
onready var random_line_04 = $Environment/Maze/RandomLine04

onready var exit_door = $Environment/EndPlatform/SteelBlock/WallBlock/ExitDoor
onready var end_tube = $Environment/EndPlatform/EndTube
onready var ghost = $Environment/EndPlatform/Ghost

onready var wall_ending_bottom = $Environment/HiddenWalls/EndingBottom

onready var falling_down = $Trigger/FallingDown
onready var before_game = $Trigger/BeforeGame
onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd
onready var end_door_area = $Trigger/EndDoorArea
onready var player_respawn = $Trigger/PlayerRespawn
onready var teleport_player = $Trigger/TeleportPlayer

onready var main_music = $Sound/MainMusic
onready var connect_sound = $Sound/ConnectSound
onready var wind_sound = $Sound/WindSound
onready var falling_sound = $Sound/FallingSound

var music_00: int
var music_01: int

var game_playing: bool = false
var boss_follows: bool = false
var path_finder_counter: float = 0.0

var boss_base_position: Vector2
var boss_base_rotation: float

func _ready() -> void:
	music_00 = main_music.add_part(0, 4 * 60 + 0.7, false, 0, 0, 0)
	music_01 = main_music.add_part(4 * 60 + 0.7, 4 * 60 + 25, true, 0.5, 0.5, -1)
	
	connect("scene_started", self, "_on_scene_started")
	
	falling_down.connect("body_entered", self, "_trigger_falling_from_island", [], CONNECT_ONESHOT)
	before_game.connect("body_entered", self, "_trigger_before_game", [], CONNECT_ONESHOT)
	game_begin.connect("body_entered", self, "_trigger_game_begin")
	boss_mouth.connect("body_entered", self, "_on_boss_touched")
	game_end.connect("body_entered", self, "_trigger_game_end")
	end_door_area.connect("body_entered", self, "_on_exit_reached", [], CONNECT_ONESHOT)
	player.connect("died", self, "_trigger_reset_game")
	player.connect("reseted", self, "_on_player_reset")
	
	var blocking_lines = [blocking_line_00, blocking_line_01, blocking_line_02]
	
	blocking_lines[Tools.random_int(0, len(blocking_lines) - 1)].disable()
	
	var random_lines = [random_line_00, random_line_01, random_line_02, random_line_03, random_line_04]
	
	for n in range(Tools.random_int(0, len(random_lines) - 1)):
		var i = Tools.random_int(0, len(random_lines) - 1)
		
		random_lines[i].disable()
		random_lines.remove(i)
	
	boss_base_position = boss.global_position
	boss_base_rotation = boss.rotation_degrees

func _on_scene_started() -> void:
	black_screen.fade_out(2.0)
	camera.follow_speed = camera.base_follow_speed * 2
	
	if teleport_player_to_end:
		_trigger_falling_from_island(player)
		_trigger_before_game(player)
		_trigger_game_begin(player)
		_trigger_game_end(player)
		move_player(player, teleport_player.position)
		return
	
	connect_sound.play()

func _trigger_falling_from_island(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	camera.follow_offset = Vector2.ZERO
	
	if teleport_player_to_end:
		return
	
	camera.change_zoom(Vector2(4.0, 4.0), 2.0)

func _trigger_before_game(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player.current_velocity.x = 0.0
	
	VirtualCursorManager.hide(false)

func _trigger_game_begin(body: Node) -> void:
	if not body.is_in_group("player") or game_playing:
		return
	
	game_playing = true
	camera.follow_speed = camera.base_follow_speed
	
	# If the actual game is turned off (for debug purposes)
	if teleport_player_to_end:
		return
	
	connect_sound.stop()
	camera.change_zoom(Vector2(10.0, 10.0), 2.0)
	player.freeze()
	player.enable_avatar_mode()
	entry_block.show()
	yield(player.animation_player, "animation_finished")
	
	main_music.play()
	SubtitleManager.say(Text.find("Narrator004"), 0.5, 3.0)
	yield(Tools.timer(2.0), "timeout")
	player.unfreeze()
	
	boss_follows = true

func _on_boss_touched(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player.kill()

# When player is moved
func _on_player_reset() -> void:
	boss.path = []
	boss.global_position = boss_base_position
	boss.rotation_degrees = boss_base_rotation

func _trigger_reset_game() -> void:
	yield(Tools.timer(2.0), "timeout")
	
	camera.follow_speed = camera.base_follow_speed * 2
	game_playing = false
	boss_follows = false
	
	move_player(player, player_respawn.global_position)

func _trigger_game_end(body: Node) -> void:
	if not body.is_in_group("player") or not game_playing:
		return
	
	camera.follow_offset = camera.base_follow_offset / 2
	camera.follow_speed = camera.base_follow_speed * 2
	camera.change_zoom(Vector2(5.0, 5.0), 2.0)
	
	VirtualCursorManager.show()
	wind_sound.play()
	
	if teleport_player_to_end:
		return
	
	player.disable_avatar_mode()
	player.disable_jump = true
	main_music.kill(5.0)
	game_playing = false

func _on_exit_reached(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	player.freeze(true)
	camera.change_zoom(Vector2(3.0, 3.0), 2.0)
	yield(Tools.timer(4.0), "timeout")
	falling_sound.play()
	end_tube.open_mouth = true
	yield(Tools.timer(0.25), "timeout")
	wall_ending_bottom.disabled = true
	yield(Tools.timer(3.0), "timeout")
	yield(black_screen.fade_in(2.0), "tween_completed")
	yield(Tools.timer(1.0), "timeout")
	
	load_next_scene()

func _process(delta: float) -> void:
	if not boss_follows or boss.dead:
		return
	
	path_finder_counter += delta
	
	if path_finder_counter <= path_finding_interval:
		return
	
	var target = player.global_position
	
	if player.dead or not game_playing:
		target = boss_base_position
	
	var path = navigation.get_simple_path(boss.global_position, target)
	
	boss.path = path
	debug_line.points = path
	path_finder_counter = 0.0

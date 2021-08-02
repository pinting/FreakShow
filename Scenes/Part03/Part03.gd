extends "res://Game/BaseScene.gd"

export var teleport_player_to_end: bool = false

const camera_change_duration: float = 2.0

const start_camera_zoom: Vector2 = Vector2(5.0, 5.0)
const start_follow_speed_scale: float = 2.0
const start_follow_offset: float = 1.0

const loop_camera_zoom: Vector2 = Vector2(4.0, 4.0)
const loop_follow_speed_scale: float = 2.0
const loop_follow_offset: float = 0.0

const game_camera_zoom: Vector2 = Vector2(10.0, 10.0)
const game_follow_speed_scale: float = 1.0
const game_follow_offset: float = 0.0

const end_camera_zoom: Vector2 = Vector2(5.0, 5.0)
const end_follow_speed_scale: float = 2.0
const end_follow_offset: float = 0.5

const exit_camera_zoom: Vector2 = Vector2(3.0, 3.0)
const exit_follow_speed_scale: float = 2.0
const exit_follow_offset: float = 0.5

onready var player = $Player
onready var camera = $GameCamera
onready var debug_line = $DebugLine

onready var boss = $Boss
onready var boss_mouth = $Boss/MouthArea

onready var entry_block = $Environment/Maze/EntryBlock
onready var navigation = $Environment/Maze/Navigation
onready var tile_map = $Environment/Maze/Navigation/TileMap

onready var exit_door = $Environment/EndPlatform/SteelBlock/WallBlock/ExitDoor
onready var end_tube = $Environment/EndPlatform/EndTube

onready var wall_ending_bottom = $Environment/HiddenWalls/EndingBottom

onready var falling_down = $Trigger/FallingDown
onready var before_game = $Trigger/BeforeGame
onready var game_begin = $Trigger/GameBegin
onready var game_end = $Trigger/GameEnd
onready var exit_door_area = $Trigger/ExitDoorArea
onready var player_respawn = $Trigger/PlayerRespawn
onready var teleport_player = $Trigger/TeleportPlayer

onready var main_music = $Sound/MainMusic
onready var connect_sound = $Sound/ConnectSound
onready var wind_sound = $Sound/WindSound
onready var falling_sound = $Sound/FallingSound

var music_00: int
var music_01: int

var game_playing: bool = false
var ending_triggered: bool = false

func _ready() -> void:
	music_00 = main_music.add_part(0, 4 * 60 + 0.7, false, 0, 0, 0)
	music_01 = main_music.add_part(4 * 60 + 0.7, 4 * 60 + 25, true, 0.5, 0.5, -1)
	
	connect("scene_started", self, "_on_scene_started")
	
	falling_down.connect("body_entered", self, "_trigger_falling_from_island", [], CONNECT_ONESHOT)
	before_game.connect("body_entered", self, "_trigger_before_game", [], CONNECT_ONESHOT)
	game_begin.connect("body_entered", self, "_trigger_game_begin")
	boss_mouth.connect("body_entered", self, "_on_boss_mouth_interaction")
	game_end.connect("body_entered", self, "_trigger_game_end")
	exit_door.connect("selected", self, "_on_exit_door_selected")
	player.connect("died", self, "_trigger_reset_game")

func _on_scene_started() -> void:
	black_screen.fade_out(2.0)
	
	camera.scale_follow_offset(start_follow_offset)
	camera.scale_follow_speed(start_follow_speed_scale)
	camera.change_zoom(start_camera_zoom, camera_change_duration)
	
	if teleport_player_to_end:
		_trigger_falling_from_island(player)
		_trigger_before_game(player)
		_trigger_game_begin(player)
		_trigger_game_end(player)
		move_player(player, teleport_player.global_position)
		return
	
	connect_sound.play()

func _trigger_falling_from_island(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	camera.scale_follow_offset(loop_follow_offset)
	camera.scale_follow_speed(loop_follow_speed_scale)
	
	if teleport_player_to_end:
		return
	
	camera.change_zoom(loop_camera_zoom, camera_change_duration)

func _trigger_before_game(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player.current_velocity.x = 0.0
	player.freeze(true)
	
	CursorManager.hide()

func _trigger_game_begin(body: Node) -> void:
	if not body.is_in_group("player") or game_playing:
		return
	
	game_playing = true
	
	camera.scale_follow_offset(game_follow_offset)
	camera.scale_follow_speed(game_follow_speed_scale)
	
	if teleport_player_to_end:
		return
	
	camera.change_zoom(game_camera_zoom, camera_change_duration)
	
	connect_sound.stop()
	player.freeze()
	entry_block.show()
	yield(player.enable_avatar_mode(), "completed")
	
	main_music.play()
	SubtitleManager.say(Text.find("Narrator004"), 0.5, 3.0)
	player.unfreeze()
	yield(Tools.timer(1.0), "timeout")
	
	boss.follows = true

func _on_boss_mouth_interaction(body: Node) -> void:
	if body.is_in_group("_removable_line_body"):
		var removable_line = body.get_parent()
		
		if removable_line.enable_boss_interaction:
			removable_line.hide()
	elif body.is_in_group("player"):
		player.kill()

func _trigger_reset_game() -> void:
	boss.go_back = true
	
	yield(Tools.timer(2.0), "timeout")
	yield(black_screen.fade_in(2.0), "tween_completed")
	
	game_playing = false
	
	camera.scale_follow_offset(loop_follow_offset)
	camera.scale_follow_speed(loop_follow_speed_scale)
	
	boss.reset()
	tile_map.reset()
	
	var lines = get_tree().get_nodes_in_group("_removable_line_reset")
	
	for line in lines:
		line.reset()
	
	move_player(player, player_respawn.global_position)

func _trigger_game_end(body: Node) -> void:
	if not body.is_in_group("player") or not game_playing:
		return
	
	boss.go_back = true
	
	camera.scale_follow_offset(end_follow_offset)
	camera.scale_follow_speed(end_follow_speed_scale)
	camera.change_zoom(end_camera_zoom, camera_change_duration)
	
	CursorManager.show()
	wind_sound.play()
	
	if teleport_player_to_end:
		return
	
	main_music.kill(5.0)
	
	player.disable_avatar_mode()
	player.disable_jump = true
	
	game_playing = false

func _on_exit_door_selected() -> void:
	if ending_triggered or not exit_door_area.overlaps_body(player):
		return
	
	ending_triggered = true
	
	camera.scale_follow_offset(exit_follow_offset)
	camera.scale_follow_speed(exit_follow_speed_scale)
	camera.change_zoom(exit_camera_zoom, camera_change_duration)
	
	CursorManager.hide()
	player.freeze(true)
	yield(Tools.timer(4.0), "timeout")
	falling_sound.play()
	end_tube.open_mouth = true
	yield(Tools.timer(0.25), "timeout")
	wall_ending_bottom.disabled = true
	yield(Tools.timer(3.0), "timeout")
	yield(black_screen.fade_in(2.0), "tween_completed")
	yield(Tools.timer(1.0), "timeout")
	
	load_next_scene()

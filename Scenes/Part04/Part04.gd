extends "res://Game/BaseScene.gd"

onready var player = $Player
onready var camera = $GameCamera
onready var screen_effect = $ScreenEffect

onready var keypad = $Environment/BellowLoop/Container/Ditch/Wall/Door00/Keypad
onready var ditch_door = $Environment/BellowLoop/Container/Ditch/Wall/Door01
onready var maintenance_room_door = $Environment/BellowLoop/Container/MaintenanceRoom/Door00
onready var sliding_platform = $Environment/BellowLoop/Container/MaintenanceRoom/Platform/SlidingNode

onready var ditch_spawn = $Trigger/DitchSpawn
onready var maintenance_room_spawn = $Trigger/MaintenanceRoomSpawn
onready var next_level_trigger = $Trigger/NextLevelTrigger

onready var main_music = $Sound/MainMusic
onready var next_level_music = $Sound/NextLevelMusic
onready var door_open_sound = $Sound/DoorOpenSound

var ending_open: bool = false
var code_help_said: bool = false
var ending_triggered: bool = false

var music_00: int
var music_01: int
var music_02: int

func _ready() -> void:
	# There is a small glitch between 1:13 and 1:14 in the track
	music_00 = main_music.add_part(5, 60 + 13, false, 20.0, 0.1, 0)
	music_01 = main_music.add_part(60 + 14, 3 * 60, false, 0.1, 1, -0.2)
	music_02 = main_music.add_part(3 * 60, 4 * 60, true, 0.5, 0.5, -1)
	
	next_level_music.add_part(7 * 60 + 5, 8 * 60, true, 5, 2, 0)
	
	connect("scene_started", self, "_on_scene_started", [], CONNECT_ONESHOT)
	camera.connect("target_reached", self, "_on_camera_reaches", [], CONNECT_ONESHOT)
	ditch_door.connect("selected", self, "_on_ditch_door_selected")
	maintenance_room_door.connect("selected", self, "_on_maintenance_room_door_selected")

func _on_scene_started() -> void:
	camera.disable_follow = true
	camera.follow_speed = camera.base_follow_speed / 4
	
	CursorManager.hide()
	player.freeze(true)
	yield(Tools.timer(1.0), "timeout")
	main_music.play()
	
	SubtitleManager.show_quote(Text.find("Text006"))
	yield(Tools.timer(25.0), "timeout")
	
	camera.disable_follow = false
	
	black_screen.fade_out(10.0)
	yield(Tools.timer(2.0), "timeout")
	SubtitleManager.hide_quote()

func _on_camera_reaches() -> void:
	
	camera.follow_speed = camera.base_follow_speed
	
	player.unfreeze()
	CursorManager.show()
	CursorManager.move_to_center()
	SubtitleManager.say(Text.find("Narrator006"), 3.0)

func _on_ditch_door_selected() -> void:
	move_player(player, maintenance_room_spawn.position, door_open_sound)

func _on_maintenance_room_door_selected() -> void:
	move_player(player, ditch_spawn.position, door_open_sound)

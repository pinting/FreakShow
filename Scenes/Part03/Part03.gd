extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part04.tscn"

onready var player = $Player

onready var ditch_door = $Environment/Ditch/Wall/Door01
onready var maintenance_room_door = $Environment/MaintenanceRoom/Door00

onready var fall_spawn = $Trigger/FallSpawn
onready var ditch_spawn = $Trigger/DitchSpawn
onready var maintenance_room_spawn = $Trigger/MaintenanceRoomSpawn

onready var main_music = $Sound/MainMusic

onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

var music_00: int
var music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(5, 3 * 60, false, 5, 1, 0)
	music_01 = main_music.add_part(3 * 60, 4 * 60, true, 0.5, 0.5, -1)
	
	ditch_door.connect("selected", self, "_on_ditch_door_select")
	maintenance_room_door.connect("selected", self, "_on_maintenance_room_door_select")
	connect("scene_started", self, "_on_scene_started")
	
	main_music.play()
	
	if not Global.NO_INTRO:
		player.freeze(true)
		player.visible = false

func _on_scene_started() -> void:
	if not Global.NO_INTRO:
		yield(timer(4.5), "timeout")
		player.visible = true
		yield(timer(4.5), "timeout")
		player.unfreeze()

func _on_ditch_door_select() -> void:
	move_with_fade(player, maintenance_room_spawn.position, door_open_sound)

func _on_maintenance_room_door_select() -> void:
	move_with_fade(player, ditch_spawn.position, door_open_sound)

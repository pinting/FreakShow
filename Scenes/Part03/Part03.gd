extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part04.tscn"

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var ditch_door = $Environment/Ditch/Wall/Door01
onready var maintenance_room_door = $Environment/MaintenanceRoom/Door00

onready var top_spawn = $Trigger/TopSpawn
onready var ditch_spawn = $Trigger/DitchSpawn
onready var maintenance_room_spawn = $Trigger/MaintenanceRoomSpawn

onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

var music_00: int
var music_01: int

func _ready():
	music_00 = music_mixer.add_part(3, 3 * 60, false, 5, 1, 0)
	music_01 = music_mixer.add_part(3 * 60, 4 * 60, true, 0.5, 0.5, -1)
	
	ditch_door.connect("selected", self, "_on_ditch_door_select")
	maintenance_room_door.connect("selected", self, "_on_maintenance_room_door_select")
	connect("scene_started", self, "_on_scene_started")
	
	music_mixer.play()
	
	if not Global.NO_INTRO:
		player.freeze(true)
		player.global_position = top_spawn.global_position

func _on_scene_started():
	if not Global.NO_INTRO:
		yield(timer(9.0), "timeout")
		player.unfreeze()

func _on_ditch_door_select():
	move_with_fade(player, maintenance_room_spawn.position, door_open_sound)

func _on_maintenance_room_door_select():
	move_with_fade(player, ditch_spawn.position, door_open_sound)

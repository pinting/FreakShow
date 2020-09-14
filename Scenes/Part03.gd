extends "res://Scenes/BaseScene.gd"

# Next scene
export var next_scene: String = "res://Scenes/Part01.tscn"

# Help player after this amount of loops into one direction
export var help_after_index: int = 2

onready var player = $Player
onready var music_mixer = $MusicMixer

onready var ditch_door = $Environment/Ditch/Wall/Door01
onready var maintenance_room_door = $Environment/MaintenanceRoom/Door00

onready var ditch_spawn = $Trigger/DitchSpawn
onready var maintenance_room_spawn = $Trigger/MaintenanceRoomSpawn

onready var door_open_sound = $Sound/DoorOpenSound
onready var silent_door_open_sound = $Sound/SilentDoorOpenSound

func _ready():
	ditch_door.connect("selected", self, "_on_ditch_door_select")
	maintenance_room_door.connect("selected", self, "_on_maintenance_room_door_select")
	connect("scene_started", self, "_on_scene_started")

func _open_door(next_position):
	door_open_sound.play()
	fade_out(1.0)
	yield(timer(1.5), "timeout")
	player.position = next_position
	fade_in(1.0)

func _on_scene_started():
	yield(timer(1.5), "timeout")
	Global.subtitle.say(tr("NARRATOR06"))

func _on_ditch_door_select():
	_open_door(maintenance_room_spawn.position)

func _on_maintenance_room_door_select():
	_open_door(ditch_spawn.position)

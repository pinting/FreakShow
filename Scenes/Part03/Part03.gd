extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Part04/Part04.tscn"
export var disable_movement_delay: bool = false
export var player_animation_frames_flash: SpriteFrames

onready var player = $Player
onready var camera = $Player/GameCamera
onready var screen_effect = $ScreenEffect/ColorRect

onready var keypad = $Environment/Ditch/Wall/Door00/Keypad
onready var ditch_door = $Environment/Ditch/Wall/Door01
onready var maintenance_room_door = $Environment/MaintenanceRoom/Door00
onready var empty_battery_station = $Environment/MaintenanceRoom/EmptyBatteryStation
onready var train_platform = $Environment/MaintenanceRoom/Platform
onready var hide_papers = $Environment/MaintenanceRoom/Wall/HidePapers
onready var paper_with_code = $Environment/MaintenanceRoom/Wall/HidePapers/PaperWithCode

onready var ditch_spawn = $Trigger/DitchSpawn
onready var maintenance_room_spawn = $Trigger/MaintenanceRoomSpawn
onready var next_level_trigger = $Trigger/NextLevelTrigger

onready var main_music = $Sound/MainMusic
onready var next_level_music = $Sound/NextLevelMusic
onready var door_open_sound = $Sound/DoorOpenSound

var player_animation_frames_base: SpriteFrames
var ending_open: bool = false
var code_help_said: bool = false
var ending_triggered: bool = false
var enable_next_level_effect: bool = false
var next_level_effect_state: bool = false
var next_level_effect_counter: float = 0.0
var next_level_effect_interval: float = 1.0
var next_level_effect_barrel_power: float = 1.0
var next_level_effect_color_bleeding: float = 1.0

var music_00: int
var music_01: int
var music_02: int

func _ready() -> void:
	# There is a small glitch between 1:13 and 1:14 in the track
	music_00 = main_music.add_part(5, 60 + 13, false, 5, 0.1, 0)
	music_01 = main_music.add_part(60 + 14, 3 * 60, false, 0.1, 1, -0.2)
	music_02 = main_music.add_part(3 * 60, 4 * 60, true, 0.5, 0.5, -1)
	
	next_level_music.add_part(7 * 60 + 5, 8 * 60, true, 5, 2, 0)
	
	player_animation_frames_base = player.animation_frames
	
	connect("scene_started", self, "_on_scene_started")
	ditch_door.connect("selected", self, "_on_ditch_door_select")
	maintenance_room_door.connect("selected", self, "_on_maintenance_room_door_select")
	empty_battery_station.connect("battery_inside", self, "_on_battery_in_place")
	paper_with_code.connect("selected", self, "_unlock_ending")
	keypad.connect("selected", self, "_keypad_selected")
	
	main_music.play()
	
	if not disable_movement_delay:
		camera.smoothing_enabled = true
		player.visible = false
		
		player.freeze(true)
	
	_hide_papers_visibility(false)

func _keypad_selected() -> void:
	if not ending_open:
		if not code_help_said:
			Game.subtitle.say(tr("NARRATOR07"))
			code_help_said = true
		
		return
	
	if ending_triggered:
		return
	
	ending_triggered = true
	
	next_level_music.play()
	
	Game.disable_selectable = true
	enable_next_level_effect = true
	
	yield(timer(5.0), "timeout")
	
	main_music.kill(2.0)
	next_level_music.kill(2.0)
	
	fade_out(2.0)
	yield(timer(2.0), "timeout")
	
	Game.disable_selectable = false
	load_scene(next_scene)

func _process_next_level_effect(delta: float) -> void:
	if not enable_next_level_effect:
		return
	
	next_level_effect_counter += delta
	
	if next_level_effect_counter > next_level_effect_interval:
		camera.shake = pow(2.0 * abs(sin(current_second)) + 1.0, Game.random_generator.randf_range(1.0, 2.0))
		
		screen_effect.modulate.a = min(1.0, screen_effect.modulate.a + delta)
		screen_effect.material.set_shader_param("barrel_power", min(2.2, next_level_effect_barrel_power + delta))
		screen_effect.material.set_shader_param("color_bleeding", min(2.4, next_level_effect_color_bleeding + delta))
		
		if next_level_effect_state:
			player.set_animation_frames(player_animation_frames_flash)
			next_level_effect_state = false
		else:
			player.set_animation_frames(player_animation_frames_base)
			next_level_effect_state = true
		
		next_level_effect_counter = 0.0
		next_level_effect_interval /= 1.5

func _process(delta: float) -> void:
	if Game.loader:
		return
	
	_process_next_level_effect(delta)

func _hide_papers_visibility(visible: bool) -> void:
	for node in hide_papers.get_children():
		node.visible = visible

func _on_scene_started() -> void:
	if not disable_movement_delay:
		yield(timer(4.5), "timeout")
		Game.subtitle.say(tr("NARRATOR06"))
		
		player.visible = true
		
		yield(timer(3.5), "timeout")
		
		for n in range(4):
			camera.smoothing_speed += 0.5
			yield(timer(0.5), "timeout")
		
		camera.smoothing_enabled = false
		
		player.unfreeze()

func _on_ditch_door_select() -> void:
	move_with_fade(player, maintenance_room_spawn.position, door_open_sound)

func _on_maintenance_room_door_select() -> void:
	move_with_fade(player, ditch_spawn.position, door_open_sound)

func _on_battery_in_place() -> void:
	_hide_papers_visibility(true)
	train_platform.open()

func _unlock_ending() -> void:
	Game.subtitle.say(tr("NARRATOR08"))

	ending_open = true

extends BaseScene

export var next_scene: String = "res://Scenes/Part05/Part05.tscn"
export var tick_length_min: float = 10.0
export var tick_length_max: float = 15.0
export var number_of_pillars: int = 30
export var width_between_pillars: float = 3000
export var pillar_high_offset: float = -370
export var pillar_low_offset: float = 335
export var teleport_player_to_end: bool = false

onready var player = $Player
onready var camera = $Player/DefaultCamera

onready var club = $Dynamic/Environment/BuildingEnd/Dirt/Road/Club

onready var dynamic = $Dynamic
onready var game_end = $Dynamic/Trigger/GameEnd
onready var fall_to_died = $Dynamic/Trigger/FallToDeath
onready var train_spawn = $Trigger/TrainSpawn
onready var pillar_spawn = $Trigger/PillarSpawn
onready var teleport_player = $Dynamic/Trigger/TeleportPlayer
onready var player_respawn = $Trigger/PlayerRespawn

onready var main_music = $Sound/MainMusic
onready var door_sound = $Sound/DoorSound

const train_scene = preload("res://Objects/Train.tscn")
const pillar_scene = preload("res://Scenes/Part04/Part04_DoublePillar.tscn")

var first_on_top_called: bool = false
var wait_time: float = INF
var reached_end: bool = false
var counter: float = 0.0

var music_00
var music_01
var music_02
var music_03

func _ready() -> void:
	dynamic.position.x += width_between_pillars * (number_of_pillars + 1)
	
	music_00 = main_music.add_part(0, 19.3, true, 2, 2, -5)
	music_01 = main_music.add_part(42, 5 * 38, true, 0, 0, 0)
	music_02 = main_music.add_part(30.8, 41.9, false, 0, 2, 0)
	music_03 = main_music.add_part(0, 19.3, true, 2, 2, -5)
	
	fall_to_died.connect("body_entered", self, "_kill_player")
	player.connect("died", self, "_on_player_die")
	game_end.connect("body_entered", self, "_on_player_reach_game_end")
	club.connect("door_selected", self, "_on_exit_selected")
	connect("scene_started", self, "_on_scene_started")
	
	main_music.play()

func _generate_pillars():
	var pillars_y = []
	var zero_count = Global.random_generator.randi_range(1, 3)
	
	for i in range(number_of_pillars):
		if zero_count == 0:
			pillars_y.push_back(-1 if Global.random_generator.randi_range(0, 1) else 1)
			zero_count = Global.random_generator.randi_range(0, 2)
		else:
			pillars_y.push_back(0)
			zero_count -= 1
	
	var end_zero_count = Global.random_generator.randi_range(0, 2)
	
	if number_of_pillars >= end_zero_count:
		for n in range(end_zero_count):
			pillars_y[number_of_pillars - (1 + n)] = 0
	
	return pillars_y

func _create_pillars(pillars_y: Array) -> void:
	for child in pillar_spawn.get_children():
		pillar_spawn.remove_child(child)
		child.queue_free()
	
	var pillar
	
	for i in range(number_of_pillars):
		pillar = pillar_scene.instance()
		
		var x_offset = i * width_between_pillars
		var y_offset = 0
		
		if pillars_y and len(pillars_y) > i:
			if pillars_y[i] == -1:
				y_offset = pillar_low_offset
			elif pillars_y[i] == 1:
				y_offset = pillar_high_offset
		
		var offset = Vector2(x_offset, y_offset)
		
		pillar.position = offset
		pillar.z_index = pillar_spawn.z_index
		
		pillar_spawn.add_child(pillar)

func _kill_player(player: Node) -> void:
	if not player.is_in_group("player"):
		return
	
	player.kill()

func _on_scene_started() -> void:
	_create_pillars(_generate_pillars())
	
	if teleport_player_to_end:
		player.global_position = teleport_player.global_position
	else:
		_create_train()

func _on_player_on_train_top() -> void:
	if first_on_top_called:
		return
	
	main_music.force_next(music_01)
	camera.zoom_action()
	Global.subtitle.say(tr("NARRATOR08"))
	
	first_on_top_called = true

func _on_player_reach_game_end(player: Node) -> void:
	if not player.is_in_group("player") or reached_end:
		return
	
	main_music.force_next(music_02)
	camera.zoom_base()
	
	reached_end = true

func _clean_trains():
	var trains = get_tree().get_nodes_in_group("train")
	
	for train in trains:
		train.stop()
		remove_child(train)
		train.queue_free()

func _on_exit_selected() -> void:
	door_sound.play()
	main_music.kill(2.0)
	
	fade_out(0.5)
	yield(timer(0.5), "timeout")
	
	club.bass_sound.volume_db = 10
	yield(timer(1.0), "timeout")
	
	_clean_trains()
	yield(timer(0.5), "timeout")
	
	load_scene(next_scene)

func _on_player_die() -> void:
	yield(timer(2.0), "timeout")
	
	main_music.force_next(music_00)
	move_with_fade(player, player_respawn.global_position)
	
	first_on_top_called = false

func _create_train() -> void:
	var new_train = train_scene.instance()
	
	new_train.z_index = train_spawn.z_index
	new_train.position = train_spawn.position
	new_train.collision_layer = 8
	new_train.collision_mask = 8
	
	new_train.connect("player_on_top", self, "_on_player_on_train_top")
	
	add_child(new_train)
	new_train.start()
	
	wait_time = Global.random_generator.randf_range(tick_length_min, tick_length_max)
	counter = 0.0

func _process(delta: float) -> void:
	if first_on_top_called or reached_end or player.dead or Global.loader:
		return
	
	counter += delta
	
	if counter >= wait_time:
		_create_train()

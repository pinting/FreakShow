extends BaseScene

export var next_scene: String = "res://Scenes/Part04.tscn"
export var tick_length_min: float = 10.0
export var tick_length_max: float = 15.0
export var number_of_pillars: int = 20
export var width_between_pillars: float = 3000
export var pillar_high_offset: float = -370
export var pillar_low_offset: float = 335

onready var player = $Player

onready var fall_to_death = $Trigger/FallToDeath
onready var train_spawn = $Trigger/TrainSpawn
onready var pillar_spawn = $Trigger/PillarSpawn

onready var main_music = $Sound/MainMusic

const train_scene = preload("res://Objects/Train.tscn")
const pillar_scene = preload("res://Scenes/Part04/Part04_DoublePillar.tscn")

var music_switched_to_action: bool = false
var wait_time: float = 0.0
var counter: float = 0.0

var music_00
var music_01

func _ready() -> void:
	music_00 = main_music.add_part(0, 19.3, true, 2, 2, -5)
	music_01 = main_music.add_part(42, 5 * 38, true, 0, 0, 0)
	
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
	
	create_pillars(pillars_y)
	
	fall_to_death.connect("body_entered", self, "_kill_player")
	player.connect("death", self, "_on_player_die")
	connect("scene_started", self, "_on_scene_started")
	
	_generate_wait_time()
	
	main_music.play()

func create_pillars(pillars_y: Array) -> void:
	for child in pillar_spawn.get_children():
		pillar_spawn.remove_child(child)
		child.queue_free()
	
	for i in range(number_of_pillars):
		var pillar = pillar_scene.instance()
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

func _kill_player(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	body.kill()

func _on_scene_started() -> void:
	_generate_train()

func _on_body_on_top() -> void:
	if music_switched_to_action:
		return
	
	main_music.force_next(music_01)
	
	var camera = Global.current_camera
	
	if camera:
		camera.zoom_action()
	
	music_switched_to_action = true

func _on_player_die() -> void:
	fade_out(3.0)
	yield(timer(3.0), "timeout")
	load_scene(get_parent().filename)

func _generate_wait_time() -> void:
	wait_time = Global.random_generator.randf_range(tick_length_min, tick_length_max)

func _remove_train(train: Train) -> void:
	remove_child(train)
	train.queue_free()

func _generate_train() -> void:
	_generate_wait_time()
	
	var new_train = train_scene.instance()
	
	new_train.z_index = train_spawn.z_index
	new_train.position = train_spawn.position
	new_train.collision_layer = 8
	new_train.collision_mask = 8
	
	new_train.connect("stopped", self, "_remove_train", [new_train])
	new_train.connect("body_on_top", self, "_on_body_on_top")
	
	add_child(new_train)
	new_train.start()
	
	counter = 0.0

func _process(delta: float) -> void:
	counter += delta
	
	if counter >= wait_time:
		_generate_train()

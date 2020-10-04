extends BaseScene

export var tick_length_min: float = 7.5
export var tick_length_max: float = 15.0

# Next scene
export var next_scene: String = "res://Scenes/Part04.tscn"

onready var player = $Player

onready var train = $Environment/Train

onready var fall_to_death = $Trigger/FallToDeath

onready var main_music = $Sound/MainMusic

const train_scene = preload("res://Objects/Train.tscn")

var wait_time: float = 0.0
var counter: float = 0.0

var music_00

func _ready() -> void:
	music_00 = main_music.add_part(0, 3 * 60, true, 0, 5, -40)
	
	fall_to_death.connect("body_entered", self, "_fail_game")
	connect("scene_started", self, "_on_scene_started")
	
	_generate_wait_time()
	
	main_music.play()

func _on_scene_started() -> void:
	_generate_train()

func _fail_game(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	if player.dead:
		return
	
	player.kill()
	
	fade_out(1.0)
	yield(timer(1.0), "timeout")
	
	load_scene(get_parent().filename)

func _generate_wait_time() -> void:
	wait_time = Global.random_generator.randf_range(tick_length_min, tick_length_max)

func _remove_train(train: Train) -> void:
	remove_child(train)
	train.queue_free()

func _generate_train() -> void:
	_generate_wait_time()
	
	var new_train = train_scene.instance()
	
	new_train.z_index = train.z_index
	new_train.position = train.position
	new_train.collision_layer = 8
	new_train.collision_mask = 8
	
	new_train.connect("stopped", self, "_remove_train", [new_train])
	
	add_child(new_train)
	new_train.start()
	
	counter = 0.0

func _process(delta: float) -> void:
	counter += delta
	
	if counter >= wait_time:
		_generate_train()

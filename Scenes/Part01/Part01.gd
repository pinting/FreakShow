extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Part02/Part02.tscn"
export var low_pitch_intro_length: float = 10.0
export var ball_is_stuck_timeout: float = 6.0
export var teleport_player_to_end: bool = false
export var zero: float = 0.05

onready var player = $Player

onready var background_train = $Environment/BackgroundTrain
onready var road_block_collision = $Environment/RoadBlock/CollisionShape2D
onready var road_block_sprite = $Environment/RoadBlock/Sprite
onready var phone_lamp = $Environment/PhoneBox/Lamp
onready var phone = $Environment/PhoneBox/Phone
onready var crate = $Environment/Crate
onready var ball = $Environment/Ball

onready var trigger_comment = $Trigger/TriggerComment
onready var trigger_train = $Trigger/TriggerTrain
onready var reaching_phone_box = $Trigger/ReachingPhoneBox
onready var reaching_hoop = $Trigger/ReachingHoop
onready var inside_hoop = $Trigger/InsideHoop
onready var teleport_player = $Trigger/TeleportPlayer

onready var main_music = $Sound/MainMusic

onready var wind_sound = $Sound/WindSound
onready var ring_sound = $Sound/RingSound
onready var pick_up_sound = $Sound/PickUpSound

var music_00: int
var music_01: int
var music_02: int

var flashing_phone_light: bool = false
var phone_selected: bool = false

func _ready() -> void:
	music_00 = main_music.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = main_music.add_part(5 * 60 + 36, 7 * 60 + 27, true, 10, 10, -40)
	music_02 = main_music.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -40)
	
	connect("scene_started", self, "_on_scene_started")
	connect("intro_over", self, "_on_intro_over")
	
	trigger_comment.connect("body_entered", self, "_trigger_comment")
	trigger_train.connect("body_entered", self, "_trigger_train")
	reaching_hoop.connect("body_entered", self, "_trigger_hoop_part")
	inside_hoop.connect("body_entered", self, "_trigger_in_hoop")
	reaching_phone_box.connect("body_entered", self, "_reaching_phone_box")
	
	main_music.master_player.pitch_scale = 0.001
	wind_sound.pitch_scale = 0.001
	
	wind_sound.play()
	
	if teleport_player_to_end:
		player.position = teleport_player.position
	
	road_block_collision.disabled = true
	road_block_sprite.visible = false

func _on_intro_over() -> void:
	main_music.play()

func _on_scene_started() -> void:
	Global.subtitle.say(tr("NARRATOR02"), 6.0)

func _on_phone_selected() -> void:
	if phone_selected:
		return
	
	flashing_phone_light = false
	phone_selected = true
	
	main_music.kill(2.0);
	fade_out(2.0)
	
	yield(timer(3.0), "timeout")
	ring_sound.stop()
	
	yield(timer(0.5), "timeout")
	pick_up_sound.play()
	
	yield(timer(2.0), "timeout")
	load_scene(next_scene)

func _trigger_comment(player: Node) -> void:
	if not player.is_in_group("player") or not trigger_comment.visible:
		return
	
	trigger_comment.visible = false
	
	Global.subtitle.say(tr("NARRATOR03"), 6)

func _trigger_train(player: Node) -> void:
	if not player.is_in_group("player") or not trigger_train.visible:
		return
	
	trigger_train.visible = false
	background_train.start()

func _reaching_phone_box(player: Node) -> void:
	if not player.is_in_group("player") or road_block_sprite.visible:
		return
	
	road_block_collision.disabled = false
	road_block_sprite.visible = true

func _trigger_hoop_part(player: Node) -> void:
	if not player.is_in_group("player") or not reaching_hoop.visible:
		return

	reaching_hoop.visible = false
	main_music.force_next(music_01)

func _trigger_in_hoop(player: Node) -> void:
	if not player.is_in_group("ball") or not inside_hoop.visible:
		return
	
	yield(timer(ball_is_stuck_timeout), "timeout")
	
	while ball.held:
		yield(timer(ball_is_stuck_timeout), "timeout")
	
	if not inside_hoop.overlaps_body(player):
		return
	
	# Turn off previous trigger point too
	reaching_hoop.visible = false
	inside_hoop.visible = false
	
	ball.disable()
	ring_sound.play()
	main_music.force_next(music_02)
	
	phone.connect("selected", self, "_on_phone_selected")
	phone.visible = true
	phone_lamp.visible = true
	flashing_phone_light = true
	
	ball.global_position = inside_hoop.global_position
	ball.mode = RigidBody2D.MODE_STATIC

func _process_wind_intro(_delta: float) -> void:
	if Global.NO_INTRO:
		return
	
	# Make vinyl sound effect
	var pitch_value = current_second / low_pitch_intro_length
	
	if pitch_value >= 1.0:
		wind_sound.pitch_scale = 1.0
		main_music.master_player.pitch_scale = 1.0
	else:
		wind_sound.pitch_scale = max(min(pitch_value, 1.0), 0.001)
		main_music.master_player.pitch_scale = max(min(pitch_value, 1.0), 0.001)

func _process_phone_lamp_flash(delta: float) -> void:
	if flashing_phone_light and fmod(current_second, randf()) <= zero:
		phone_lamp.visible = not phone_lamp.visible

func _process(delta: float) -> void:
	_process_wind_intro(delta)
	_process_phone_lamp_flash(delta)

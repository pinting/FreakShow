extends "res://Game/BaseScene.gd"

export var teleport_player_to_end: bool = false

const ball_reposition_delay: float = 5.0
const ball_reposition_y_offset: float = 3000.0

onready var player: Player = $Player
onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var train: StaticBody2D = $Environment/Train
onready var road_block: StaticBody2D = $Environment/RoadBlock
onready var phone_box: Sprite = $Environment/PhoneBox
onready var hoop: Node2D = $Environment/Hoop
onready var ball: RigidBody2D = $Environment/Ball

onready var trigger_comment: Area2D = $Trigger/TriggerComment
onready var trigger_train: Area2D = $Trigger/TriggerTrain
onready var reaching_phone_box: Area2D = $Trigger/ReachingPhoneBox
onready var reaching_hoop: Area2D = $Trigger/ReachingHoop
onready var ball_area: Area2D = $Trigger/BallArea
onready var teleport_player: Node2D = $Trigger/TeleportPlayer

onready var main_music: MusicMixer = $Sound/MainMusic
onready var door_sound: AudioStreamPlayer = $Sound/DoorSound
onready var wind_sound: AudioStreamPlayer = $Sound/WindSound
onready var ring_sound: AudioStreamPlayer2D = $Sound/RingSound
onready var pick_up_sound: AudioStreamPlayer2D = $Sound/PickUpSound

var music_00: int
var music_01: int
var music_02: int

var ball_reposition_sleep: float = ball_reposition_delay

func _ready() -> void:
	music_00 = main_music.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = main_music.add_part(5 * 60 + 36, 7 * 60 + 27, true, 10, 10, -40)
	music_02 = main_music.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -40)
	
	connect("scene_started", self, "_on_scene_started")
	trigger_comment.connect("body_entered", self, "_trigger_comment", [], CONNECT_ONESHOT)
	trigger_train.connect("body_entered", self, "_trigger_train", [], CONNECT_ONESHOT)
	reaching_hoop.connect("body_entered", self, "_trigger_hoop_part", [], CONNECT_ONESHOT)
	reaching_phone_box.connect("body_entered", self, "_reaching_phone_box", [], CONNECT_ONESHOT)
	hoop.connect("ball_in_hoop", self, "_trigger_ball_in_hoop", [], CONNECT_ONESHOT)
	
	Tools.set_body_visibility(road_block, false)
	
	if teleport_player_to_end:
		move_player(player, teleport_player.position)

func _on_scene_started() -> void:
	SubtitleManager.say(Text.find("Narrator002"), 6.0, 12.0)
	yield(Tools.timer(4.0), "timeout")
	animation_player.play("pitch_effect")
	yield(Tools.timer(1.0), "timeout")
	wind_sound.play()
	main_music.play()
	black_screen.fade_out(5.0)

func _on_phone_selected() -> void:
	phone_box.flashing_phone_light = false

	main_music.kill(2.0);
	black_screen.fade_in(2.0)
	yield(Tools.timer(3.0), "timeout")

	ring_sound.stop()
	yield(Tools.timer(0.5), "timeout")

	pick_up_sound.play()
	yield(Tools.timer(2.0), "timeout")

	load_next_scene()

func _trigger_comment(_body: Node) -> void:
	SubtitleManager.say(Text.find("Narrator003"), 6.0)

func _trigger_train(_body: Node) -> void:
	train.start()

func _reaching_phone_box(_body: Node) -> void:
	Tools.set_body_visibility(road_block, true)

func _trigger_hoop_part(_body: Node) -> void:
	main_music.force_next(music_01)

func _trigger_ball_in_hoop() -> void:
	yield(Tools.timer(5.0), "timeout")

	ring_sound.play()

	phone_box.phone.visible = true
	phone_box.lamp.visible = true
	phone_box.flashing_phone_light = true
	
	phone_box.phone.connect("selected", self, "_on_phone_selected", [], CONNECT_ONESHOT)

func _process(delta: float) -> void:
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta

func _physics_process(_delta: float) -> void:
	if ball_reposition_sleep <= 0 and not ball_area.overlaps_body(ball):
		ball.reset(player.global_position + Vector2.UP * ball_reposition_y_offset)
		ball_reposition_sleep = ball_reposition_delay

extends "res://Game/BaseScene.gd"

export var teleport_player_to_end: bool = false

const ball_reposition_delay: float = 5.0
const ball_reposition_y_offset: float = 3000.0

onready var player: Player = $Player
onready var ball: Pickable = $Ball
onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var train: StaticBody2D = $Environment/Train
onready var loop: Loop = $Environment/Loop
onready var phone_box: Sprite = $Environment/PhoneBox
onready var hoop: Node2D = $Environment/Hoop

onready var trigger_comment: Area2D = $Trigger/TriggerComment
onready var trigger_train: Area2D = $Trigger/TriggerTrain
onready var reaching_loop_with_ball: Area2D = $Trigger/ReachingLoopWithBall
onready var reaching_hoop_with_ball: Area2D = $Trigger/ReachingHoopWithBall
onready var ball_area: Area2D = $Trigger/BallArea
onready var teleport_player: Node2D = $Trigger/TeleportPlayer

onready var main_music: MusicMixer = $Sound/MainMusic
onready var door_sound: AudioStreamPlayer = $Sound/DoorSound
onready var wind_sound: AudioStreamPlayer = $Sound/WindSound
onready var ring_sound: AudioStreamPlayer2D = $Sound/RingSound
onready var pick_up_sound: AudioStreamPlayer2D = $Sound/PickUpSound

var music_00: int
var music_01: int

var ball_reposition_sleep: float = ball_reposition_delay

func _ready() -> void:
	music_00 = main_music.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = main_music.add_part(5 * 60 + 36, 7 * 60 + 27, true, 5, 5, -10)
	
	connect("scene_started", self, "_on_scene_started")
	trigger_comment.connect("body_entered", self, "_trigger_comment", [], CONNECT_ONESHOT)
	ball.connect("picked", self, "_trigger_ball_picked", [], CONNECT_ONESHOT)
	trigger_train.connect("body_entered", self, "_trigger_train", [], CONNECT_ONESHOT)
	reaching_loop_with_ball.connect("body_entered", self, "_reaching_loop_with_ball", [], CONNECT_ONESHOT)
	reaching_hoop_with_ball.connect("body_entered", self, "_reaching_hoop_with_ball", [], CONNECT_ONESHOT)
	hoop.connect("ball_in_hoop", self, "_trigger_ball_in_hoop", [], CONNECT_ONESHOT)
	
	Tools.set_group_visibility("_right_side", false)
	
	if teleport_player_to_end:
		_trigger_ball_picked(ball)
		_reaching_loop_with_ball(ball)
		yield(move_player(player, teleport_player.position), "completed")
		_reset_ball()

func _on_scene_started() -> void:
	SubtitleManager.say(Text.find("Narrator002"), 6.0, 12.0)
	yield(Tools.timer(4.0), "timeout")
	animation_player.play("pitch_effect")
	yield(Tools.timer(1.0), "timeout")
	wind_sound.play()
	main_music.play()
	black_screen.fade_out(5.0)

func _trigger_comment(_body: Node) -> void:
	SubtitleManager.say(Text.find("Narrator003"), 6.0)

func _trigger_ball_picked(_ball: Pickable) -> void:
	ball.z_index = 0

func _trigger_train(_body: Node) -> void:
	train.start()

func _reaching_loop_with_ball(_body: Node) -> void:
	loop.loop_mode = "none"
	loop.mirror_mode = "none"
	loop.undo_mirror()
	Tools.set_group_visibility("_right_side", true)

func _reaching_hoop_with_ball(_body: Node) -> void:
	main_music.force_next(music_01)

func _trigger_ball_in_hoop() -> void:
	main_music.force_next(music_01)
	
	yield(Tools.timer(5.0), "timeout")

	ring_sound.play()

	phone_box.phone.visible = true
	phone_box.lamp.visible = true
	phone_box.flashing_phone_light = true
	
	phone_box.phone.connect("selected", self, "_on_phone_selected", [], CONNECT_ONESHOT)

func _on_phone_selected() -> void:
	phone_box.flashing_phone_light = false
	
	black_screen.fade_in(2.0)
	yield(Tools.timer(3.0), "timeout")

	ring_sound.stop()
	yield(Tools.timer(0.5), "timeout")

	pick_up_sound.play()
	yield(Tools.timer(2.0), "timeout")
	
	yield(SubtitleManager.say(Text.find("Narrator012"), 1.0, 2.0), "completed")
	yield(SubtitleManager.say(Text.find("Narrator013"), 1.0, 2.0), "completed")
	yield(SubtitleManager.say(Text.find("Narrator014"), 2.0, 3.0), "completed")
	yield(SubtitleManager.say(Text.find("Narrator015"), 2.0, 3.0), "completed")
	yield(SubtitleManager.say(Text.find("Narrator016"), 6.0, 10.0), "completed")

	main_music.kill(2.0)
	yield(Tools.timer(3.0), "timeout")
	
	load_next_scene()

func _process(delta: float) -> void:
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta

func _physics_process(_delta: float) -> void:
	if ball_reposition_sleep <= 0 and not ball_area.overlaps_body(ball):
		ball_reposition_sleep = ball_reposition_delay
		_reset_ball()

func _reset_ball() -> void:
	var new_position = player.global_position + Vector2.UP * ball_reposition_y_offset
	
	yield(ball.hide(), "completed")
	yield(ball.reset(new_position), "completed")
	ball.show()

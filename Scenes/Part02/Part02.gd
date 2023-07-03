extends "res://Game/BaseScene.gd"

@export var teleport_player_to_end: bool = false
@export var auto_trigger_phone_ringing: bool = false

const ball_reposition_delay: float = 5.0
const ball_reposition_y_offset: float = 3000.0

@onready var player: Player = $Player
@onready var ball: Pickable = $Ball

@onready var circle: Sprite2D = $Environment/Building01/Top/Bottom/RightBlock/Circle
@onready var train: StaticBody2D = $Environment/Train
@onready var loop: Loop = $Environment/Loop
@onready var phone_box: Sprite2D = $Environment/PhoneBox
@onready var hoop: Node2D = $Environment/Hoop

@onready var trigger_comment: Area2D = $Trigger/TriggerComment
@onready var trigger_train: Area2D = $Trigger/TriggerTrain
@onready var reaching_loop_with_ball: Area2D = $Trigger/ReachingLoopWithBall
@onready var reaching_hoop_with_ball: Area2D = $Trigger/ReachingHoopWithBall
@onready var ball_area: Area2D = $Trigger/BallArea
@onready var teleport_player: Node2D = $Trigger/TeleportPlayer

@onready var main_music: MusicMixer = $Sound/MainMusic
@onready var phone_music: MusicMixer = $Sound/PhoneMusic
@onready var wind_sound: AudioStreamPlayer = $Sound/WindSound
@onready var ring_sound: AudioStreamPlayer2D = $Sound/RingSound
@onready var pick_up_sound: AudioStreamPlayer2D = $Sound/PickUpSound

var music_00: int
var music_01: int

var phone_music_00: int
var phone_music_01: int

var ball_reposition_sleep: float = ball_reposition_delay

func _ready() -> void:
	super._ready()
	
	music_00 = main_music.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = main_music.add_part(5 * 60 + 36, 7 * 60 + 27, true, 5, 5, -10)
	
	phone_music_00 = phone_music.add_part(2 * 60 + 6, 2 * 60 + 59, true, 5, 5, -10)
	phone_music_01 = phone_music.add_part(4 * 60 + 36, 4 * 60 + 50, true, 1, 1, -5)
	
	connect("scene_started", Callable(self, "_on_scene_started"))
	trigger_comment.connect("body_entered", Callable(self, "_trigger_comment").bind(), CONNECT_ONE_SHOT)
	ball.connect("picked", Callable(self, "_trigger_ball_picked").bind(), CONNECT_ONE_SHOT)
	trigger_train.connect("body_entered", Callable(self, "_trigger_train").bind(), CONNECT_ONE_SHOT)
	loop.connect("looped", Callable(self, "_player_looped").bind(), CONNECT_ONE_SHOT)
	reaching_loop_with_ball.connect("body_entered", Callable(self, "_reaching_loop_with_ball").bind(), CONNECT_ONE_SHOT)
	reaching_hoop_with_ball.connect("body_entered", Callable(self, "_reaching_hoop_with_ball").bind(), CONNECT_ONE_SHOT)
	hoop.connect("ball_in_hoop", Callable(self, "_trigger_ball_in_hoop").bind(), CONNECT_ONE_SHOT)
	
	Tools.set_group_visibility("_right_side", false)
	
	if teleport_player_to_end:
		_trigger_ball_picked(ball)
		_reaching_loop_with_ball(ball)
		await move_player(player, teleport_player.position)
		_reset_ball()
	
	if auto_trigger_phone_ringing:
		_reaching_hoop_with_ball(ball)
		_trigger_ball_in_hoop()

func _on_scene_started() -> void:
	await Tools.wait(1.0)

	if not teleport_player_to_end:
		SubtitleManager.say(Text.find("Narrator002"), 6.0, 12.0)
		await Tools.wait(4.0)
	
	Tools.animate_pitch(main_music.master_player, 0.01, 1.0)
	Tools.animate_pitch(main_music.slave_player, 0.01, 1.0)
	Tools.animate_volume(wind_sound, Tools.SILENT, -8.0)
	
	wind_sound.play()
	main_music.play()
	black_screen.fade_out(5.0)

func _trigger_comment(_body: Node) -> void:
	SubtitleManager.say(Text.find("Narrator003"), 6.0)

func _trigger_ball_picked(_ball: Pickable) -> void:
	ball.z_index = 0

func _trigger_train(_body: Node) -> void:
	train.start()

func _player_looped(_direction: String) -> void:
	circle.visible = true

func _reaching_loop_with_ball(_body: Node) -> void:
	loop.loop_mode = "none"
	loop.mirror_mode = "none"
	loop.undo_mirror()
	Tools.set_group_visibility("_right_side", true)

func _reaching_hoop_with_ball(_body: Node) -> void:
	main_music.force_next(music_01)

func _trigger_ball_in_hoop() -> void:
	await Tools.wait(2.0)

	ring_sound.play()

	phone_box.phone.visible = true
	phone_box.lamp.visible = true
	phone_box.flashing_phone_light = true
	
	phone_box.phone.connect("selected", Callable(self, "_on_phone_selected").bind(), CONNECT_ONE_SHOT)

func _on_phone_selected() -> void:
	phone_box.flashing_phone_light = false
	
	main_music.kill(2.0)
	black_screen.fade_in(2.0)
	await Tools.wait(3.0)

	ring_sound.stop()
	await Tools.wait(0.5)

	pick_up_sound.play()
	await Tools.wait(3.0)
	
	load_next_scene()

func _process(delta: float) -> void:
	super._process(delta)
	
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta

func _physics_process(delta: float) -> void:
	if ball_reposition_sleep <= 0 and not ball.disabled and not ball_area.overlaps_body(ball):
		ball_reposition_sleep = ball_reposition_delay
		_reset_ball()

func _reset_ball() -> void:
	var new_position = player.global_position + Vector2.UP * ball_reposition_y_offset
	
	await ball.disappear()
	await ball.reset(new_position)
	ball.appear()

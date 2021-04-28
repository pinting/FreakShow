extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Part03/Part03.tscn"
export var low_pitch_intro_length: float = 10.0
export var teleport_player_to_end: bool = false
export var ball_reposition_delay: float = 5.0
export var ball_reposition_y_offset: float = 3000.0

onready var player = $Player

onready var train = $Environment/Train
onready var road_block = $Environment/RoadBlock
onready var phone_box = $Environment/PhoneBox
onready var crate = $Environment/Crate
onready var shed_door = $Environment/Shed/Door
onready var exhibition_door = $Environment/ExhibitionRoom/Door
onready var hoop = $Environment/Hoop
onready var ball = $Environment/Ball

onready var trigger_comment = $Trigger/TriggerComment
onready var trigger_train = $Trigger/TriggerTrain
onready var reaching_phone_box = $Trigger/ReachingPhoneBox
onready var reaching_hoop = $Trigger/ReachingHoop
onready var teleport_player = $Trigger/TeleportPlayer
onready var shed_spawn = $Trigger/ShedSpawn
onready var exhibition_spawn = $Trigger/ExhibitationSpawn
onready var ball_area = $Trigger/BallArea

onready var main_music = $Sound/MainMusic

onready var door_sound = $Sound/DoorSound
onready var wind_sound = $Sound/WindSound
onready var ring_sound = $Sound/RingSound
onready var pick_up_sound = $Sound/PickUpSound

var music_00: int
var music_01: int
var music_02: int

var phone_selected: bool = false
var ball_reposition_sleep: float = ball_reposition_delay

func _ready() -> void:
	music_00 = main_music.add_part(0, 3 * 60 + 20, true, 0, 10, -40)
	music_01 = main_music.add_part(5 * 60 + 36, 7 * 60 + 27, true, 10, 10, -40)
	music_02 = main_music.add_part(8 * 60 + 21, 9 * 60 + 56.5, true, 5, 5, -40)
	
	connect("scene_started", self, "_on_scene_started")
	trigger_comment.connect("body_entered", self, "_trigger_comment")
	trigger_train.connect("body_entered", self, "_trigger_train")
	reaching_hoop.connect("body_entered", self, "_trigger_hoop_part")
	reaching_phone_box.connect("body_entered", self, "_reaching_phone_box")
	shed_door.connect("selected", self, "_on_shed_door_selected")
	exhibition_door.connect("selected", self, "_on_exhibition_door_selected")
	hoop.connect("ball_in_hoop", self, "_trigger_ball_in_hoop")
	
	main_music.master_player.pitch_scale = 0.001
	wind_sound.pitch_scale = 0.001
	
	wind_sound.play()
	
	if teleport_player_to_end:
		player.position = teleport_player.position
	
	Tools.set_shapes_disabled(road_block, true)

	road_block.visible = false

func _on_scene_started() -> void:
	black_screen.fade_out(3.0)
	SubtitleManager.say(Text.find("Narrator002"), 6.0)
	main_music.play()

func _on_shed_door_selected() -> void:
	move_with_fade(player, exhibition_spawn.global_position, door_sound)

func _on_exhibition_door_selected() -> void:
	move_with_fade(player, shed_spawn.global_position, door_sound)

func _on_phone_selected() -> void:
	if phone_selected:
		return
	
	phone_box.flashing_phone_light = false
	phone_selected = true

	main_music.kill(2.0);
	black_screen.fade_in(2.0)
	yield(Game.timer(3.0), "timeout")

	ring_sound.stop()
	yield(Game.timer(0.5), "timeout")

	pick_up_sound.play()
	yield(Game.timer(2.0), "timeout")

	load_scene(next_scene, true)

func _trigger_comment(player: Node) -> void:
	if not player.is_in_group("player") or not trigger_comment.visible:
		return
	
	trigger_comment.visible = false
	SubtitleManager.say(Text.find("Narrator003"), 6)

func _trigger_train(player: Node) -> void:
	if not player.is_in_group("player") or not trigger_train.visible:
		return
	
	trigger_train.visible = false
	train.start()

func _reaching_phone_box(player: Node) -> void:
	if not player.is_in_group("player") or road_block.visible:
		return
	
	Tools.set_shapes_disabled(road_block, false)
	road_block.visible = true

func _trigger_hoop_part(ball: Node) -> void:
	if not ball.is_in_group("ball") or not reaching_hoop.visible:
		return

	reaching_hoop.visible = false
	main_music.force_next(music_01)

func _trigger_ball_in_hoop() -> void:
	yield(Game.timer(5.0), "timeout")
	ring_sound.play()
	phone_box.phone.connect("selected", self, "_on_phone_selected")
	phone_box.phone.visible = true
	phone_box.lamp.visible = true
	phone_box.flashing_phone_light = true

func _process_sound_effect(delta: float) -> void:
	var pitch_value = current_second / low_pitch_intro_length
	
	if pitch_value >= 1.0:
		wind_sound.pitch_scale = 1.0
		main_music.master_player.pitch_scale = 1.0
	else:
		wind_sound.pitch_scale = max(min(pitch_value, 1.0), 0.001)
		main_music.master_player.pitch_scale = max(min(pitch_value, 1.0), 0.001)

func _process_ball_reposition_sleep(delta: float) -> void:
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta

func _process(delta: float) -> void:
	_process_sound_effect(delta)
	_process_ball_reposition_sleep(delta)

func _physics_process(delta: float) -> void:
	if ball_reposition_sleep <= 0 and not ball_area.overlaps_body(ball):
		ball.reset(player.global_position + Vector2.UP * ball_reposition_y_offset)
		ball_reposition_sleep = ball_reposition_delay

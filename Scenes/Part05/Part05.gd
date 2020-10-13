extends "res://Scenes/BaseScene.gd"

export var next_scene: String = "res://Scenes/Credits.tscn"
export var player_sync_fix_max_diff: float = 10.0

onready var player_top = $PlayerTop
onready var player_bottom = $PlayerBottom
onready var camera = $DefaultCamera

onready var top_empty_battery_station = $Environment/Top/Inside/EmptyBatteryStation
onready var top_button = $Environment/Top/Inside/Button
onready var top_hand = $Environment/Top/Hand
onready var top_player_collision_right_shape = $Environment/Top/CollisionPlayer/Right
onready var top_button_light = $Environment/Top/Inside/Button/Light

onready var bottom_door = $Environment/Bottom/Door
onready var bottom_button = $Environment/Bottom/Inside/Button
onready var bottom_hand = $Environment/Bottom/Hand
onready var bottom_player_collision_left_shape = $Environment/Bottom/CollisionPlayer/Left
onready var bottom_button_light = $Environment/Bottom/Inside/Button/Light

onready var end_camera = $Environment/End/Camera
onready var end_animated_sprite = $Environment/End/AnimatedSprite
onready var end_fap_sound = $Environment/End/FapSound

onready var fall_to_death = $Trigger/FallToDeath

onready var main_music = $Sound/MainMusic
onready var not_close_enough_sound = $Sound/NotCloseEnoughSound

var battery_in_place = false
var game_over = false
var game_finished = false

var music_00
var music_01

func _ready() -> void:
	music_00 = main_music.add_part(0, 60 + 21, false, 0, 0.5, 0)
	music_01 = main_music.add_part(15, 60 + 21, true, 0.5, 0.5, -1)
	
	connect("scene_started", self, "_on_scene_started")
	top_empty_battery_station.connect("battery_inside", self, "_on_battery_inside")
	bottom_button.connect("selected", self, "_on_bottom_button_selected")
	top_button.connect("selected", self, "_on_top_button_selected")
	bottom_hand.connect("player_on_palm", self, "_player_on_palm")
	top_hand.connect("player_on_palm", self, "_player_on_palm")
	fall_to_death.connect("body_entered", self, "_on_fall_to_death")
	
	main_music.play()

func _player_on_palm(player: Player) -> void:
	if game_finished:
		return
	
	var mark_for_removal = []
	
	for index in len(Global.players):
		var other_player = Global.players[index]
		
		if player != other_player:
			mark_for_removal.push_front(index)
	
	for index in mark_for_removal:
		Global.players.remove(index)
	
	game_finished = true
	
	yield(timer(3.0), "timeout")
	fade_out(2.0)
	yield(timer(2.0), "timeout")
	
	end_animated_sprite.frames = player.animated_sprite.frames
	end_animated_sprite.playing = true 
	
	camera.current = false
	end_camera.current = true
	
	end_fap_sound.play()
	
	fade_in(5.0)
	yield(timer(10.0), "timeout")
	
	fade_out(5.0)
	main_music.kill(7.0)
	yield(timer(10.0), "timeout")
	
	load_scene(next_scene)

func _on_bottom_button_selected() -> void:
	if not battery_in_place:
		not_close_enough_sound.play()
		return
	
	if top_hand.open:
		top_hand.close()
	
	bottom_hand.open()

func _on_top_button_selected() -> void:
	if not battery_in_place:
		not_close_enough_sound.play()
		return
	
	if bottom_hand.open:
		bottom_hand.close()
	
	top_hand.open()

func _on_battery_inside() -> void:
	battery_in_place = true
	
	bottom_door.open()
	
	yield(timer(2.0), "timeout")
	
	camera.zoom_action()
	Global.subtitle.say(tr("NARRATOR11"))
	
	top_player_collision_right_shape.disabled = true
	bottom_player_collision_left_shape.disabled = true
	top_button_light.visible = true
	bottom_button_light.visible = true

func _on_scene_started() -> void:
	pass

func _on_fall_to_death(body: Node) -> void:
	if game_over:
		return
	
	# To remain safe, the remaing one player can still trigger a game over
	if game_finished and Global.players.find(body) == -1:
		body.get_parent().remove_child(body)
		body.queue_free()
		return
	
	game_over = true
	
	main_music.kill(2.0);
	fade_out(2.0)
	yield(timer(2.0), "timeout")
	
	load_scene(get_parent().filename)

func _process(delta):
	if game_finished or not player_top or not player_bottom:
		return
	
	var p1 = player_top.global_position
	var p2 = player_bottom.global_position
	
	var diff = abs(abs(p1.x) - abs(p2.x))
	
	if diff > player_sync_fix_max_diff:
		var avg = (abs(p1.x) + abs(p2.x)) / 2
		
		player_top.global_position.x = avg * (p1.x / abs(p1.x))
		player_bottom.global_position.x = avg * (p2.x / abs(p2.x))

extends CanvasLayer

export var flash_player_animation_frames: SpriteFrames

onready var canvas = $Canvas

var base_player_animation_frames: SpriteFrames

var enabled: bool = false
var player: Player = null

var player_flash_state: bool = false
var counter: float = 0.0
var interval: float = 1.0
var barrel_power: float = 1.0
var color_bleeding: float = 1.0
var current_second: float = 0.0

func _ready():
	pass

func _process(delta: float) -> void:
	if not enabled:
		return
	
	current_second += delta
	counter += delta
	
	var camera = Game.current_camera
	
	if counter > interval:
		if camera:
			camera.shake = pow(2.0 * abs(sin(current_second)) + 1.0, Game.random_generator.randf_range(1.0, 2.0))
		
		canvas.modulate.a = min(1.0, canvas.modulate.a + delta)
		canvas.material.set_shader_param("barrel_power", min(2.2, barrel_power + delta))
		canvas.material.set_shader_param("color_bleeding", min(2.4, color_bleeding + delta))
		
		if player:
			if player_flash_state:
				player.set_animation_frames(flash_player_animation_frames)
				player_flash_state = false
			else:
				player.set_animation_frames(base_player_animation_frames)
				player_flash_state = true
		
		counter = 0.0
		interval /= 1.5

func play(target_player: Player = null):
	if target_player:
		player = target_player
		base_player_animation_frames = target_player.animation_frames
	
	enabled = true

extends BaseScene

@onready var player: Player = $Player
@onready var camera: GameCamera = $GameCamera

@onready var exit_door: Selectable = $Environment/Building02/Block00/Door

@onready var main_music: MusicMixer = $Sound/MainMusic

var music_00: int
var music_01: int

func _ready() -> void:
	super._ready()
	
	music_00 = main_music.add_part(2 * 60 + 19, 6 * 60 + 20, false, 15, 5, 0)
	music_01 = main_music.add_part(4 * 60 + 42, 6 * 60 + 20, true, 5, 5, -10)
	
	connect("scene_started", Callable(self, "_on_scene_started").bind(), CONNECT_ONE_SHOT)
	camera.connect("target_reached", Callable(self, "_on_camera_reaches").bind(), CONNECT_ONE_SHOT)
	exit_door.connect("selected", Callable(self, "_on_exit_door_selected"))

func _on_scene_started() -> void:
	camera.disable_follow = true
	camera.follow_speed = camera.base_follow_speed / 2
	
	player.freeze(true)
	await Tools.wait(1.0)
	main_music.play()
	
	SubtitleManager.show_quote(Text.find("Text005"))
	await Tools.wait(25.0)
	
	camera.disable_follow = false
	
	black_screen.fade_out(10.0)
	await Tools.wait(5.0)
	SubtitleManager.hide_quote()
	await Tools.wait(7.0)
	SubtitleManager.say(Text.find("Narrator012"))

func _on_camera_reaches() -> void:
	camera.follow_speed = camera.base_follow_speed
	
	player.unfreeze()
	CursorManager.appear()
	CursorManager.move_to_center()
	SubtitleManager.say(Text.find("Narrator013"))

func _on_exit_door_selected() -> void:
	main_music.kill(3.0)
	await black_screen.fade_in(3.0)
	await Tools.wait(1.0)
	load_next_scene()

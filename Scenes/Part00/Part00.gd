extends BaseScene

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var exit_door: Selectable = $Environment/Building02/Block00/Door

onready var main_music: MusicMixer = $Sound/MainMusic

var music_00: int
var music_01: int

func _ready() -> void:
	music_00 = main_music.add_part(2 * 60 + 19, 6 * 60 + 20, false, 15, 5, 0)
	music_01 = main_music.add_part(4 * 60 + 42, 6 * 60 + 20, true, 5, 5, -10)
	
	connect("scene_started", self, "_on_scene_started", [], CONNECT_ONESHOT)
	camera.connect("target_reached", self, "_on_camera_reaches", [], CONNECT_ONESHOT)
	exit_door.connect("selected", self, "_on_exit_door_selected")

func _on_scene_started() -> void:
	camera.disable_follow = true
	camera.follow_speed = camera.base_follow_speed / 2
	
	player.freeze(true)
	yield(Tools.wait(1.0), "completed")
	main_music.play()
	
	SubtitleManager.show_quote(Text.find("Text005"))
	yield(Tools.wait(25.0), "completed")
	
	camera.disable_follow = false
	
	black_screen.fade_out(10.0)
	yield(Tools.wait(5.0), "completed")
	SubtitleManager.hide_quote()
	yield(Tools.wait(7.0), "completed")
	SubtitleManager.say(Text.find("Narrator012"))

func _on_camera_reaches() -> void:
	camera.follow_speed = camera.base_follow_speed
	
	player.unfreeze()
	CursorManager.show()
	CursorManager.move_to_center()
	SubtitleManager.say(Text.find("Narrator013"))

func _on_exit_door_selected() -> void:
	main_music.kill(3.0)
	yield(black_screen.fade_in(3.0), "completed")
	yield(Tools.wait(1.0), "completed")
	load_next_scene()

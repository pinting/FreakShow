extends BaseScene

onready var player: Player = $Player
onready var camera: GameCamera = $GameCamera

onready var exit_door: Selectable = $Environment/ExitDoor

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

	VirtualCursorManager.hide()
	player.freeze(true)
	yield(Tools.timer(1.0), "timeout")
	main_music.play()
	
	SubtitleManager.show_quote(Text.find("Text005"))
	yield(Tools.timer(25.0), "timeout")
	
	camera.disable_follow = false
	
	black_screen.fade_out(10.0)
	yield(Tools.timer(5.0), "timeout")
	SubtitleManager.hide_quote()
	yield(Tools.timer(7.0), "timeout")
	SubtitleManager.say(Text.find("Narrator012"))

func _on_camera_reaches() -> void:
	camera.follow_speed = camera.base_follow_speed
	
	player.unfreeze()
	VirtualCursorManager.show()
	VirtualCursorManager.move_to_center()
	SubtitleManager.say(Text.find("Narrator013"))

func _on_exit_door_selected() -> void:
	main_music.kill(3.0)
	yield(black_screen.fade_in(3.0), "tween_completed")
	yield(Tools.timer(1.0), "timeout")
	load_next_scene()

extends BaseScene

export var ball_reposition_delay: float = 5.0

onready var ball = $Environment/Ball
onready var lock_area = $Trigger/LockArea
onready var ball_area = $Trigger/BallArea

var ball_reposition_sleep: float = ball_reposition_delay

func _ready():
	lock_area.connect("body_entered", self, "_on_lock_area_touched")

func _process(delta: float) -> void:
	var is_accept = VirtualInput.is_action_just_pressed("ui_accept")
	
	if is_accept:
		if ball.selectable.visible:
			ball.hide()
		else:
			ball.show()

func _on_lock_area_touched(body) -> void:
	if not body.is_in_group("pickable"):
		return
	
	body.rotation_degrees = rotation_degrees - fmod(rotation_degrees, 90.0)
	body.global_position = lock_area.global_position
	
	body.disable()

func _physics_process(delta: float) -> void:
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta
	
	if ball_reposition_sleep <= 0 and not ball_area.overlaps_body(ball):
		_reset_ball()
		ball_reposition_sleep = ball_reposition_delay

func _reset_ball() -> void:
	yield(ball.hide(), "completed")
	yield(ball.reset(ball_area.global_position), "completed")
	ball.show()

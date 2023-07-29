extends BaseScene

const ball_reposition_delay: float = 5.0
const ball_reposition_y_offset: float = 3000.0

@onready var player: Player = $Player
@onready var ball: Pickable = $Ball

@onready var ball_area: Area2D = $Trigger/BallArea
@onready var lock_area: Area2D = $Trigger/LockArea

var ball_reposition_sleep: float = ball_reposition_delay

func _ready() -> void:
	super._ready()
	
	lock_area.connect("body_entered", _body_entered_lock_area)

func _process(delta: float) -> void:
	super._process(delta)
	
	var accept_pressed = VirtualInput.is_action_just_pressed("ui_accept")
	
	if accept_pressed:
		if ball.disabled:
			ball.enable()
			SubtitleManager.say("Ball enabled!")
		else:
			ball.disable()
			SubtitleManager.say("Ball disabled!")

func _body_entered_lock_area(body: PhysicsBody2D) -> void:
	if not body.is_in_group("pickable"):
		return
	
	var pickable: Pickable = body
	
	pickable.disable()

func _physics_process(delta: float) -> void:
	_process_missing_ball(delta)

func _process_missing_ball(delta: float) -> void:
	# Disable this for now
	return
	
	if ball_reposition_sleep > 0:
		ball_reposition_sleep -= delta
	elif not ball.disabled and not ball_area.overlaps_body(ball):
		ball_reposition_sleep = ball_reposition_delay
		_reset_ball()

func _reset_ball() -> void:
	var new_position = player.global_position + Vector2.UP * ball_reposition_y_offset
	
	await ball.disappear()
	await ball.reset(new_position)
	
	ball.appear()

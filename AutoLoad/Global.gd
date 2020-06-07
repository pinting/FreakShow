extends Node

# Resolution to reach (on large screens up-scale, on small screens down-scale)
const RESOLUTION = Vector2(1920, 1080)

# Default zoom for the non scaled resolution
const CAMERA_ZOOM = Vector2(2, 2)

# Enable debug messages
const DEBUG = true

# Disable sounds
const NO_SOUNDS = false

# Disable intro
const NO_INTRO = false

# Current camera object
var current_camera = null

# Position of the player
var player_position = Vector2(0, 0)

func debug(message):
	if DEBUG:
		print(message)

func debug_if_integer(t, message):
	if abs(floor(t) - t) < 0.05:
		debug(message)

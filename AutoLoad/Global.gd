extends Node

# Resolution to reach (on large screens up-scale, on small screens down-scale)
const RESOLUTION = Vector2(1920, 1080)

# Default zoom for the non scaled resolution
const CAMERA_ZOOM = Vector2(2, 2)

# Turn off sounds and intro screen
const DEBUG = true

# Current camera object
var current_camera = null

# Position of the player
var player_position = Vector2(0, 0)

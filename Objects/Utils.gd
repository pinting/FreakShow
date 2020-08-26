class_name Utils
extends Node2D

func _ready():
	pass

static func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	
	return q0.linear_interpolate(q1, t)

static func smooth_path(raw_path: PoolVector2Array, step: float = 10) -> PoolVector2Array:
	var raw_size = raw_path.size()
	
	if raw_size < 3:
		return raw_path
	
	var result = PoolVector2Array()
	var i = 0
	
	while i + 2 < raw_size:
		for t in range(step + 1):
			var v = _quadratic_bezier(raw_path[i], raw_path[i + 1], raw_path[i + 2], t / step)
			
			result.push_back(v)
		
		i += 2
	
	while i < raw_size:
		result.push_back(raw_path[i])
		i += 1
	
	return result

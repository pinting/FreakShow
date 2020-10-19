extends Node

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	
	return q0.linear_interpolate(q1, t)

func smooth_path(raw_path: PoolVector2Array, step: float = 10) -> PoolVector2Array:
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

func random_int(min_value: int, max_value: int, inclusive_range = false):
	if inclusive_range:
		max_value += 1
	
	var range_size = max_value - min_value
	
	randomize()
	
	return (randi() % range_size) + min_value

func random_bytes(n: int):
	var r = []
	
	for index in range(0, n):
		r.append(random_int(0, 256))
	
	return r

func uuid_bin():
	var b = random_bytes(16)
	
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	
	return b

func uuid():
	var b = uuid_bin()
	
	var l = "%02x%02x%02x%02x" % [b[0], b[1], b[2], b[3]]
	var m = "%02x%02x" % [b[4], b[5]]
	var h = "%02x%02x" % [b[6], b[7]]
	var c = "%02x%02x" % [b[8], b[9]]
	var n = "%02x%02x%02x%02x%02x%02x" % [b[10], b[11], b[12], b[13], b[14], b[15]]
	
	return "%s-%s-%s-%s-%s" % [l, m, h, c, n]

func set_shapes_disabled(body: CollisionObject2D, disabled: bool):
	for child in body.get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			child.disabled = disabled

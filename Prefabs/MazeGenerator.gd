class_name MazeGenerator
extends Object

var size = Vector2.ZERO
var links = {}
var visited = {}

func reset(new_size: Vector2):
	size = new_size
	links = {}
	visited = {}

func is_inside(p: Vector2) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y

func get_index(p: Vector2) -> String:
	assert(p >= Vector2.ZERO)
	
	return p.x + p.y * size.x

func get_link_key(a: Vector2, b: Vector2) -> String:
	var inside = is_inside(a) and is_inside(b)
	
	assert(inside, "Position is not inside")
	
	var d = a.distance_to(b)
	
	assert(d == 1.0, "Distance should not be greater than one")
	
	var a_index = get_index(a)
	var b_index = get_index(b)
	
	if a_index < b_index:
		return str(a_index, "-", b_index)
	else:
		return str(b_index, "-", a_index)

func get_link(a: Vector2, b: Vector2) -> bool:
	var key = get_link_key(a, b)
	
	if links.has(key):
		return links[key]
	
	return false

func set_link(a: Vector2, b: Vector2, value: bool) -> void:
	var key = get_link_key(a, b)
	
	links[key] = value

func set_visited(p: Vector2) -> void:
	visited[get_index(p)] = true

func is_visited(p: Vector2) -> bool:
	return visited.has(get_index(p))

func get_next(from: Vector2, direction: Vector2, not_visited: bool = true):
	assert(direction.distance_to(Vector2.ZERO) == 1.0, "Bad direction")
	
	var next = from + direction
	
	if is_inside(next):
		if not_visited and is_visited(next):
			return null
		
		return next
	
	return null

func get_random_next(from: Vector2, not_visited: bool = true):
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	
	randomize()
	directions.shuffle()
	
	var next = null
	
	while not next and len(directions) > 0:
		next = get_next(from, directions.pop_front(), not_visited)
	
	return next

func generate(entry: Vector2, exit: Vector2, iterations: int = 10) -> void:
	assert(is_inside(entry), "Entry is not inside")
	assert(is_inside(exit), "Exit is not inside")
	
	var primary_path = []
	var n = 0
	
	# Find the longest primary path
	while n < iterations:
		reset(size)
		
		var temp = []
		
		set_visited(entry)
		temp.push_back(entry)
		
		var prev = entry
		var next = get_random_next(entry)
		
		while(next and next != exit):
			set_visited(next)
			temp.push_back(next)
			
			prev = next
			next = get_random_next(prev)
		
		if next != exit:
			continue
		
		if len(primary_path) < len(temp):
			primary_path = temp
		
		n += 1
	
	var primary_path_len = len(primary_path)
	
	assert(primary_path_len >= 2, "Primary path cannot be shorther than 2")
	
	# Set primary path
	reset(size)
	
	for i in range(primary_path_len - 1):
		var a = primary_path[i]
		var b = primary_path[i + 1]
		
		set_link(a, b, true)
	
	for p in primary_path:
		set_visited(p)
	
	# Set random secondary path
	for p in primary_path:
		var a = p
		var b = get_random_next(a)
		
		while b:
			set_visited(b)
			set_link(a, b, true)
			
			a = b
			b = get_random_next(a)

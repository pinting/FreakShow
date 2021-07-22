extends TileMap

export var map_top_left: Vector2
export var map_bottom_right: Vector2
export var number_of_islands: Vector2

export var p_entry: Vector2
export var p_exit: Vector2

export var cell_step = Vector2(4, 4)
export var cell_v_offset = Vector2(2, 0)
export var cell_h_offset = Vector2(0, 2)

export var E00 = 19
export var L00 = 15
export var L01 = 17
export var L02 = 14
export var L03 = 16
export var H00 = 6
export var V00 = 11
export var T00 = 13
export var T01 = 18
export var T02 = 20
export var T03 = 21

func _ready() -> void:
	reset()

func reset() -> void:
	var generator = MazeGenerator.new()
	
	generator.reset(number_of_islands + Vector2.ONE)
	generator.generate(p_entry, p_exit)

	_clear(cell_step)
	_draw_islands(cell_v_offset + cell_h_offset, cell_step)
	_render(generator, cell_v_offset, cell_h_offset, cell_step)

func _clear(step: Vector2) -> void:
	var size = map_bottom_right - map_top_left
	var border_base = map_top_left - Vector2.ONE
	var size_with_border = size + step - Vector2.ONE
	var size_before_border = size_with_border - Vector2.ONE
	
	for y in range(size_with_border.y): 
		for x in range(size_with_border.x):
			var p = border_base + Vector2(x, y)
			var c = E00
			
			if x == 0.0 and y == 0.0:
				# TL
				c = L00
			elif x == size_before_border.x and y == 0.0:
				# TR
				c = L01
			elif x == 0.0 and y == size_before_border.y:
				# BL
				c = L02
			elif x == size_before_border.x and y == size_before_border.y:
				# BR
				c = L03
			elif y == 0.0 or y == size_before_border.y:
				# Horizontal
				c = H00
			elif x == 0.0 or x == size_before_border.x:
				# Vertical
				c = V00
			
			_custom_set_cell(p.x, p.y, c)
	
	var entry_cell = map_top_left + p_entry * step - Vector2(0, 1)
	
	_custom_set_cell(entry_cell.x - 1, entry_cell.y, L03)
	_custom_set_cell(entry_cell.x, entry_cell.y, E00)
	_custom_set_cell(entry_cell.x + 1, entry_cell.y, L02)
	
	var exit_cell = map_top_left + p_exit * step + Vector2(0, 1)
	
	_custom_set_cell(exit_cell.x - 1, exit_cell.y, L01)
	_custom_set_cell(exit_cell.x, exit_cell.y, E00)
	_custom_set_cell(exit_cell.x + 1, exit_cell.y, L00)

func _render(generator: MazeGenerator, v_offset: Vector2, h_offset: Vector2, step: Vector2) -> void:
	var p = map_top_left + v_offset
	
	for y in range(generator.size.y):
		p.x = map_top_left.x + v_offset.x
		
		for x in range(generator.size.x - 1):
			var from = Vector2(x, y)
			var to = Vector2(x + 1.0, y)
			
			if not generator.get_link(from, to):
				_draw_v_block(p.x, p.y)
			
			p.x += step.x
			
		p.y += step.y
		
	p = map_top_left + h_offset
	
	for y in range(generator.size.y - 1):
		p.x = map_top_left.x
		
		for x in range(generator.size.x):
			var from = Vector2(x, y)
			var to = Vector2(x, y + 1.0)
			
			if not generator.get_link(from, to):
				_draw_h_block(p.x, p.y)
			
			p.x += step.x
		
		p.y += step.y

func _draw_islands(offset: Vector2, step: Vector2) -> void:
	var size = number_of_islands
	var p = map_top_left + offset
	
	for _y in range(size.y):
		p.x = map_top_left.x + offset.x
		
		for _x in range(size.x):
			_draw_island_block(p.x, p.y)
			
			p.x += step.x
		
		p.y += step.y

func _draw_island_block(x: int, y: int) -> void:
	_custom_set_cell(x - 1, y - 1, L00)
	_custom_set_cell(x, y - 1, H00, true)
	_custom_set_cell(x + 1, y - 1, L01)
	_custom_set_cell(x - 1, y, V00, true)
	_custom_set_cell(x, y, -1)
	_custom_set_cell(x + 1, y, V00, true)
	_custom_set_cell(x - 1, y + 1, L02)
	_custom_set_cell(x, y + 1, H00, true)
	_custom_set_cell(x + 1, y + 1, L03)

func _draw_v_block(x: int, y: int) -> void:
	_custom_set_cell(x, y - 1, T02)
	_custom_set_cell(x, y, V00)
	_custom_set_cell(x, y + 1, T01)

func _draw_h_block(x: int, y: int) -> void:
	_custom_set_cell(x - 1, y, T00)
	_custom_set_cell(x, y, H00)
	_custom_set_cell(x + 1, y, T03)

func _custom_set_cell(x: int, y: int, tile: int, if_empty: bool = false) -> void:
	if if_empty and get_cell(x, y) != INVALID_CELL and get_cell(x, y) != E00:
		return
	
	set_cell(x, y, tile)

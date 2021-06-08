extends Node

signal player_added(player)

var players: Array = []

func register(player: Player) -> void:
	players.push_back(player)
	Tools.debug("Player registered")
	emit_signal("player_added", player)

func clear() -> void:
	for player in players:
		Tools.destroy(player)
	
	players = []

func get_each(key: String):
	var result = []
	
	for player in players:
		result.push_back(player.get(key))
	
	return result

func set_each(key: String, value) -> void:
	for player in players:
		player.set(key, value)

func call_each(key: String, parameters: Array = []) -> void:
	for player in players:
		player.callv(key, parameters)

func get_by_distance(position: Vector2, by_max: bool = true) -> Player:
	var current_best = 0
	var selected_player = null
	
	for player in players:
		var distance = player.global_position.distance_to(position)
		
		if (by_max and current_best < distance) or (not by_max and current_best > distance):
			current_best = distance
			selected_player = player
	
	return selected_player

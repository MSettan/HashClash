extends Node2D
var board_array: Array[Vector2i] = []

var map_resolution: int

signal tiles_type(data: Array[Vector2i], resolution: int)

const HEXES_SOURCE_ID = 0
const LAND_TILE = Vector2i(0, 0)
const BIG_ISLAND_MIN_SIZE = 20

var hexes: Dictionary = {}
var islands: Array = []
var little_islands: Array = []
var hex_to_island: Dictionary = {}

func _islands_finder() -> void:
	hexes.clear()
	islands.clear()
	little_islands.clear()
	hex_to_island.clear()

	var visited: Dictionary = {}

	for x in range(map_resolution):
		for y in range(map_resolution):
			var cell := Vector2i(x, y)
			if _is_land_cell(cell):
				hexes[cell] = true

	for cell_key in hexes.keys():
		var cell: Vector2i = cell_key
		if visited.has(cell):
			continue

		var found_island := _find_island_from_cell(cell, visited)
		if found_island.size() > BIG_ISLAND_MIN_SIZE:
			var big_island_index := islands.size()
			islands.append(found_island)
			_mark_hexes_island(found_island, big_island_index, false)
		else:
			var little_island_index := little_islands.size()
			little_islands.append(found_island)
			_mark_hexes_island(found_island, little_island_index, true)

	print("Islands found: ", islands.size(), " big, ", little_islands.size(), " small")

func _find_island_from_cell(start_cell: Vector2i, visited: Dictionary) -> Array[Vector2i]:
	var found_island: Array[Vector2i] = []
	var frontier: Array[Vector2i] = [start_cell]
	visited[start_cell] = true

	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		found_island.append(cell)

		for neighbor_cell in _get_hex_neighbors(cell):
			if visited.has(neighbor_cell) or not hexes.has(neighbor_cell):
				continue

			visited[neighbor_cell] = true
			frontier.append(neighbor_cell)

	return found_island

func _mark_hexes_island(found_island: Array[Vector2i], island_index: int, is_little: bool) -> void:
	for cell in found_island:
		hex_to_island[cell] = {
			"index": island_index,
			"is_little": is_little,
		}

func get_random_big_island_cell() -> Vector2i:
	if islands.is_empty():
		push_warning("No big islands found for pawn spawn.")
		return Vector2i(-1, -1)

	var random_island: Array = islands[randi() % islands.size()]
	if random_island.is_empty():
		push_warning("Selected big island has no cells.")
		return Vector2i(-1, -1)

	var random_cell: Vector2i = random_island[randi() % random_island.size()]
	return random_cell

func _is_land_cell(cell: Vector2i) -> bool:
	return _is_cell_inside_map(cell) and _get_board_tile(cell) == LAND_TILE

func _get_board_tile(cell: Vector2i) -> Vector2i:
	return board_array[_cell_index(cell)]

func _cell_index(cell: Vector2i) -> int:
	return cell.x * map_resolution + cell.y

func _get_hex_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var offsets := _get_hex_neighbor_offsets(cell)

	for offset in offsets:
		var neighbor_cell := cell + offset
		if _is_cell_inside_map(neighbor_cell):
			neighbors.append(neighbor_cell)

	return neighbors

func _get_hex_neighbor_offsets(cell: Vector2i) -> Array[Vector2i]:
	if cell.y % 2 == 0:
		return [
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(0, -1),
			Vector2i(-1, 0),
			Vector2i(-1, 1),
			Vector2i(-1, -1),
		]

	return [
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(1, -1),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

func _is_cell_inside_map(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_resolution and cell.y < map_resolution

#recive tileArrayFrom MapGenerator
func _on_map_generator_data_noise_to_tiles(data: Array[Vector2i], resolution: int) -> void:
	board_array = data
	map_resolution = resolution
	_board_builder()

func _board_builder():
	$TileBoard.clear()

	var array_increment: int = 0

	for x in range(map_resolution):
		for y in range(map_resolution):
			var tile_pos = Vector2i(x, y)
			$TileBoard.set_cell(tile_pos, HEXES_SOURCE_ID, board_array[array_increment])
			array_increment += 1
			
	_islands_finder()
	
	send_types_of_tiles()

func send_types_of_tiles():
	tiles_type.emit(board_array, map_resolution)

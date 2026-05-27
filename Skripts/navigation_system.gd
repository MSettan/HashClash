extends Node2D
class_name HexNavigationSystem

@onready var tile_board: TileMapLayer = $"../TileBoard"

var types_of_tiles: Array[Vector2i] = []
var map_resolution: int

var astar: AStar2D
var walkable_cells: Dictionary = {}

const GREY_TILE = Vector2i(0, 0)
func send_types_of_tiles():
	_resolve_tile_board()
	if tile_board == null:
		push_error("HexNavigationSystem cannot find ../TileBoard.")
		return

	astar = AStar2D.new()
	walkable_cells.clear()

	var array_increment: int = 0

	for x in range(map_resolution):
		for y in range(map_resolution):
			var cell := Vector2i(x, y)
			if types_of_tiles[array_increment] == GREY_TILE:
				walkable_cells[cell] = true
				astar.add_point(_cell_id(cell), tile_board.map_to_local(cell))
			array_increment += 1

	for cell_key in walkable_cells.keys():
		var cell: Vector2i = cell_key
		for neighbor_cell in _get_hex_neighbors(cell):
			if not walkable_cells.has(neighbor_cell):
				continue

			var point_id := _cell_id(cell)
			var neighbor_id := _cell_id(neighbor_cell)
			if not astar.are_points_connected(point_id, neighbor_id):
				astar.connect_points(point_id, neighbor_id)

	$"../../HUD/GridDisplay".setup(tile_board, walkable_cells, map_resolution)
	$"../../Pawn".setup(tile_board, self)

func _on_tile_map_plate_tiles_type(data: Array[Vector2i], resolution: int) -> void:
	types_of_tiles = data
	map_resolution = resolution
	send_types_of_tiles()

func is_cell_walkable(cell: Vector2i) -> bool:
	return walkable_cells.has(cell)

func get_path_between_cells(from_cell: Vector2i, to_cell: Vector2i) -> PackedVector2Array:
	if not is_cell_walkable(from_cell) or not is_cell_walkable(to_cell):
		return PackedVector2Array()

	return astar.get_point_path(_cell_id(from_cell), _cell_id(to_cell))

func get_path_cost(from_cell: Vector2i, to_cell: Vector2i) -> int:
	var path := get_path_between_cells(from_cell, to_cell)
	if path.size() == 0:
		return -1

	return path.size() - 1

func get_reachable_cells(from_cell: Vector2i, max_steps: int) -> Array[Vector2i]:
	var reachable: Array[Vector2i] = []
	if max_steps <= 0 or not is_cell_walkable(from_cell):
		return reachable

	var frontier: Array[Vector2i] = [from_cell]
	var distance_by_cell: Dictionary = {}
	distance_by_cell[from_cell] = 0

	while frontier.size() > 0:
		var cell: Vector2i = frontier.pop_front()
		var current_distance: int = distance_by_cell[cell]

		for neighbor_cell in _get_hex_neighbors(cell):
			if not is_cell_walkable(neighbor_cell) or distance_by_cell.has(neighbor_cell):
				continue

			var next_distance := current_distance + 1
			if next_distance > max_steps:
				continue

			distance_by_cell[neighbor_cell] = next_distance
			frontier.append(neighbor_cell)

			if neighbor_cell != from_cell:
				reachable.append(neighbor_cell)

	return reachable

func get_nearest_walkable_cell(cell: Vector2i) -> Vector2i:
	if is_cell_walkable(cell):
		return cell

	var best_cell := Vector2i.ZERO
	var best_distance: float = INF

	for walkable_cell_key in walkable_cells.keys():
		var walkable_cell: Vector2i = walkable_cell_key
		var distance := Vector2(cell).distance_squared_to(Vector2(walkable_cell))
		if distance < best_distance:
			best_distance = distance
			best_cell = walkable_cell

	return best_cell

func _cell_id(cell: Vector2i) -> int:
	return cell.x + cell.y * map_resolution

func _resolve_tile_board() -> void:
	if tile_board != null:
		return

	tile_board = get_node_or_null("../TileBoard") as TileMapLayer

func _get_hex_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_RIGHT_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_LEFT_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_SIDE))
	neighbors.append(tile_board.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE))
	return neighbors

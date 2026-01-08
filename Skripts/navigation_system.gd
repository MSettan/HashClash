extends Node2D

@onready var tile_board = $"../TileBoard"

var types_of_tiles: Array[Vector2i] = []
var map_resolution: int

var astar_grid: AStarGrid2D


func send_types_of_tiles():
	astar_grid = AStarGrid2D.new()
	astar_grid.cell_size = tile_board.tile_set.tile_size
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.region = Rect2(Vector2.ZERO, ceil(get_viewport_rect().size / astar_grid.cell_size))
	astar_grid.region = Rect2(0,0, map_resolution, map_resolution)
	astar_grid.update()
	
	var array_increment: int = 0

	for x in range (map_resolution):
		for y in range (map_resolution):
			
			if types_of_tiles[array_increment].y == 1:
				var solid_tile: Vector2i = Vector2i(x, types_of_tiles[array_increment].x)
				astar_grid.set_point_solid(solid_tile)
			array_increment += 1
			
	$"../../HUD/GridDisplay".grid = astar_grid
	$"../../Pawn".setup(astar_grid)
	

func _on_tile_map_plate_tiles_type(data: Array) -> void:
	types_of_tiles = data
	map_resolution = types_of_tiles[-1].x + 1
	send_types_of_tiles()

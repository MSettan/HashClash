extends Control

var tile_board: TileMapLayer
var walkable_cells: Dictionary = {}
var map_resolution := 0
var show_grid_display: bool:
	set(v): show_grid_display = v; queue_redraw()

func setup(_tile_board: TileMapLayer, _walkable_cells: Dictionary, _map_resolution: int) -> void:
	tile_board = _tile_board
	walkable_cells = _walkable_cells
	map_resolution = _map_resolution
	queue_redraw()

func  toggle_grid_display(on: bool):
		show_grid_display = on

func _draw():
	if tile_board == null or not show_grid_display:
		return

	for x in range(map_resolution):
		for y in range(map_resolution):
			var cell := Vector2i(x, y)
			var local_pos := tile_board.map_to_local(cell)
			var screen_pos := tile_board.to_global(local_pos)
			var col := Color(0, 1, 0, 0.3) if walkable_cells.has(cell) else Color(1, 0, 0, 0.3)
			draw_circle(screen_pos, 12.0, col)

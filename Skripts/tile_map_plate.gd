extends Node2D
var board_array: Array[Vector2i] = []

var map_resolution: int

signal tiles_type(data: Array[Vector2i], resolution: int)

const HEXES_SOURCE_ID = 0

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

	send_types_of_tiles()

func send_types_of_tiles():
	tiles_type.emit(board_array, map_resolution)

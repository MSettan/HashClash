extends Node2D
var board_array: Array[Vector2i] = []

var map_resolution: int

signal tiles_type(data: Array)

func _ready():
	_board_builder()
	await pog
	startup=false
	pass

func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	if startup:
		return startup
	if coord_list.has(coords):
		return true
	return false
	
func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:  
	tile_data.modulate =  Color(1,0,0,1)


signal pog
var startup = true
var new_color = str("ffffff")
var coord_list = [Vector2i(-1,-1)]

func _set_list(list):
	coord_list = list



#recive tileArrayFrom MapGenerator
func _on_map_generator_data_noise_to_tiles(data: Array) -> void:
	board_array = data
	map_resolution = board_array[-1].x + 1
	
func _board_builder():
	var array_increment: int = 0

	for x in range (map_resolution):
		for y in range (map_resolution):
			
			var tile_pos = Vector2i(x, y)

			$TileBoard.set_cell(tile_pos,0, Vector2i(0, board_array[array_increment].y))
			array_increment += 1
	
	_tile_data_runtime_update(0, Vector2i(0,0), $TileBoard.get_cell_tile_data(Vector2i(1,1)))
	print($TileBoard.get_cell_tile_data(Vector2i(1,1)))
	#$TileBoard.modulate = Color(0,1,1,1)
	
	send_types_of_tiles()
		
	
func send_types_of_tiles():
	tiles_type.emit(board_array)

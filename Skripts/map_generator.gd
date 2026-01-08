extends Node

var map_resolution = 32
var noise_scale = 0.1

signal data_noise_to_tiles(data: Array)

var noise_to_tiles: Array[Vector2i] = []

var water_threshold = 0.5

@onready var tilemap: TileMapLayer = $"../TileMapPlate/TileBoard"

func generate_map():
	var noise = FastNoiseLite.new()
	
	#change seed to random number
	noise.seed = randi()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	
	tilemap.clear()
	
	for x in range (map_resolution):
		for y in range (map_resolution):
			
			var noise_value = noise.get_noise_2d(x, y)
			var noise_value_threshold: Vector2i
			noise_value = (noise_value+1)/2
			
			#generate grass and water hexes with sourse 0.1 and 0.2
			if noise_value < water_threshold:
				noise_value_threshold = Vector2i(y, 0)
			else:
				noise_value_threshold = Vector2i(y, 1)
			noise_to_tiles.append(noise_value_threshold)
			
	#send to tileMapPlate
	send_array()
	
func _ready() -> void:
	generate_map()

func send_array():
	data_noise_to_tiles.emit(noise_to_tiles)

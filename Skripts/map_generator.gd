extends Node

@export var map_resolution: int = 32
@export var noise_scale: float = 0.1
@export_range(0.0, 1.0, 0.01) var water_threshold: float = 0.5

signal data_noise_to_tiles(data: Array[Vector2i], resolution: int)

var noise_to_tiles: Array[Vector2i] = []

const GREY_TILE = Vector2i(0, 0)
const BLUE_TILE = Vector2i(0, 1)

func generate_map():
	noise_to_tiles.clear()

	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale

	for x in range(map_resolution):
		for y in range(map_resolution):
			var noise_value := (noise.get_noise_2d(x, y) + 1.0) / 2.0

			if noise_value < water_threshold:
				noise_to_tiles.append(GREY_TILE)
			else:
				noise_to_tiles.append(BLUE_TILE)

	send_array()

func _ready() -> void:
	generate_map.call_deferred()

func send_array():
	data_noise_to_tiles.emit(noise_to_tiles, map_resolution)

func _on_button_regenerate_map_pressed() -> void:
	generate_map()

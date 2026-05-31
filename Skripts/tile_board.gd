extends TileMapLayer

@export var reachable_tile_lift: Vector2i = Vector2i(0, -4)
@export var reachable_tile_color: Color = Color(0.82, 1.0, 0.82, 1.0)
@export var reachable_hover_color: Color = Color(1.0, 0.58, 0.18, 1.0)
@export var blocked_hover_color: Color = Color(1.0, 0.22, 0.18, 1.0)
@export var base_texture_origin: Vector2i = Vector2i(0, 0)

const BLUE_TILE = Vector2i(0, 1)

var reachable_cells: Dictionary = {}
var cells_to_update: Dictionary = {}
var hovered_cell: Vector2i = Vector2i(-10, -10)

func set_reachable_cells(cells: Array[Vector2i]) -> void:
	cells_to_update.clear()
	_mark_reachable_cells_for_update()
	reachable_cells.clear()

	for cell in cells:
		reachable_cells[cell] = true
		cells_to_update[cell] = true

	cells_to_update[hovered_cell] = true
	notify_runtime_tile_data_update()
	update_internals()

func clear_reachable_cells() -> void:
	cells_to_update.clear()
	_mark_reachable_cells_for_update()
	cells_to_update[hovered_cell] = true
	reachable_cells.clear()
	notify_runtime_tile_data_update()
	update_internals()

func set_hovered_cell(cell: Vector2i) -> void:
	if cell == hovered_cell:
		return

	cells_to_update.clear()
	cells_to_update[hovered_cell] = true
	cells_to_update[cell] = true
	hovered_cell = cell
	notify_runtime_tile_data_update()
	update_internals()

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return reachable_cells.has(coords) or coords == hovered_cell or cells_to_update.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords == hovered_cell:
		if _is_blue_tile(coords):
			tile_data.modulate = Color.WHITE
			tile_data.texture_origin = base_texture_origin
			return

		if reachable_cells.has(coords):
			tile_data.modulate = reachable_hover_color
			tile_data.texture_origin = base_texture_origin + reachable_tile_lift
			return

		tile_data.modulate = blocked_hover_color
		tile_data.texture_origin = base_texture_origin
		return

	if reachable_cells.has(coords):
		tile_data.modulate = reachable_tile_color
		tile_data.texture_origin = base_texture_origin + reachable_tile_lift
		return

	tile_data.modulate = Color.WHITE
	tile_data.texture_origin = base_texture_origin

func _mark_reachable_cells_for_update() -> void:
	for cell in reachable_cells.keys():
		cells_to_update[cell] = true

func _is_blue_tile(coords: Vector2i) -> bool:
	return get_cell_atlas_coords(coords) == BLUE_TILE

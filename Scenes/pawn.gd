extends CharacterBody2D

@export var move_time_per_tile: float = 0.18
@export var snap_offset: Vector2 = Vector2(0, -6)
@export var movement_points_per_turn: int = 3

var tile_board
var navigation_system: HexNavigationSystem
var current_cell: Vector2i
var target_cell: Vector2i
var movement_points_left: int
var is_moving := false
var last_mouse_viewport_position: Vector2 = Vector2.ZERO

func setup(_tile_board: TileMapLayer, _navigation_system: HexNavigationSystem) -> void:
	tile_board = _tile_board
	navigation_system = _navigation_system
	movement_points_left = movement_points_per_turn
	current_cell = navigation_system.get_random_walkable_cell()
	target_cell = current_cell
	global_position = _cell_to_global(current_cell)
	_update_reachable_tiles()

func _ready() -> void:
	$PawnSprite.play("pawn_idle")
	$PathPreviz.top_level = true
	$PathPreviz.global_position = Vector2.ZERO
	$PathPreviz.global_rotation = 0.0
	$PathPreviz.global_scale = Vector2.ONE

func _input(event: InputEvent) -> void:
	if tile_board == null or navigation_system == null:
		return

	if event is InputEventMouse:
		last_mouse_viewport_position = event.position
		_update_path_preview()

	if Input.is_action_just_pressed("leftClick"):
		_move_to_mouse()

func _process(_delta: float) -> void:
	if tile_board == null or navigation_system == null:
		return

	_update_path_preview()

func _move_to_mouse() -> void:
	if is_moving:
		return

	var clicked_cell: Vector2i = _get_mouse_cell()
	if not navigation_system.is_cell_walkable(clicked_cell):
		return

	var path: PackedVector2Array = navigation_system.get_path_between_cells(current_cell, clicked_cell)
	if path.size() == 0:
		return

	var path_cost: int = path.size() - 1
	if path_cost > movement_points_per_turn:
		return

	is_moving = true
	tile_board.clear_reachable_cells()
	$PathPreviz.clear_points()

	for i in range(1, path.size()):
		var target_position: Vector2 = tile_board.to_global(path[i]) + snap_offset
		var tween := create_tween()
		tween.tween_property(self, "global_position", target_position, move_time_per_tile)
		await tween.finished

	current_cell = clicked_cell
	target_cell = clicked_cell
	movement_points_left = movement_points_per_turn
	is_moving = false
	_update_reachable_tiles()

func _update_path_preview() -> void:
	if is_moving:
		return

	var hover_cell: Vector2i = _get_mouse_cell()
	tile_board.set_hovered_cell(hover_cell)

	if hover_cell == target_cell:
		return

	target_cell = hover_cell
	$PathPreviz.clear_points()

	if not navigation_system.is_cell_walkable(hover_cell):
		return

	if navigation_system.get_path_cost(current_cell, hover_cell) > movement_points_per_turn:
		return

	var path: PackedVector2Array = navigation_system.get_path_between_cells(current_cell, hover_cell)
	for point in path:
		$PathPreviz.add_point(tile_board.to_global(point) + snap_offset)

func reset_turn() -> void:
	movement_points_left = movement_points_per_turn
	_update_reachable_tiles()

func _cell_to_global(cell: Vector2i) -> Vector2:
	return tile_board.to_global(tile_board.map_to_local(cell)) + snap_offset

func _get_mouse_cell() -> Vector2i:
	var viewport_position := last_mouse_viewport_position
	if viewport_position == Vector2.ZERO:
		viewport_position = get_viewport().get_mouse_position()

	var tile_board_local_position: Vector2 = tile_board.get_global_transform_with_canvas().affine_inverse() * viewport_position
	return tile_board.local_to_map(tile_board_local_position)

func _update_reachable_tiles() -> void:
	if tile_board == null or navigation_system == null:
		return

	tile_board.set_reachable_cells(navigation_system.get_reachable_cells(current_cell, movement_points_per_turn))

extends Camera2D

var isPressed := false

var zoom_target := 1.0
var zoom_speed := 0.1
var min_zoom := 0.1
var max_zoom := 2.5
var keyboard_pan_speed := 500.0
var keyboard_zoom_speed := 1.2
@export var tile_board_path: NodePath = ^"../TileMapPlate/TileBoard"
@export var frame_padding := 0.9

func _ready() -> void:
	zoom_target = zoom.x

func _input(event: InputEvent) -> void:
	isPressed = Input.is_action_pressed("midleClick")

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		frame_tile_board()

	if Input.is_action_just_pressed("MidleMouseZoomUp"):
		_zoom_to_mouse(zoom_speed)
	elif  Input.is_action_just_pressed("MidleMouseZoomDown"):
		_zoom_to_mouse(-zoom_speed)

	if event is InputEventMouseMotion and isPressed:
		global_position += -event.relative * (1 / zoom.x)

func _process(delta: float) -> void:
	var move_direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_W):
		move_direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_direction.y += 1.0
	if Input.is_key_pressed(KEY_A):
		move_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_direction.x += 1.0

	if move_direction != Vector2.ZERO:
		global_position += move_direction.normalized() * keyboard_pan_speed * delta / zoom.x

	var keyboard_zoom_delta := 0.0
	if Input.is_key_pressed(KEY_E):
		keyboard_zoom_delta += keyboard_zoom_speed * delta
	if Input.is_key_pressed(KEY_Q):
		keyboard_zoom_delta -= keyboard_zoom_speed * delta

	if keyboard_zoom_delta != 0.0:
		_zoom_to_screen_center(keyboard_zoom_delta)

func _zoom_to_mouse(zoom_delta: float) -> void:
	var mouse_before_zoom: Vector2 = get_global_mouse_position()
	zoom_target = clamp(zoom_target + zoom_delta, min_zoom, max_zoom)
	zoom = Vector2.ONE * zoom_target
	var mouse_after_zoom: Vector2 = get_global_mouse_position()
	global_position += mouse_before_zoom - mouse_after_zoom

func _zoom_to_screen_center(zoom_delta: float) -> void:
	zoom_target = clamp(zoom_target + zoom_delta, min_zoom, max_zoom)
	zoom = Vector2.ONE * zoom_target

func frame_tile_board() -> void:
	var tile_board := get_node_or_null(tile_board_path) as TileMapLayer
	if tile_board == null:
		return

	var used_rect := tile_board.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return

	var board_bounds := _get_tile_board_global_bounds(tile_board, used_rect)
	if board_bounds.size.x <= 0.0 or board_bounds.size.y <= 0.0:
		return

	global_position = board_bounds.get_center()

	var viewport_size: Vector2 = get_viewport_rect().size
	var fit_zoom: float = min(viewport_size.x / board_bounds.size.x, viewport_size.y / board_bounds.size.y) * frame_padding
	zoom_target = clamp(fit_zoom, min_zoom, max_zoom)
	zoom = Vector2.ONE * zoom_target

func _get_tile_board_global_bounds(tile_board: TileMapLayer, used_rect: Rect2i) -> Rect2:
	var half_tile_size := Vector2(tile_board.tile_set.tile_size) * 0.5
	var min_position := Vector2(INF, INF)
	var max_position := Vector2(-INF, -INF)

	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var cell := Vector2i(x, y)
			if tile_board.get_cell_source_id(cell) == -1:
				continue

			var cell_center := tile_board.to_global(tile_board.map_to_local(cell))
			min_position.x = min(min_position.x, cell_center.x - half_tile_size.x)
			min_position.y = min(min_position.y, cell_center.y - half_tile_size.y)
			max_position.x = max(max_position.x, cell_center.x + half_tile_size.x)
			max_position.y = max(max_position.y, cell_center.y + half_tile_size.y)

	return Rect2(min_position, max_position - min_position)

extends Camera2D

var isPressed := false

var zoom_target := 1.0
var zoom_speed := 0.1
var min_zoom := 0.1
var max_zoom := 2.5
var keyboard_pan_speed := 500.0
var keyboard_zoom_speed := 1.2

func _ready() -> void:
	zoom_target = zoom.x

func _input(event: InputEvent) -> void:
	isPressed = Input.is_action_pressed("midleClick")

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

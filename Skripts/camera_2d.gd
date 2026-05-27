extends Camera2D

var isPressed := false

var zoom_target := 1.0
var zoom_speed := 0.1
var min_zoom := 0.1
var max_zoom := 2.5

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

func _zoom_to_mouse(zoom_delta: float) -> void:
	var mouse_before_zoom: Vector2 = get_global_mouse_position()
	zoom_target = clamp(zoom_target + zoom_delta, min_zoom, max_zoom)
	zoom = Vector2.ONE * zoom_target
	var mouse_after_zoom: Vector2 = get_global_mouse_position()
	global_position += mouse_before_zoom - mouse_after_zoom

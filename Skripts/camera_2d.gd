extends Camera2D

var isPressed := false

var zoom_target := 1.0
var zoom_speed := 0.1
var min_zoom := 0.1
var max_zoom := 2.5

func _input(event: InputEvent) -> void:
	isPressed = Input.is_action_pressed("midleClick")
		
	if Input.is_action_just_pressed("MidleMouseZoomUp"):
		zoom_target += zoom_speed
	elif  Input.is_action_just_pressed("MidleMouseZoomDown"):
		zoom_target -= zoom_speed
	
	zoom_target = clamp(zoom_target, min_zoom, max_zoom)
	
	if event is InputEventMouseMotion && isPressed:
		global_position += -event.relative*(1/zoom_target)
	
func _process(delta):
	zoom = zoom.lerp(Vector2.ONE * zoom_target, 10 * delta)

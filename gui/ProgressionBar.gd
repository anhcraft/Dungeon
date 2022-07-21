extends ColorRect

var _target_ratio = 1.0;
var _current_ratio = 1.0;

func _ready():
	var color = Color.red
	set_overlay_color(color.lightened(0.1))
	color.a = 0.4
	set_background_color(color)

func _process(delta):
	if abs(_target_ratio - _current_ratio) > 0.01:
		_current_ratio = clamp(_current_ratio + (_target_ratio - _current_ratio) * 0.1, 0.0, 1.0)
		if _current_ratio > 0.98:
			hide()
		else:
			show() 
			material.set_shader_param("progress", _current_ratio)

func set_target_ratio(v: float):
	_target_ratio = v

func set_overlay_color(color: Color):
	material.set_shader_param("overlay_color", color)

func set_background_color(color: Color):
	material.set_shader_param("background_color", color)

func relocate_above_shape(polygon: PoolVector2Array, scale: Vector2):
	var top = polygon[0].y
	var left = polygon[0].x
	var right = polygon[0].x
	for v in polygon:
		top = min(v.y, top)
		left = min(v.x, left)
		right = max(v.x, right)

	var k = 1.0
	if scale.x < 0:
		k = 0.5
	rect_position = Vector2(
		(left + right - rect_size.x * k) * 0.5,
		top - rect_size.y * 2.0
	)

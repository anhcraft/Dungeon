extends ColorRect

var _target_ratio = 1.0;
var _current_ratio = 1.0;

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

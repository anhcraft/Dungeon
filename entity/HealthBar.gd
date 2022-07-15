extends ColorRect

var rect_max_size = 0.0;
var target_ratio = 1.0;
var current_ratio = 1.0;

func _ready():
	rect_max_size = rect_size.x

func _process(delta):
	# health bar animation
	target_ratio = $"/root/Player".get_health_ratio()
	if abs(target_ratio - current_ratio) > 0.01:
		current_ratio = clamp(current_ratio + (target_ratio - current_ratio) * 0.1, 0.0, 1.0)
		rect_size.x = current_ratio * rect_max_size

func relocate():
	var arr = $"../CollisionShape2D".polygon
	var top = arr[0].y
	var left = arr[0].x
	var right = arr[0].x
	for v in arr:
		top = min(v.y, top)
		left = min(v.x, left)
		right = max(v.x, right)

	var k = 1.0
	if $"../CollisionShape2D".scale.x < 0:
		k = 0.5
	rect_position.x = (left + right - rect_size.x * k) * 0.5
	rect_position.y = top - rect_size.y * 2.0
	$"../HealthBarBackground".rect_position = rect_position
